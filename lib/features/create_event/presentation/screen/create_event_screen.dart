import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/core/errors/app_exception.dart';
import 'package:yandex_dance/core/services/geo/address_search_service.dart';
import 'package:yandex_dance/core/services/geo/address_suggestion.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/icons/svg_icon.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/snackbar/app_snackbar.dart';
import 'package:yandex_dance/features/auth/domain/repositories/auth_repository.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/cover_upload_image.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/dance_style_dropdown.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/date_time_picker_row.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/event_addres_field.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/event_description_field.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/event_title_field.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/event_max_participants_field.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/age_restriction_field.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/create_event_button.dart';
import 'package:yandex_dance/features/events/domain/repositories/event_repository.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  late final AddressSearchService _addressSearchService;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _maxParticipantsFocus = FocusNode();

  bool _titleTouched = false;
  bool _descriptionTouched = false;
  bool _addressTouched = false;
  bool _maxParticipantsTouched = false;

  InputState _titleState = InputState.initial;
  InputState _descriptionState = InputState.initial;
  InputState _addressState = InputState.initial;
  InputState _maxParticipantsState = InputState.initial;

  DanceStyle? _selectedDanceStyle;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _selectedAgeRestriction = 'Для всех';
  AddressSuggestion? _selectedAddressSuggestion;

  File? _selectedCoverFile;

  @override
  void initState() {
    super.initState();
    _addressSearchService = sl<AddressSearchService>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _maxParticipantsController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _addressFocus.dispose();
    _maxParticipantsFocus.dispose();
    super.dispose();
  }

  String? _titleValidator(String value) {
    if (value.isEmpty) return 'Введите название';
    if (value.length < 3) return 'Минимум 3 символа';
    return null;
  }

  String? _descriptionValidator(String value) {
    if (value.isEmpty) return 'Введите описание';
    if (value.length < 10) return 'Минимум 10 символов';
    return null;
  }

  String? _addressValidator(String value) {
    if (value.isEmpty) return 'Введите адрес';
    if (value.length < 5) return 'Минимум 5 символов';
    return null;
  }

  String? _maxParticipantsValidator(String value) {
    if (value.isEmpty) return 'Введите количество участников';

    final int? number = int.tryParse(value);
    if (number == null) return 'Введите корректное число';

    if (number < 1) return 'Минимум 1 участник';
    if (number > 1000) return 'Максимум 1000 участников';

    return null;
  }

  bool _validateAllFields() {
    bool isValid = true;

    final titleError = _titleValidator(_titleController.text);
    if (titleError != null) {
      setState(() {
        _titleTouched = true;
        _titleState = InputState.error;
      });
      isValid = false;
    }

    final descriptionError = _descriptionValidator(_descriptionController.text);
    if (descriptionError != null) {
      setState(() {
        _descriptionTouched = true;
        _descriptionState = InputState.error;
      });
      isValid = false;
    }

    final addressError = _addressValidator(_addressController.text);
    if (addressError != null) {
      setState(() {
        _addressTouched = true;
        _addressState = InputState.error;
      });
      isValid = false;
    }
    if (_selectedAddressSuggestion == null ||
        _selectedAddressSuggestion!.displayLabel !=
            _addressController.text.trim()) {
      setState(() {
        _addressTouched = true;
        _addressState = InputState.error;
      });
      AppSnackBar.showError(context, 'Выберите адрес из подсказок');
      isValid = false;
    }

    final maxParticipantsError = _maxParticipantsValidator(
      _maxParticipantsController.text,
    );
    if (maxParticipantsError != null) {
      setState(() {
        _maxParticipantsTouched = true;
        _maxParticipantsState = InputState.error;
      });
      isValid = false;
    }

    if (_selectedDanceStyle == null) {
      AppSnackBar.showError(context, 'Выберите стиль танца');
      isValid = false;
    }

    if (_selectedDate == null) {
      AppSnackBar.showError(context, 'Выберите дату мероприятия');
      isValid = false;
    }

    if (_selectedTime == null) {
      AppSnackBar.showError(context, 'Выберите время мероприятия');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _createEvent() async {
    FocusScope.of(context).unfocus();

    if (!_validateAllFields()) {
      AppSnackBar.showError(
        context,
        'Пожалуйста, заполните все обязательные поля',
      );
      return;
    }

    try {
      final uid = sl<AuthRepository>().currentUserId;
      if (uid == null) {
        throw Exception('Пользователь не авторизован');
      }

      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await sl<EventRepository>().createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        danceStyle: _selectedDanceStyle!,
        dateTime: eventDateTime,
        address: _addressController.text.trim(),
        latitude: _selectedAddressSuggestion?.latitude,
        longitude: _selectedAddressSuggestion?.longitude,
        maxParticipants: int.parse(_maxParticipantsController.text.trim()),
        ageRestriction: _selectedAgeRestriction,
        creatorId: uid,
        coverSourcePath: _selectedCoverFile?.path,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Успешно!'),
                content: const Text('Мероприятие успешно создано'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Ошибка: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray500,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('Создать мероприятие', style: AppTextTheme.body1Medium18pt),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: AppButton(
            iconWidget: const SvgIcon(
              AppIcons.back,
              size: 20,
              color: AppColors.gray0,
            ),
            onTap: () => Navigator.of(context).pop(),
            style: const AppButtonStyle(
              width: 40,
              height: 40,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoverUploadWidget(
              onChanged: (file) {
                _selectedCoverFile = file;
              },
            ),
            const SizedBox(height: 14),

            EventTitleField(
              controller: _titleController,
              focusNode: _titleFocus,
              touched: _titleTouched,
              state: _titleState,
              validator: _titleValidator,
              nextFocusNode: _descriptionFocus,
              onChanged: (value) {
                setState(() => _titleTouched = true);
              },
              onStateChange: (state) {
                setState(() => _titleState = state);
              },
            ),

            const SizedBox(height: 14),

            EventDescriptionField(
              controller: _descriptionController,
              focusNode: _descriptionFocus,
              touched: _descriptionTouched,
              state: _descriptionState,
              validator: _descriptionValidator,
              onChanged: (value) {
                setState(() => _descriptionTouched = true);
              },
              onStateChange: (state) {
                setState(() => _descriptionState = state);
              },
            ),

            const SizedBox(height: 14),

            DanceStyleDropdown(
              selectedStyle: _selectedDanceStyle,
              onChanged: (value) {
                setState(() {
                  _selectedDanceStyle = value;
                });
              },
            ),

            const SizedBox(height: 14),

            DateTimePickerRow(
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              onTimeSelected: (time) {
                setState(() {
                  _selectedTime = time;
                });
              },
            ),

            const SizedBox(height: 14),

            EventAddressField(
              controller: _addressController,
              focusNode: _addressFocus,
              touched: _addressTouched,
              state: _addressState,
              validator: _addressValidator,
              searchService: _addressSearchService,
              selectedAddress: _selectedAddressSuggestion,
              onAddressSelected:
                  (value) => setState(() => _selectedAddressSuggestion = value),
              onChanged: (value) {
                setState(() => _addressTouched = true);
              },
              onStateChange: (state) {
                setState(() => _addressState = state);
              },
            ),

            const SizedBox(height: 14),

            EventMaxParticipantsField(
              controller: _maxParticipantsController,
              focusNode: _maxParticipantsFocus,
              touched: _maxParticipantsTouched,
              state: _maxParticipantsState,
              validator: _maxParticipantsValidator,
              onChanged: (value) {
                setState(() => _maxParticipantsTouched = true);
              },
              onStateChange: (state) {
                setState(() => _maxParticipantsState = state);
              },
            ),

            const SizedBox(height: 14),

            AgeRestrictionField(
              selectedAgeRestriction: _selectedAgeRestriction,
              onChanged: (value) {
                setState(() {
                  _selectedAgeRestriction = value;
                });
              },
            ),

            const SizedBox(height: 20),

            CreateEventButton(
              onPressed: _createEvent,
              text: 'Создать мероприятие',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
