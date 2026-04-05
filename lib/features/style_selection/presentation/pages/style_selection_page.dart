import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/mixins/state_manager_listener_mixin.dart';
import 'package:yandex_dance/core/services/geo/city.dart';
import 'package:yandex_dance/core/services/geo/city_search_service.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/avatar_picker/avatar_picker.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/city_picker/city_picker_field.dart';
import 'package:yandex_dance/core/ui/widgets/dance_styles_selector/dance_styles_selector.dart';
import 'package:yandex_dance/core/ui/widgets/date_picker/date_of_birth_field.dart';
import 'package:yandex_dance/core/ui/widgets/date_picker/date_of_birth_picker.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/utils/validators.dart';
import 'package:yandex_dance/features/style_selection/presentation/managers/style_selection_manager.dart';
import 'package:yandex_dance/features/style_selection/presentation/state/style_selection_state.dart';

class StyleSelectionPage extends StatefulWidget {
  const StyleSelectionPage({super.key});

  @override
  State<StyleSelectionPage> createState() => _StyleSelectionPageState();
}

class _StyleSelectionPageState extends State<StyleSelectionPage>
    with StateManagerListenerMixin<StyleSelectionPage, StyleSelectionState> {
  late final StyleSelectionManager _manager;
  late final CitySearchService _citySearchService;

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  final _nameFocus = FocusNode();
  final _bioFocus = FocusNode();

  bool _nameTouched = false;
  bool _bioTouched = false;

  InputState _nameState = InputState.initial;
  InputState _bioState = InputState.initial;

  DateTime? _selectedDateOfBirth;
  City? _selectedCity;
  bool _cityError = false;

  @override
  Stream<StyleSelectionState> get stateStream => _manager.stream;

  @override
  String? errorMessageOf(StyleSelectionState state) => state.errorMessage;

  @override
  void initState() {
    super.initState();
    _manager = sl<StyleSelectionManager>();
    _citySearchService = sl<CitySearchService>();
    attachStateListener();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _nameFocus.dispose();
    _bioFocus.dispose();
    _manager.close();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDateOfBirthPicker(
      context: context,
      initialDate: _selectedDateOfBirth,
    );
    if (picked != null) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  void _submit() {
    if (_selectedCity == null) {
      setState(() => _cityError = true);
      return;
    }
    _manager.submit(
      displayName: _nameController.text,
      city: _selectedCity!.name,
      dateOfBirth: _selectedDateOfBirth,
      bio: _bioController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.gray500,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: StreamBuilder<StyleSelectionState>(
        stream: _manager.stream,
        initialData: _manager.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? _manager.state;

          return Scaffold(
            backgroundColor: AppColors.gray500,
            extendBodyBehindAppBar: true,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: MediaQuery.of(context).padding.top + 24,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    ShaderMask(
                      shaderCallback:
                          (bounds) => const LinearGradient(
                            colors: [AppColors.purple500, AppColors.pink500],
                          ).createShader(bounds),
                      child: Text(
                        'Расскажи\nо себе',
                        textAlign: TextAlign.center,
                        style: AppTextTheme.body3Regular20pt.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    AvatarPicker(
                      onTap: _manager.pickAvatar,
                      file: state.avatarFile,
                    ),

                    const SizedBox(height: 24),

                    // Name (required)
                    AppTextField(
                      hint: 'Имя *',
                      state: _nameState,
                      prefixIcon: AppIcons.user,
                      contoller: _nameController,
                      touched: _nameTouched,
                      focusNode: _nameFocus,
                      nextFocusNode: _bioFocus,
                      textInputAction: TextInputAction.next,
                      validator:
                          (v) => Validators.requiredText(v, field: 'Имя'),
                      onChanged: (_) => setState(() => _nameTouched = true),
                      onStateChange: (s) => setState(() => _nameState = s),
                    ),

                    const SizedBox(height: 16),

                    CityPickerField(
                      value: _selectedCity,
                      searchService: _citySearchService,
                      showError: _cityError && _selectedCity == null,
                      errorText: 'Выберите город из списка',
                      onChanged: (city) => setState(() {
                        _selectedCity = city;
                        _cityError = false;
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Bio (optional)
                    AppTextField(
                      hint: 'О себе',
                      state: _bioState,
                      contoller: _bioController,
                      touched: _bioTouched,
                      focusNode: _bioFocus,
                      isLongText: true,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() => _bioTouched = true),
                      onStateChange: (s) => setState(() => _bioState = s),
                    ),

                    const SizedBox(height: 16),

                    DateOfBirthField(
                      value: _selectedDateOfBirth,
                      onTap: _pickDateOfBirth,
                    ),

                    const SizedBox(height: 24),

                    Text('Стили танца *', style: AppTextTheme.body3Regular20pt),
                    const SizedBox(height: 4),
                    Text(
                      'Выбери направления, которые тебе ближе',
                      style: AppTextTheme.body2Regular14pt.copyWith(
                        color: AppColors.gray300,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DanceStylesSelector(
                      selectedStyles: state.selectedStyles,
                      onToggle: _manager.toggleStyle,
                    ),

                    const SizedBox(height: 32),

                    // Submit
                    AppButton(
                      label: 'Продолжить',
                      style: AppButtonStyle.gradientFilled,
                      needLoading: true,
                      onTap: state.isProcessing ? null : _submit,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

