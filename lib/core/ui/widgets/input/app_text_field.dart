import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/colors/input_color.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/input/text_field_suffix_icon.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hint,
    required this.state,
    this.isPassword = false,
    this.prefixIcon,
    this.onChanged,
    this.onStateChange,
    required this.contoller,
    this.validator,
    this.onValidateExternally,
    this.onFocusChange,
    this.onUnfocus,
    required this.touched,
    required this.focusNode,
    this.nextFocusNode,
    this.isReadOnly,
    this.onTap,
    this.isLongText,
    this.isNumber,
    this.inputFormatters,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.textStyle,
    this.hintStyle,
  });

  final String hint;
  final InputState state;
  final bool isPassword;
  final String? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<InputState>? onStateChange;
  final TextEditingController contoller;
  final String? Function(String)? validator;
  final void Function()? onValidateExternally;
  final VoidCallback? onFocusChange;
  final VoidCallback? onUnfocus;
  final bool touched;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final bool? isReadOnly;
  final VoidCallback? onTap;
  final bool? isLongText;
  final bool? isNumber;
  final TextInputFormatter? inputFormatters;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  @override
  State<AppTextField> createState() => AppTextFieldState();
}

class AppTextFieldState extends State<AppTextField> {
  bool _isObscured = true;
  late InputState _currentState;
  late VoidCallback _focusListener;

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final text = widget.contoller.text;

    if (oldWidget.contoller.text != text) {
      if (widget.validator != null) {
        final error = widget.validator!(text);
        _currentState = error == null ? InputState.success : InputState.error;
      } else {
        _currentState =
            text.isNotEmpty ? InputState.filled : InputState.initial;
      }

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _currentState = widget.state;

    _focusListener = () {
      if (!mounted) return;

      if (widget.focusNode.hasFocus) {
        setState(() => _currentState = InputState.typing);
        widget.onStateChange?.call(InputState.typing);
        widget.onFocusChange?.call();
      } else {
        widget.onUnfocus?.call();

        final text = widget.contoller.text;

        if (widget.validator != null) {
          final error = widget.validator!(text);
          _currentState = error == null ? InputState.success : InputState.error;
        } else {
          _currentState =
              text.isNotEmpty ? InputState.filled : InputState.initial;
        }

        setState(() {});
        widget.onStateChange?.call(_currentState);
      }
    };
    widget.focusNode.addListener(_focusListener);
    _isObscured = widget.isPassword;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusListener);
    super.dispose();
  }

  bool validateExternally() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.contoller.text);
      setState(() {
        _currentState = error == null ? InputState.success : InputState.error;
      });
      widget.onStateChange?.call(_currentState);
      return error == null;
    }
    return true;
  }

  void updateState(InputState newState) {
    setState(() {
      _currentState = newState;
    });
    widget.onStateChange?.call(newState);
  }

  @override
  Widget build(BuildContext context) {
    final resolver = InputColorResolver(state: _currentState, context: context);
    final radius = BorderRadius.circular(20);
    final borderColor =
        _currentState == InputState.typing
            ? resolver.textColor
            : AppColors.gray300;
    final errorText =
        !widget.focusNode.hasFocus &&
                _currentState == InputState.error &&
                widget.touched &&
                widget.validator != null
            ? widget.validator!(widget.contoller.text)
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: AppColors.gray400.withValues(alpha: 0.70),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: TextFormField(
              inputFormatters:
                  widget.isNumber == true
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
                      : [],
              maxLines: widget.isLongText == true ? null : 1,
              keyboardType:
                  widget.keyboardType ??
                  (widget.isNumber == true ? TextInputType.phone : null),
              autofillHints: widget.autofillHints,
              textInputAction: widget.textInputAction,
              onTap: widget.onTap,
              readOnly: widget.isReadOnly ?? false,
              controller: widget.contoller,
              focusNode: widget.focusNode,
              obscureText: widget.isPassword ? _isObscured : false,
              obscuringCharacter: '*',
              cursorColor: resolver.cursorColor,
              cursorHeight: 20,
              cursorWidth: 1,
              onChanged: (value) {
                widget.onChanged?.call(value);

                if (widget.validator != null) {
                  final error = widget.validator!(value);

                  final newState =
                      error == null ? InputState.success : InputState.error;

                  widget.onStateChange?.call(newState);
                }
              },
              style: AppTextTheme.body1Medium18pt
                  .copyWith(color: resolver.textColor)
                  .merge(widget.textStyle),
              onFieldSubmitted: (_) {
                widget.onSubmitted?.call(widget.contoller.text);
                if (widget.onValidateExternally != null) {
                  widget.onValidateExternally!();
                }
                if (widget.nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(widget.nextFocusNode);
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 52,
                  minHeight: 52,
                ),
                prefixIcon:
                    widget.prefixIcon == null
                        ? null
                        : Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 10),
                            child: SvgPicture.asset(
                              widget.prefixIcon!,
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                AppColors.gray100,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 52,
                  minHeight: 52,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 12),
                  child: TextFieldSuffixIcon(
                    isPassword: widget.isPassword,
                    isObscured: _isObscured,
                    currentState: _currentState,
                    onToggleObscure: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
                hintText: widget.hint,
                hintStyle: AppTextTheme.body1Medium18pt
                    .copyWith(color: AppColors.gray100.withValues(alpha: 0.70))
                    .merge(widget.hintStyle),
                labelStyle: AppTextTheme.body2Regular14pt.copyWith(
                  color: AppColors.gray100,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              errorText,
              style: AppTextTheme.body2Regular14pt.copyWith(
                color: AppColors.inputTextNegative,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
