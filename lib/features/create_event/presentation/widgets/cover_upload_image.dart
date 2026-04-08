import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/widgets/custom_bounce_effect.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

class CoverUploadWidget extends StatefulWidget {
  const CoverUploadWidget({super.key, this.onChanged, this.initialImagePath});

  final Function(File)? onChanged;
  final String? initialImagePath;

  @override
  State<CoverUploadWidget> createState() => _CoverUploadWidgetState();
}

class _CoverUploadWidgetState extends State<CoverUploadWidget> {
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      selectedImage = File(widget.initialImagePath!);
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await showPickerDialog();
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          selectedImage = file;
        });
        widget.onChanged?.call(file);
      }
    } catch (e) {
      debugPrint('Ошибка при выборе изображения: $e');
    }
  }

  Future<XFile?> showPickerDialog() async {
    final ImagePicker picker = ImagePicker();

    if (Platform.isIOS) {
      final source = await showCupertinoModalPopup<ImageSource>(
        context: context,
        builder:
            (_) => CupertinoActionSheet(
              title: const Text('Выберите действие'),
              actions: [
                CupertinoActionSheetAction(
                  child: const Text('Выбрать из галереи'),
                  onPressed:
                      () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                CupertinoActionSheetAction(
                  child: const Text('Сделать фото'),
                  onPressed:
                      () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      );
      if (source != null) {
        return await picker.pickImage(source: source);
      }
    } else {
      final source = await showDialog<ImageSource>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Выберите действие'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Выбрать из галереи'),
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Сделать фото'),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
              ],
            ),
      );
      if (source != null) {
        return await picker.pickImage(source: source);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomBounceEffect(
      onTap: pickImage,
      child:
          selectedImage == null
              ? DottedBorder(
                childOnTop: true,
                options: RoundedRectDottedBorderOptions(
                  strokeWidth: 1,
                  color: AppColors.purple600,
                  dashPattern: [6, 4],
                  radius: const Radius.circular(18),
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.gray400,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppIcons.upload,
                        width: 30,
                        height: 30,
                        colorFilter: const ColorFilter.mode(
                          AppColors.gray100,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Загрузить обложку',
                        style: AppTextTheme.body4Medium16pt.copyWith(
                          color: AppColors.gray100,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                alignment: Alignment.center,
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Изменить',
                                style: AppTextTheme.body2Regular14pt.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
