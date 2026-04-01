import 'dart:async';

import 'package:yandex_dance/app/di/service_locator.dart';
import 'package:yandex_dance/core/enums/dance_style.dart';
import 'package:yandex_dance/features/style_selection/presentation/managers/style_selection_manager.dart';
import 'package:yandex_dance/features/style_selection/presentation/state/style_selection_state.dart';
import 'package:flutter/material.dart';

class StyleSelectionPage extends StatefulWidget {
  const StyleSelectionPage({super.key});

  @override
  State<StyleSelectionPage> createState() => _StyleSelectionPageState();
}

class _StyleSelectionPageState extends State<StyleSelectionPage> {
  late final StyleSelectionManager _manager;
  StreamSubscription<StyleSelectionState>? _subscription;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _manager = sl<StyleSelectionManager>();

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
    return StreamBuilder<StyleSelectionState>(
      stream: _manager.stream,
      initialData: _manager.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _manager.state;

        return Scaffold(
          appBar: AppBar(title: const Text('Выбери свои стили')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Какие направления тебе ближе?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Это поможет персонализировать профиль и события',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        DanceStyle.values.map((style) {
                          final isSelected = state.selectedStyles.contains(
                            style,
                          );

                          return FilterChip(
                            selected: isSelected,
                            label: Text(style.title),
                            onSelected: (_) => _manager.toggleStyle(style),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.isSaving ? null : _manager.submit,
                    child:
                        state.isSaving
                            ? const Text('Сохранение...')
                            : const Text('Продолжить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
