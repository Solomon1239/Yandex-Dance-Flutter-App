import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/widgets/buttons/base_button.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/input/app_text_field.dart';
import 'package:yandex_dance/core/ui/widgets/switcher/switcher.dart';

class InputDebugPage extends StatefulWidget {
  const InputDebugPage({super.key});

  @override
  State<InputDebugPage> createState() => _InputDebugPageState();
}

class _InputDebugPageState extends State<InputDebugPage> {
  final _searchController = TextEditingController();
  final _simpleController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _searchFocusNode = FocusNode();
  final _simpleFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _touched = false;

  @override
  void dispose() {
    _searchController.dispose();
    _simpleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _searchFocusNode.dispose();
    _simpleFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Debug')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Simple',
              hint: 'Найти',
              state: InputState.initial,
              prefixIcon: AppIcons.search,
              contoller: _simpleController,
              focusNode: _simpleFocusNode,
              touched: _touched,
              onChanged: (_) => setState(() => _touched = true),
              onFocusChange: () => setState(() => _touched = true),
              onUnfocus: () => setState(() => _touched = true),
              nextFocusNode: _emailFocusNode,
            ),
            const SizedBox(height: 12),

            CupertinoSlidingSegmentedControl<int>(
              groupValue: 0,
              children: {0: Text('Войти'), 1: Text('Регистрация')},
              onValueChanged: (value) {},
            ),
            AppSegmentedControl(
              expandItems: true,
              height: 50,
              horizontalPadding: 0,
              itemPadding: EdgeInsets.symmetric(horizontal: 0),
              items: [
                Text('Войти', style: AppTextTheme.body3Regular20pt),
                Text('Регистрация', style: AppTextTheme.body3Regular20pt),
              ],
              onChanged: (index) {},
            ),
            SizedBox(height: 20),
            AppSegmentedControl(
              height: 30,
              itemPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              items: [
                SvgPicture.asset(AppIcons.list, width: 20),
                SvgPicture.asset(AppIcons.map, width: 20),
              ],
              onChanged: (index) {},
              horizontalPadding: 0,
            ),
          ],
        ),
      ),
    );
  }
}
