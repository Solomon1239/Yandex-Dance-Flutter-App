import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

class DateTimePickerRow extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final void Function(DateTime) onDateSelected;
  final void Function(TimeOfDay) onTimeSelected;

  const DateTimePickerRow({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showCustomCupertinoDatePicker(
      context,
      initialDate: selectedDate ?? DateTime.now(),
      minimumDate: DateTime.now(),
      maximumDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showCustomCupertinoTimePicker(
      context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Дата', style: AppTextTheme.body4Medium16pt),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.gray400.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gray300.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.gray300,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedDate != null
                            ? '${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}'
                            : 'ДД.ММ.ГГГГ',
                        style: AppTextTheme.body2Regular14pt.copyWith(
                          color:
                              selectedDate != null
                                  ? AppColors.gray0
                                  : AppColors.gray300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Время', style: AppTextTheme.body4Medium16pt),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.gray400.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gray300.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: AppColors.gray300,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : '--:--',
                        style: AppTextTheme.body2Regular14pt.copyWith(
                          color:
                              selectedTime != null
                                  ? AppColors.gray0
                                  : AppColors.gray300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? minimumDate;
  final DateTime? maximumDate;

  const CustomDatePicker({
    super.key,
    required this.initialDate,
    this.minimumDate,
    this.maximumDate,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = _resetTimeToStartOfDay(widget.initialDate);
  }

  DateTime _resetTimeToStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _getMinimumDate() {
    if (widget.minimumDate == null) return null;
    return _resetTimeToStartOfDay(widget.minimumDate!);
  }

  DateTime? _getMaximumDate() {
    if (widget.maximumDate == null) return null;
    return DateTime(
      widget.maximumDate!.year,
      widget.maximumDate!.month,
      widget.maximumDate!.day,
      23,
      59,
      59,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 283,
            decoration: BoxDecoration(
              color: AppColors.gray400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    'Выберите дату',
                    style: AppTextTheme.body1Medium18pt.copyWith(
                      color: AppColors.gray300,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(height: 1, color: AppColors.gray300),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 18,
                    bottom: 16,
                    right: 7.5,
                    left: 7.5,
                  ),
                  child: SizedBox(
                    height: 190,
                    child: CupertinoDatePicker(
                      initialDateTime: dateTime,
                      mode: CupertinoDatePickerMode.date,
                      minimumDate: _getMinimumDate(),
                      maximumDate: _getMaximumDate(),
                      onDateTimeChanged: (DateTime value) {
                        setState(() {
                          dateTime = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.gray400,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(dateTime);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Подтвердить',
                        textAlign: TextAlign.center,
                        style: AppTextTheme.body1Medium18pt.copyWith(
                          color: AppColors.purple500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(height: 1, color: AppColors.gray300),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Отмена',
                        style: AppTextTheme.body1Medium18pt.copyWith(
                          color: AppColors.pink500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Кастомный TimePicker в стиле вашего приложения
class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePicker({super.key, required this.initialTime});

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late DateTime dateTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.initialTime.hour,
      widget.initialTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 285,
            decoration: BoxDecoration(
              color: AppColors.gray400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    'Выберите время',
                    style: AppTextTheme.body1Medium18pt.copyWith(
                      color: AppColors.gray300,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(height: 1, color: AppColors.gray300),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 18,
                    bottom: 16,
                    right: 7.5,
                    left: 7.5,
                  ),
                  child: SizedBox(
                    height: 190,
                    child: CupertinoDatePicker(
                      initialDateTime: dateTime,
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat:
                          MediaQuery.of(context).alwaysUse24HourFormat,
                      minuteInterval: 1,
                      onDateTimeChanged: (DateTime value) {
                        setState(() {
                          dateTime = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.gray400,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(TimeOfDay.fromDateTime(dateTime));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Подтвердить',
                        textAlign: TextAlign.center,
                        style: AppTextTheme.body1Medium18pt.copyWith(
                          color: AppColors.purple500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(height: 1, color: AppColors.gray300),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Отмена',
                        style: AppTextTheme.body1Medium18pt.copyWith(
                          color: AppColors.pink500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Функции для показа пикеров
Future<DateTime?> showCustomCupertinoDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) {
  // Округляем initialDate до начала дня
  final normalizedInitialDate = DateTime(
    initialDate.year,
    initialDate.month,
    initialDate.day,
  );

  // Округляем minimumDate до начала дня
  final DateTime? normalizedMinimumDate =
      minimumDate != null
          ? DateTime(minimumDate.year, minimumDate.month, minimumDate.day)
          : null;

  // Округляем maximumDate до конца дня
  final DateTime? normalizedMaximumDate =
      maximumDate != null
          ? DateTime(
            maximumDate.year,
            maximumDate.month,
            maximumDate.day,
            23,
            59,
            59,
          )
          : null;

  return showDialog<DateTime?>(
    context: context,
    barrierColor: AppColors.gray200.withValues(alpha: 0.8),
    builder: (context) {
      return CustomDatePicker(
        initialDate: normalizedInitialDate,
        minimumDate: normalizedMinimumDate,
        maximumDate: normalizedMaximumDate,
      );
    },
  );
}

Future<TimeOfDay?> showCustomCupertinoTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay?>(
    context: context,
    barrierColor: AppColors.gray200.withValues(alpha: 0.8),
    builder: (context) {
      return CustomTimePicker(initialTime: initialTime);
    },
  );
}
