import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
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
import 'package:yandex_dance/core/ui/widgets/custom_bounce_effect.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/utils/validators.dart';
import 'package:yandex_dance/features/profile/presentation/managers/edit_profile_manager.dart';
import 'package:yandex_dance/features/profile/presentation/state/edit_profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with StateManagerListenerMixin<EditProfilePage, EditProfileState> {
  late final EditProfileManager _manager;
  late final CitySearchService _citySearchService;

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  final _nameFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _bioFocus = FocusNode();

  bool _nameTouched = false;
  bool _bioTouched = false;

  InputState _nameState = InputState.initial;
  InputState _bioState = InputState.initial;

  City? _selectedCity;
  bool _cityError = false;
  DateTime? _selectedDateOfBirth;
  List<DanceStyle> _selectedStyles = const [];

  bool _initialized = false;

  @override
  Stream<EditProfileState> get stateStream => _manager.stream;

  @override
  String? errorMessageOf(EditProfileState state) => state.errorMessage;

  @override
  String? successMessageOf(EditProfileState state) => state.successMessage;

  @override
  void onStateChange(EditProfileState state) {
    final profile = state.profile;
    if (profile != null && !_initialized) {
      _initialized = true;
      _nameController.text = profile.displayName ?? '';
      _bioController.text = profile.bio ?? '';
      if ((profile.city ?? '').isNotEmpty) {
        _selectedCity = City(name: profile.city!, fiasId: '');
      }
      setState(() {
        _selectedDateOfBirth = profile.dateOfBirth;
        _selectedStyles = List<DanceStyle>.from(profile.danceStyles);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _manager = sl<EditProfileManager>()..load();
    _citySearchService = sl<CitySearchService>();
    attachStateListener();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _nameFocus.dispose();
    _cityFocus.dispose();
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

  void _toggleStyle(DanceStyle style) {
    setState(() {
      if (_selectedStyles.contains(style)) {
        _selectedStyles = _selectedStyles.where((s) => s != style).toList();
      } else {
        _selectedStyles = [..._selectedStyles, style];
      }
    });
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameTouched = true;
        _nameState = InputState.error;
      });
      return;
    }
    if (_selectedCity == null) {
      setState(() => _cityError = true);
      return;
    }
    _manager.saveBasicInfo(
      displayName: _nameController.text,
      bio: _bioController.text,
      city: _selectedCity!.name,
      dateOfBirth: _selectedDateOfBirth,
      danceStyles: _selectedStyles,
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
      child: StreamBuilder<EditProfileState>(
        stream: _manager.stream,
        initialData: _manager.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? _manager.state;

          if (state.isLoading) {
            return const Scaffold(
              backgroundColor: AppColors.gray500,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.purple500),
              ),
            );
          }

          final profile = state.profile;
          if (profile == null) {
            return const Scaffold(
              backgroundColor: AppColors.gray500,
              body: Center(child: Text('Профиль не найден')),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.gray500,
            body: CustomBounceEffect(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppButton(
                        onTap: () => Navigator.of(context).pop(),
                        iconWidget: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.gray0,
                          size: 26,
                        ),
                        style: const AppButtonStyle(
                          width: 48,
                          height: 48,
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback:
                          (bounds) => const LinearGradient(
                            colors: [AppColors.purple500, AppColors.pink500],
                          ).createShader(bounds),
                      child: Text(
                        'Редактировать\nпрофиль',
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
                      onTap: _manager.pickAndUploadAvatar,
                      networkImageUrl: profile.avatarThumbUrl,
                    ),

                    const SizedBox(height: 24),

                    AppTextField(
                      hint: 'Имя *',
                      state: _nameState,
                      prefixIcon: AppIcons.user,
                      contoller: _nameController,
                      touched: _nameTouched,
                      focusNode: _nameFocus,
                      nextFocusNode: _cityFocus,
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
                      focusNode: _cityFocus,
                      nextFocusNode: _bioFocus,
                      showError: _cityError && _selectedCity == null,
                      errorText: 'Выберите город из списка',
                      onChanged:
                          (city) => setState(() {
                            _selectedCity = city;
                            _cityError = false;
                          }),
                    ),

                    const SizedBox(height: 16),

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

                    Text('Стили танца', style: AppTextTheme.body3Regular20pt),
                    const SizedBox(height: 4),
                    Text(
                      'Выбери направления, которые тебе ближе',
                      style: AppTextTheme.body2Regular14pt.copyWith(
                        color: AppColors.gray300,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DanceStylesSelector(
                      selectedStyles: _selectedStyles,
                      onToggle: _toggleStyle,
                    ),

                    const SizedBox(height: 32),

                    AppButton(
                      label: 'Сохранить',
                      style: AppButtonStyle.gradientFilled,
                      needLoading: true,
                      onTap: state.isSaving ? null : _submit,
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
