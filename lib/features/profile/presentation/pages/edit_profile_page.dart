import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/utils/validators.dart';
import 'package:yandex_dance/features/profile/presentation/managers/edit_profile_manager.dart';
import 'package:yandex_dance/features/profile/presentation/state/edit_profile_state.dart';
import 'package:yandex_dance/core/widgets/section_title.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final EditProfileManager _manager;
  StreamSubscription<EditProfileState>? _subscription;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _ageController = TextEditingController();

  String? _lastError;
  String? _lastSuccess;

  @override
  void initState() {
    super.initState();
    _manager = sl<EditProfileManager>()..load();

    _subscription = _manager.stream.listen((state) {
      if (!mounted) return;

      final profile = state.profile;
      if (profile != null && _nameController.text.isEmpty) {
        _nameController.text = profile.displayName ?? '';
        _bioController.text = profile.bio ?? '';
        _cityController.text = profile.city ?? '';
        _ageController.text = profile.age?.toString() ?? '';
      }

      if (state.errorMessage != null &&
          state.errorMessage!.isNotEmpty &&
          state.errorMessage != _lastError) {
        _lastError = state.errorMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      }

      if (state.successMessage != null &&
          state.successMessage!.isNotEmpty &&
          state.successMessage != _lastSuccess) {
        _lastSuccess = state.successMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    _manager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EditProfileState>(
      stream: _manager.stream,
      initialData: _manager.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _manager.state;

        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = state.profile;
        if (profile == null) {
          return const Scaffold(body: Center(child: Text('Профиль не найден')));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Редактировать профиль')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Аватар'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            profile.avatarThumbUrl != null
                                ? CachedNetworkImageProvider(
                                  profile.avatarThumbUrl!,
                                )
                                : null,
                        child:
                            profile.avatarThumbUrl == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed:
                            state.isUploadingAvatar
                                ? null
                                : _manager.pickAndUploadAvatar,
                        child:
                            state.isUploadingAvatar
                                ? const Text('Загрузка...')
                                : const Text('Загрузить фото'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle('Видео'),
                  const SizedBox(height: 12),
                  if (profile.introVideoThumbUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: profile.introVideoThumbUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const Text('Видео пока не добавлено'),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed:
                        state.isUploadingVideo
                            ? null
                            : _manager.pickAndUploadIntroVideo,
                    child:
                        state.isUploadingVideo
                            ? const Text('Загрузка...')
                            : const Text('Загрузить видео'),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle('Основная информация'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    validator:
                        (value) =>
                            Validators.requiredText(value ?? '', field: 'Имя'),
                    decoration: const InputDecoration(labelText: 'Имя'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Описание'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Город'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.age(value ?? ''),
                    decoration: const InputDecoration(labelText: 'Возраст'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          state.isSaving
                              ? null
                              : () {
                                if (!_formKey.currentState!.validate()) return;

                                _manager.saveBasicInfo(
                                  displayName: _nameController.text,
                                  bio: _bioController.text,
                                  city: _cityController.text,
                                  ageText: _ageController.text,
                                );
                              },
                      child:
                          state.isSaving
                              ? const Text('Сохранение...')
                              : const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
