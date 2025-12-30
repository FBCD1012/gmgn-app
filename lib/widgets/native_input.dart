import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

class NativeInput extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;
  final double? fontSize;

  const NativeInput({
    super.key,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
    this.fontSize,
  });

  @override
  State<NativeInput> createState() => _NativeInputState();
}

class _NativeInputState extends State<NativeInput> {
  late html.InputElement _inputElement;
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'native-input-${DateTime.now().millisecondsSinceEpoch}';

    _inputElement = html.InputElement()
      ..type = _getInputType()
      ..placeholder = widget.hintText ?? ''
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.outline = 'none'
      ..style.backgroundColor = _colorToRgba(widget.backgroundColor ?? const Color(0xFF252525))
      ..style.color = _colorToRgba(widget.textColor ?? Colors.white)
      ..style.fontSize = '${widget.fontSize ?? 15}px'
      ..style.padding = '0'
      ..style.fontFamily = 'SF Pro Display, -apple-system, BlinkMacSystemFont, sans-serif';

    // Set placeholder color via CSS
    final hintColorRgba = _colorToRgba(widget.hintColor ?? Colors.grey.shade600);
    final currentCss = _inputElement.style.cssText ?? '';
    _inputElement.style.cssText = currentCss + '''
      &::placeholder {
        color: $hintColorRgba;
      }
    ''';

    // Sync controller value
    if (widget.controller != null) {
      _inputElement.value = widget.controller!.text;
      widget.controller!.addListener(_syncToHtml);
    }

    // Listen to changes
    _inputElement.onInput.listen((event) {
      if (widget.controller != null) {
        widget.controller!.value = TextEditingValue(
          text: _inputElement.value ?? '',
          selection: TextSelection.collapsed(offset: _inputElement.value?.length ?? 0),
        );
      }
      widget.onChanged?.call(_inputElement.value ?? '');
    });

    // Listen to Enter key
    _inputElement.onKeyDown.listen((event) {
      if (event.key == 'Enter') {
        widget.onEditingComplete?.call();
      }
    });

    // Register view
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _inputElement,
    );
  }

  void _syncToHtml() {
    if (widget.controller != null && _inputElement.value != widget.controller!.text) {
      _inputElement.value = widget.controller!.text;
    }
  }

  String _getInputType() {
    if (widget.keyboardType == TextInputType.number ||
        widget.keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
      return 'number';
    }
    if (widget.keyboardType == TextInputType.emailAddress) {
      return 'email';
    }
    if (widget.keyboardType == TextInputType.phone) {
      return 'tel';
    }
    return 'text';
  }

  String _colorToRgba(Color color) {
    return 'rgba(${color.red}, ${color.green}, ${color.blue}, ${color.opacity})';
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_syncToHtml);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
