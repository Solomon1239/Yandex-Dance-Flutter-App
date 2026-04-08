import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button.dart';
import 'package:yandex_dance/core/ui/widgets/custom_bounce_effect.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/app_button_style.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/utils/validators.dart';
import 'package:yandex_dance/features/auth/presentation/managers/auth_manager.dart';
import 'package:yandex_dance/features/auth/presentation/state/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthManager _manager;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;

  InputState _emailState = InputState.initial;
  InputState _passwordState = InputState.initial;
  InputState _confirmPasswordState = InputState.initial;

  @override
  void initState() {
    super.initState();
    _manager = sl<AuthManager>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _manager.close();
    super.dispose();
  }

  String? _confirmPasswordValidator(String value) {
    if (value.isEmpty) return 'Подтвердите пароль';
    if (value != _passwordController.text) return 'Пароли не совпадают';
    return null;
  }

  void _submit(AuthState state) {
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.password(_passwordController.text);

    bool hasError = false;

    if (emailError != null) {
      setState(() {
        _emailTouched = true;
        _emailState = InputState.error;
      });
      hasError = true;
    }

    if (passwordError != null) {
      setState(() {
        _passwordTouched = true;
        _passwordState = InputState.error;
      });
      hasError = true;
    }

    if (state.mode == AuthMode.signUp) {
      final confirmError = _confirmPasswordValidator(
        _confirmPasswordController.text,
      );
      if (confirmError != null) {
        setState(() {
          _confirmPasswordTouched = true;
          _confirmPasswordState = InputState.error;
        });
        hasError = true;
      }
    }

    if (hasError) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (state.mode == AuthMode.login) {
      _manager.signIn(email: email, password: password);
    } else {
      _manager.signUp(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _manager.stream,
      initialData: _manager.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _manager.state;
        final isLogin = state.mode == AuthMode.login;

        return Scaffold(
          backgroundColor: AppColors.gray500,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 64),

                  // Gradient title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.purple500, AppColors.pink500],
                    ).createShader(bounds),
                    child: Text(
                      'Заходи,\nпотанцуем!',
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

                  // Mode switcher
                  _AuthModeSwitcher(
                    isLogin: isLogin,
                    onLoginTap: () => _manager.setMode(AuthMode.login),
                    onSignUpTap: () => _manager.setMode(AuthMode.signUp),
                  ),

                  const SizedBox(height: 24),

                  // Email
                  AppTextField(
                    hint: 'Email',
                    state: _emailState,
                    prefixIcon: AppIcons.mail,
                    contoller: _emailController,
                    touched: _emailTouched,
                    focusNode: _emailFocus,
                    nextFocusNode: _passwordFocus,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    onChanged: (_) => setState(() => _emailTouched = true),
                    onStateChange: (s) => setState(() => _emailState = s),
                  ),

                  const SizedBox(height: 16),

                  // Password
                  AppTextField(
                    hint: 'Пароль',
                    state: _passwordState,
                    isPassword: true,
                    prefixIcon: AppIcons.lock,
                    contoller: _passwordController,
                    touched: _passwordTouched,
                    focusNode: _passwordFocus,
                    nextFocusNode:
                        isLogin ? null : _confirmPasswordFocus,
                    autofillHints: [
                      isLogin
                          ? AutofillHints.password
                          : AutofillHints.newPassword,
                    ],
                    textInputAction:
                        isLogin
                            ? TextInputAction.done
                            : TextInputAction.next,
                    validator: Validators.password,
                    onChanged: (_) => setState(() => _passwordTouched = true),
                    onStateChange: (s) => setState(() => _passwordState = s),
                    onSubmitted:
                        isLogin ? (_) => _submit(state) : null,
                  ),

                  // Confirm password (sign up only, animated)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: isLogin ? 0.0 : 1.0,
                      child:
                          isLogin
                              ? const SizedBox.shrink()
                              : Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: AppTextField(
                                  hint: 'Подтверждение пароля',
                                  state: _confirmPasswordState,
                                  isPassword: true,
                                  prefixIcon: AppIcons.lock,
                                  contoller: _confirmPasswordController,
                                  touched: _confirmPasswordTouched,
                                  focusNode: _confirmPasswordFocus,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  textInputAction: TextInputAction.done,
                                  validator: _confirmPasswordValidator,
                                  onChanged:
                                      (_) => setState(
                                        () => _confirmPasswordTouched = true,
                                      ),
                                  onStateChange:
                                      (s) => setState(
                                        () => _confirmPasswordState = s,
                                      ),
                                  onSubmitted: (_) => _submit(state),
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Error message
                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: AppTextTheme.body2Regular14pt.copyWith(
                        color: AppColors.pink500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Submit button
                  AppButton(
                    label: isLogin ? 'Войти' : 'Создать аккаунт',
                    style: AppButtonStyle.gradientFilled,
                    needLoading: true,
                    onTap:
                        state.isLoading ? null : () => _submit(state),
                  ),

                  const SizedBox(height: 24),

                  // OR divider
                  const _OrDivider(),

                  const SizedBox(height: 24),

                  // Google button
                  AppButton(
                    label: 'Войти с помощью Google',
                    iconWidget: SvgPicture.asset(
                      AppIcons.googleColored,
                      width: 24,
                      height: 24,
                    ),
                    style: AppButtonStyle.outlined,
                    onTap:
                        state.isLoading
                            ? null
                            : _manager.signInWithGoogle,
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────

class _AuthModeSwitcher extends StatelessWidget {
  const _AuthModeSwitcher({
    required this.isLogin,
    required this.onLoginTap,
    required this.onSignUpTap,
  });

  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.gray400,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;
          return Stack(
            children: [
              // Sliding gradient indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: isLogin ? 0 : tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [AppColors.purple500, AppColors.pink500],
                    ),
                  ),
                ),
              ),
              // Labels
              Row(
                children: [
                  Expanded(
                    child: CustomBounceEffect(
                      onTap: onLoginTap,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          style: AppTextTheme.body4Medium16pt.copyWith(
                            color:
                                isLogin ? AppColors.gray0 : AppColors.gray300,
                          ),
                          child: const Text('Войти'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomBounceEffect(
                      onTap: onSignUpTap,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          style: AppTextTheme.body4Medium16pt.copyWith(
                            color:
                                isLogin ? AppColors.gray300 : AppColors.gray0,
                          ),
                          child: const Text('Регистрация'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.gray400)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ИЛИ',
            style: AppTextTheme.body2Regular14pt.copyWith(
              color: AppColors.gray300,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.gray400)),
      ],
    );
  }
}

