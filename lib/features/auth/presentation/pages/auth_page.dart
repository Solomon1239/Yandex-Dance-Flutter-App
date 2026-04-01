import 'dart:async';
import 'dart:io';

import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/utils/validators.dart';
import 'package:yandex_dance/features/auth/presentation/managers/auth_manager.dart';
import 'package:yandex_dance/features/auth/presentation/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../session/presentation/managers/app_session_manager.dart';
import '../../../session/presentation/state/app_session_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthManager _manager;
  StreamSubscription<AuthState>? _subscription;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AppSessionManager _sessionManager;
  StreamSubscription<AppSessionState>? _sessionSubscription;

  bool _obscureText = true;
  String? _lastError;

  void _handleSessionState(AppSessionState state) {
    if (!mounted) return;

    switch (state.status) {
      case AppSessionStatus.checking:
        break;
      case AppSessionStatus.guest:
        break;
      case AppSessionStatus.needsStyleSelection:
        context.go('/styles');
        break;
      case AppSessionStatus.authorized:
        context.go('/profile');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _manager = sl<AuthManager>();
    _sessionManager = sl<AppSessionManager>();

    _sessionSubscription = _sessionManager.stream.listen(_handleSessionState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleSessionState(_sessionManager.state);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _manager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _manager.stream,
      initialData: _manager.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _manager.state;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height - 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      state.mode == AuthMode.login
                          ? 'Welcome Back'
                          : 'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _manager.setMode(AuthMode.login),
                            child: const Text('Log In'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _manager.setMode(AuthMode.signUp),
                            child: const Text('Sign Up'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator:
                                    (value) => Validators.email(value ?? ''),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscureText,
                                validator:
                                    (value) => Validators.password(value ?? ''),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(
                                        () => _obscureText = !_obscureText,
                                      );
                                    },
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text('Forgot password?'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed:
                                      state.isLoading
                                          ? null
                                          : () {
                                            if (!_formKey.currentState!
                                                .validate()) {
                                              return;
                                            }

                                            _manager.submitEmail(
                                              email:
                                                  _emailController.text.trim(),
                                              password:
                                                  _passwordController.text,
                                            );
                                          },
                                  child:
                                      state.isLoading
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : Text(
                                            state.mode == AuthMode.login
                                                ? 'Войти'
                                                : 'Создать аккаунт',
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed:
                          state.isLoading ? null : _manager.signInWithGoogle,
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                    ),
                    if (Platform.isIOS) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed:
                            state.isLoading ? null : _manager.signInWithApple,
                        icon: const Icon(Icons.apple),
                        label: const Text('Continue with Apple'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
