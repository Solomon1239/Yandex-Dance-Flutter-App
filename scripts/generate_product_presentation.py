#!/usr/bin/env python3

from __future__ import annotations

import argparse
import shutil
import zipfile
from pathlib import Path
import xml.etree.ElementTree as ET

P_NS = "http://schemas.openxmlformats.org/presentationml/2006/main"
A_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"
R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

NS = {"p": P_NS, "a": A_NS, "r": R_NS, "pkg": PKG_NS}

ET.register_namespace("a", A_NS)
ET.register_namespace("p", P_NS)
ET.register_namespace("r", R_NS)
ET.register_namespace("", PKG_NS)

SLIDE_ORDER = [1, 9, 13, 20, 21, 22, 23, 24, 16, 28, 25, 26, 31]

SLIDE_TEXTS: dict[int, list[str]] = {
    1: [
        "YANDEX DANCE",
        "События",
        "и люди",
        "Приложение для",
        "танцевального сообщества",
    ],
    9: [
        "СОДЕРЖАНИЕ",
        "Проблема",
        "и контекст",
        "01",
        "Продукт",
        "и аудитория",
        "02",
        "Сценарии",
        "и ценность",
        "03",
        "Реализация",
        "и рост",
        "04",
    ],
    13: ["ПРОДУКТ"],
    16: [
        "MVP УЖЕ ЗАКРЫВАЕТ",
        "ОСНОВНОЙ ПУТЬ ПОЛЬЗОВАТЕЛЯ",
    ],
    20: [
        "Проблема",
        "События и комьюнити",
        "разрознены между платформами",
        "КОНТЕКСТ",
        "И ЗАПРОС",
        "04",
    ],
    21: [
        "ПРОДУКТ",
        "В ОДНОМ",
        "ПРИЛОЖЕНИИ",
        "Решение",
        "Yandex Dance объединяет discovery, social и creator tools",
        "Пользователь входит, выбирает стили, ищет события, подписывается на людей, создает свой ивент и развивает профиль внутри одного мобильного сценария",
        "05",
    ],
    22: [
        "СЦЕНАРИЙ",
        "01",
        "ПОИСК СОБЫТИЙ",
        "Мероприятия",
        "Лента, фильтры и карта в одном экране",
        "Поиск по стилю, дате и возрасту, карточка события, детали, участие и переключение список/карта через MapLibre",
        "LIST + MAP",
        "06",
    ],
    23: [
        "ДЛЯ",
        "Создание мероприятия",
        "Форма без ручной рутины",
        "Обложка, описание, стиль, дата и время, адрес с подсказками DaData, возрастной рейтинг и лимит участников",
        "СЦЕНАРИЙ",
        "02",
        "07",
    ],
    24: [
        "ДЛЯ",
        "Профиль и друзья",
        "Социальный слой вокруг событий",
        "Поиск танцоров, подписки, чужой профиль, свои стили, видео-интро и собственные события формируют живое сообщество",
        "СЦЕНАРИЙ",
        "03",
        "08",
    ],
    25: [
        "ТЕХНИЧЕСКАЯ",
        "Архитектура",
        "Flutter-клиент с модульной feature-структурой",
        "Firebase Auth, Firestore и Storage; go_router, get_it, MapLibre, DaData, оптимизация изображений и видео, unit и widget tests",
        "ПЛАТФОРМА",
        "И СТЕК",
        "11",
    ],
    26: [
        "РОСТ",
        "Развитие",
        "Из рабочего MVP в полноценную платформу",
        "Следующий слой ценности: рекомендации, push-уведомления, роли организаторов, ticketing, аналитика и монетизация creator-инструментов",
        "СЛЕДУЮЩИЙ",
        "ШАГ",
        "12",
    ],
    28: [
        "РЕАЛИЗОВАНО",
        "В MVP",
        "Email, Google",
        "и Apple sign-in",
        "Онбординг по",
        "танцевальным стилям",
        "Лента событий, карта",
        "и детальная карточка",
        "Создание события",
        "с медиа и адресом",
        "Профили, подписки",
        "и видео-интро",
        "10",
    ],
    31: ["ТАНЦЫ, ЛЮДИ И СОБЫТИЯ"],
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build a Yandex Dance product deck from a PPTX template."
    )
    parser.add_argument("template", type=Path, help="Path to the PPTX template")
    parser.add_argument("output", type=Path, help="Path for the generated PPTX")
    return parser.parse_args()


def collect_slide_text_nodes(root: ET.Element) -> list[ET.Element]:
    return list(root.findall(".//a:t", NS))


def replace_slide_texts(xml_bytes: bytes, replacements: list[str], slide_no: int) -> bytes:
    root = ET.fromstring(xml_bytes)
    text_nodes = collect_slide_text_nodes(root)
    if len(text_nodes) != len(replacements):
        raise ValueError(
            f"Slide {slide_no} expects {len(text_nodes)} text nodes, got {len(replacements)} replacements"
        )

    for node, value in zip(text_nodes, replacements, strict=True):
        node.text = value

    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def slide_rid_map(rels_root: ET.Element) -> dict[int, str]:
    result: dict[int, str] = {}
    for rel in rels_root.findall("pkg:Relationship", NS):
        target = rel.get("Target", "")
        if target.startswith("slides/slide") and target.endswith(".xml"):
            slide_no = int(target.removeprefix("slides/slide").removesuffix(".xml"))
            result[slide_no] = rel.get("Id", "")
    return result


def reorder_presentation(xml_bytes: bytes, rels_bytes: bytes) -> bytes:
    root = ET.fromstring(xml_bytes)
    rels_root = ET.fromstring(rels_bytes)
    rid_by_slide = slide_rid_map(rels_root)

    slide_id_list = root.find("p:sldIdLst", NS)
    if slide_id_list is None:
        raise ValueError("Presentation does not contain a slide list")

    existing_by_rid = {
        slide_id.get(f"{{{R_NS}}}id"): slide_id for slide_id in slide_id_list.findall("p:sldId", NS)
    }

    for child in list(slide_id_list):
        slide_id_list.remove(child)

    for slide_no in SLIDE_ORDER:
        rid = rid_by_slide[slide_no]
        slide_id = existing_by_rid.get(rid)
        if slide_id is None:
            raise ValueError(f"Slide {slide_no} with relationship {rid} is missing")
        slide_id_list.append(slide_id)

    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def build_presentation(template_path: Path, output_path: Path) -> None:
    if not template_path.exists():
        raise FileNotFoundError(f"Template not found: {template_path}")

    output_path.parent.mkdir(parents=True, exist_ok=True)

    with zipfile.ZipFile(template_path, "r") as source_zip:
        contents: dict[str, bytes] = {
            item.filename: source_zip.read(item.filename) for item in source_zip.infolist()
        }
        compression_by_name = {
            item.filename: item.compress_type for item in source_zip.infolist()
        }

    for slide_no, replacements in SLIDE_TEXTS.items():
        slide_name = f"ppt/slides/slide{slide_no}.xml"
        contents[slide_name] = replace_slide_texts(contents[slide_name], replacements, slide_no)

    contents["ppt/presentation.xml"] = reorder_presentation(
        contents["ppt/presentation.xml"], contents["ppt/_rels/presentation.xml.rels"]
    )

    temp_output = output_path.with_suffix(".tmp")
    if temp_output.exists():
        temp_output.unlink()

    with zipfile.ZipFile(temp_output, "w") as output_zip:
        for file_name, payload in contents.items():
            output_zip.writestr(
                file_name,
                payload,
                compress_type=compression_by_name.get(file_name, zipfile.ZIP_DEFLATED),
            )

    shutil.move(temp_output, output_path)


def main() -> None:
    args = parse_args()
    build_presentation(args.template, args.output)
    print(f"Generated: {args.output}")


if __name__ == "__main__":
    main()
