import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
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
import 'package:yandex_dance/features/create_event/presentation/widgets/age_restriction_field.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/create_event_button.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/cover_upload_image.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/dance_style_dropdown.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/date_time_picker_row.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/event_addres_field.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/event_description_field.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/event_max_participants_field.dart';
import 'package:yandex_dance/features/create_event/presentation/widgets/event_title_field.dart';
import 'package:yandex_dance/features/events/domain/entities/dance_event.dart';

class EditEventResult {
  const EditEventResult({
    required this.title,
    required this.description,
    required this.danceStyle,
    required this.dateTime,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.maxParticipants,
    required this.ageRestriction,
    this.coverSourcePath,
  });

  final String title;
  final String description;
  final DanceStyle danceStyle;
  final DateTime dateTime;
  final String address;
  final double? latitude;
  final double? longitude;
  final int maxParticipants;
  final String ageRestriction;
  final String? coverSourcePath;
}

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key, required this.event});

  final DanceEvent event;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
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

  late DanceStyle _selectedDanceStyle;
  late DateTime _selectedDateTime;
  late String _selectedAgeRestriction;
  AddressSuggestion? _selectedAddressSuggestion;
  File? _selectedCoverFile;

  @override
  void initState() {
    super.initState();
    _addressSearchService = sl<AddressSearchService>();
    _titleController.text = widget.event.title;
    _descriptionController.text = widget.event.description;
    _addressController.text = widget.event.address;
    _maxParticipantsController.text = widget.event.maxParticipants.toString();
    _selectedDanceStyle = widget.event.danceStyle;
    _selectedDateTime = widget.event.dateTime;
    _selectedAgeRestriction =
        widget.event.ageRestriction.trim().isEmpty
            ? 'Для всех'
            : widget.event.ageRestriction;
    if (widget.event.latitude != null && widget.event.longitude != null) {
      _selectedAddressSuggestion = AddressSuggestion(
        displayLabel: widget.event.address,
        latitude: widget.event.latitude!,
        longitude: widget.event.longitude!,
      );
    }
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

  DateTime get _selectedDate => DateTime(
    _selectedDateTime.year,
    _selectedDateTime.month,
    _selectedDateTime.day,
  );

  TimeOfDay get _selectedTime => TimeOfDay.fromDateTime(_selectedDateTime);

  bool _validateAllFields() {
    var isValid = true;

    final titleError = _titleValidator(_titleController.text.trim());
    if (titleError != null) {
      setState(() {
        _titleTouched = true;
        _titleState = InputState.error;
      });
      isValid = false;
    }

    final descriptionError = _descriptionValidator(
      _descriptionController.text.trim(),
    );
    if (descriptionError != null) {
      setState(() {
        _descriptionTouched = true;
        _descriptionState = InputState.error;
      });
      isValid = false;
    }

    final addressError = _addressValidator(_addressController.text.trim());
    if (addressError != null) {
      setState(() {
        _addressTouched = true;
        _addressState = InputState.error;
      });
      isValid = false;
    }

    final maxParticipantsError = _maxParticipantsValidator(
      _maxParticipantsController.text.trim(),
    );
    if (maxParticipantsError != null) {
      setState(() {
        _maxParticipantsTouched = true;
        _maxParticipantsState = InputState.error;
      });
      isValid = false;
    }

    final address = _addressController.text.trim();
    final isAddressChanged = address != widget.event.address.trim();
    if ((_selectedAddressSuggestion == null ||
            _selectedAddressSuggestion!.displayLabel != address) &&
        (isAddressChanged ||
            widget.event.latitude == null ||
            widget.event.longitude == null)) {
      setState(() {
        _addressTouched = true;
        _addressState = InputState.error;
      });
      AppSnackBar.showError(context, 'Выберите адрес из подсказок');
      isValid = false;
    }

    final maxParticipants = int.tryParse(
      _maxParticipantsController.text.trim(),
    );
    if (maxParticipants != null &&
        maxParticipants < widget.event.currentParticipants) {
      AppSnackBar.showError(
        context,
        'Количество мест не может быть меньше текущих участников (${widget.event.currentParticipants})',
      );
      isValid = false;
    }

    return isValid;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_validateAllFields()) {
      AppSnackBar.showError(
        context,
        'Пожалуйста, заполните все обязательные поля',
      );
      return;
    }

    Navigator.of(context).pop(
      EditEventResult(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        danceStyle: _selectedDanceStyle,
        dateTime: _selectedDateTime,
        address: _addressController.text.trim(),
        latitude: _selectedAddressSuggestion?.latitude ?? widget.event.latitude,
        longitude:
            _selectedAddressSuggestion?.longitude ?? widget.event.longitude,
        maxParticipants: int.parse(_maxParticipantsController.text.trim()),
        ageRestriction: _selectedAgeRestriction,
        coverSourcePath: _selectedCoverFile?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray500,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'Редактировать мероприятие',
          style: AppTextTheme.body1Medium18pt,
        ),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: AppButton(
            iconWidget: const SvgIcon(
              AppIcons.back,
              size: 20,
              color: AppColors.gray0,
            ),
            onTap: () async => Navigator.of(context).pop(),
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
            const SizedBox(height: 14),
            CoverUploadWidget(
              initialNetworkImageUrl:
                  widget.event.coverThumbUrl ?? widget.event.coverUrl,
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
              onChanged: (_) => setState(() => _titleTouched = true),
              onStateChange: (value) => setState(() => _titleState = value),
            ),
            const SizedBox(height: 14),
            EventDescriptionField(
              controller: _descriptionController,
              focusNode: _descriptionFocus,
              touched: _descriptionTouched,
              state: _descriptionState,
              validator: _descriptionValidator,
              onChanged: (_) => setState(() => _descriptionTouched = true),
              onStateChange: (value) {
                setState(() => _descriptionState = value);
              },
            ),
            const SizedBox(height: 14),
            DanceStyleDropdown(
              selectedStyle: _selectedDanceStyle,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedDanceStyle = value);
              },
            ),
            const SizedBox(height: 14),
            DateTimePickerRow(
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              onDateSelected: (date) {
                setState(() {
                  _selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    _selectedDateTime.hour,
                    _selectedDateTime.minute,
                  );
                });
              },
              onTimeSelected: (time) {
                setState(() {
                  _selectedDateTime = DateTime(
                    _selectedDateTime.year,
                    _selectedDateTime.month,
                    _selectedDateTime.day,
                    time.hour,
                    time.minute,
                  );
                });
              },
            ),
            const SizedBox(height: 14),
            EventAddressField(
              controller: _addressController,
              focusNode: _addressFocus,
              nextFocusNode: _maxParticipantsFocus,
              touched: _addressTouched,
              state: _addressState,
              validator: _addressValidator,
              searchService: _addressSearchService,
              selectedAddress: _selectedAddressSuggestion,
              onAddressSelected: (value) {
                setState(() {
                  _selectedAddressSuggestion = value;
                });
              },
              onChanged: (_) => setState(() => _addressTouched = true),
              onStateChange: (value) {
                setState(() => _addressState = value);
              },
            ),
            const SizedBox(height: 14),
            EventMaxParticipantsField(
              controller: _maxParticipantsController,
              focusNode: _maxParticipantsFocus,
              touched: _maxParticipantsTouched,
              state: _maxParticipantsState,
              validator: _maxParticipantsValidator,
              onChanged: (_) => setState(() => _maxParticipantsTouched = true),
              onStateChange: (value) {
                setState(() => _maxParticipantsState = value);
              },
            ),
            const SizedBox(height: 14),
            AgeRestrictionField(
              selectedAgeRestriction: _selectedAgeRestriction,
              onChanged: (value) {
                setState(() => _selectedAgeRestriction = value);
              },
            ),
            const SizedBox(height: 20),
            CreateEventButton(onPressed: _submit, text: 'Сохранить изменения'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
