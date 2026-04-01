import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/profile/presentation/managers/profile_manager.dart';
import 'package:yandex_dance/features/profile/presentation/state/profile_state.dart';
import 'package:yandex_dance/core/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileManager _manager;
  StreamSubscription<ProfileState>? _subscription;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _manager = sl<ProfileManager>()..start();

    _subscription = _manager.stream.listen((state) {
      if (!mounted) return;
      if (state.errorMessage != null &&
          state.errorMessage!.isNotEmpty &&
          state.errorMessage != _lastError) {
        _lastError = state.errorMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _manager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileState>(
      stream: _manager.stream,
      initialData: _manager.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _manager.state;

        switch (state.status) {
          case ProfileStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

          case ProfileStatus.error:
            return Scaffold(
              appBar: AppBar(title: const Text('Профиль')),
              body: Center(child: Text(state.errorMessage ?? 'Ошибка')),
            );

          case ProfileStatus.ready:
            final profile = state.profile!;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Профиль'),
                actions: [
                  IconButton(
                    onPressed: () => context.push('/profile/edit'),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: _manager.signOut,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.displayName ?? 'Без имени',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  if (profile.city != null &&
                                      profile.city!.isNotEmpty)
                                    Text(profile.city!),
                                  const SizedBox(height: 8),
                                  Text(
                                    profile.rating != null
                                        ? 'Рейтинг: ${profile.rating}'
                                        : 'Рейтинг появится позже',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SectionTitle('О себе'),
                    const SizedBox(height: 8),
                    Text(
                      profile.bio?.isNotEmpty == true
                          ? profile.bio!
                          : 'Пока без описания',
                    ),
                    const SizedBox(height: 24),
                    const SectionTitle('Стили'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          profile.danceStyles
                              .map((style) => Chip(label: Text(style.title)))
                              .toList(),
                    ),
                    const SizedBox(height: 24),
                    const SectionTitle('Видео'),
                    const SizedBox(height: 8),
                    if (profile.introVideoThumbUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: profile.introVideoThumbUrl!,
                          fit: BoxFit.cover,
                          height: 220,
                          width: double.infinity,
                        ),
                      )
                    else
                      const Text('Видео пока не добавлено'),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.push('/profile/edit'),
                      child: const Text('Редактировать профиль'),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
