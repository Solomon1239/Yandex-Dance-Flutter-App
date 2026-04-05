import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

Future<DateTime?> showDateOfBirthPicker({
  required BuildContext context,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: AppColors.gray400,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final now = DateTime.now();
      DateTime tempDate = initialDate ?? DateTime(now.year - 18);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Отмена',
                      style: AppTextTheme.body4Medium16pt.copyWith(
                        color: AppColors.gray300,
                      ),
                    ),
                  ),
                  Text(
                    'Дата рождения',
                    style: AppTextTheme.body4Medium16pt.copyWith(
                      color: AppColors.gray0,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(ctx, tempDate),
                    child: Text(
                      'Готово',
                      style: AppTextTheme.body4Medium16pt.copyWith(
                        color: AppColors.purple500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 216,
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: AppColors.gray0,
                      fontSize: 20,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate ?? DateTime(now.year - 18),
                  minimumDate: DateTime(1920),
                  maximumDate: now,
                  onDateTimeChanged: (date) => tempDate = date,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
