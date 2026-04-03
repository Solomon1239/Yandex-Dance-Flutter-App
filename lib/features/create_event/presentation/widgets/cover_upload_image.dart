import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
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
  bool isUploading = false;
  String? uploadedUrl;

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
          isUploading = true;
        });

        widget.onChanged?.call(file);

        // TODO: Реализовать логику загрузки и получения URL
      }
    } catch (e) {
      debugPrint('Ошибка при выборе изображения: $e');
      setState(() => isUploading = false);
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
    return GestureDetector(
      onTap: isUploading ? null : pickImage,
      child:
          selectedImage == null
              ? DottedBorder(
                childOnTop: true,
                options: RoundedRectDottedBorderOptions(
                  strokeWidth: 1,
                  color: AppColors.purple600,
                  dashPattern: [6, 4],
                  radius: const Radius.circular(24),
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.gray400,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppIcons.upload,
                        width: 36,
                        height: 36,
                        colorFilter: const ColorFilter.mode(
                          AppColors.gray100,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Загрузить обложку',
                        style: AppTextTheme.body3Regular20pt.copyWith(
                          color: AppColors.gray100,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                alignment: Alignment.center,
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child:
                      uploadedUrl != null
                          ? Image.network(
                            uploadedUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                          : Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              if (isUploading)
                                Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Изменить',
                                        style: AppTextTheme.body3Regular20pt
                                            .copyWith(color: Colors.white),
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

  Future<void> uploadFile(XFile file) async {
    // Здесь ваша логика загрузки на сервер
    // Например:
    // try {
    //   final response = await apiService.uploadCover(file);
    //   setState(() {
    //     uploadedUrl = response.url;
    //     isUploading = false;
    //   });
    // } catch (e) {
    //   setState(() => isUploading = false);
    //   // Обработка ошибки
    // }
  }
}
