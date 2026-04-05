import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yandex_dance/core/services/geo/city.dart';
import 'package:yandex_dance/core/services/geo/city_search_service.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/icons/app_icons.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';

class CityPickerField extends StatefulWidget {
  const CityPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.searchService,
    this.hint = 'Город *',
    this.showError = false,
    this.errorText,
  });

  final City? value;
  final ValueChanged<City?> onChanged;
  final CitySearchService searchService;
  final String hint;
  final bool showError;
  final String? errorText;

  @override
  State<CityPickerField> createState() => _CityPickerFieldState();
}

class _CityPickerFieldState extends State<CityPickerField> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  Timer? _debounce;
  int _requestId = 0;

  List<City> _results = const [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.name ?? '');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant CityPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final newText = widget.value?.name ?? '';
      if (newText != _controller.text) {
        _controller.text = newText;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
      }
      if (widget.value != null) {
        setState(() {
          _results = const [];
          _hasSearched = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _onTextChanged(String value) {
    final trimmed = value.trim();
    if (widget.value != null && trimmed != widget.value!.name) {
      widget.onChanged(null);
    }
    _debounce?.cancel();
    if (trimmed.length < 2) {
      setState(() {
        _results = const [];
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _search(trimmed),
    );
  }

  Future<void> _search(String query) async {
    final currentRequest = ++_requestId;
    final results = await widget.searchService.search(query);
    if (!mounted || currentRequest != _requestId) return;
    setState(() {
      _results = results;
      _isLoading = false;
      _hasSearched = true;
    });
  }

  void _select(City city) {
    _requestId++;
    _debounce?.cancel();
    _controller.text = city.name;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: city.name.length),
    );
    setState(() {
      _results = const [];
      _hasSearched = false;
      _isLoading = false;
    });
    _focusNode.unfocus();
    widget.onChanged(city);
  }

  void _clear() {
    _requestId++;
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _results = const [];
      _hasSearched = false;
      _isLoading = false;
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.showError
        ? AppColors.pink500
        : AppColors.gray300.withValues(alpha: 0.55);
    final showSuggestions = _focusNode.hasFocus &&
        (_isLoading || _results.isNotEmpty || _hasSearched);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gray400.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                AppIcons.pin,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.gray100,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onTextChanged,
                  cursorColor: AppColors.gray0,
                  style: AppTextTheme.body1Medium18pt.copyWith(
                    color: AppColors.gray0,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: AppTextTheme.body1Medium18pt.copyWith(
                      color: AppColors.gray100.withValues(alpha: 0.70),
                    ),
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _clear,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.gray300,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.showError &&
            widget.errorText != null &&
            widget.value == null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.errorText!,
              style: AppTextTheme.body2Regular14pt.copyWith(
                color: AppColors.pink500,
              ),
            ),
          ),
        ],
        if (showSuggestions) ...[
          const SizedBox(height: 8),
          _SuggestionsBox(
            isLoading: _isLoading,
            results: _results,
            onSelect: _select,
          ),
        ],
      ],
    );
  }
}

class _SuggestionsBox extends StatelessWidget {
  const _SuggestionsBox({
    required this.isLoading,
    required this.results,
    required this.onSelect,
  });

  final bool isLoading;
  final List<City> results;
  final ValueChanged<City> onSelect;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.gray400.withValues(alpha: 0.70),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.gray300.withValues(alpha: 0.55),
      ),
    );

    if (isLoading) {
      return Container(
        height: 56,
        decoration: decoration,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.purple500,
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Container(
        height: 56,
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          'Ничего не найдено',
          style: AppTextTheme.body2Regular14pt.copyWith(
            color: AppColors.gray300,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: results.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: AppColors.gray300.withValues(alpha: 0.15),
            indent: 16,
            endIndent: 16,
          ),
          itemBuilder: (_, i) {
            final city = results[i];
            return InkWell(
              onTap: () => onSelect(city),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.pin,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        AppColors.gray300,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            city.name,
                            style: AppTextTheme.body4Medium16pt.copyWith(
                              color: AppColors.gray0,
                            ),
                          ),
                          if (city.region != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              city.region!,
                              style: AppTextTheme.body2Regular14pt.copyWith(
                                color: AppColors.gray300,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
