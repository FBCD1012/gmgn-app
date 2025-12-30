import 'package:flutter/material.dart';
import 'theme.dart';

enum GButtonVariant { primary, secondary, outline, ghost }
enum GButtonSize { sm, md, lg }

/// 通用按钮组件
class GButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final IconData? icon;
  final GButtonVariant variant;
  final GButtonSize size;
  final VoidCallback? onTap;
  final bool disabled;
  final Color? color;

  const GButton({
    super.key,
    this.text,
    this.child,
    this.icon,
    this.variant = GButtonVariant.primary,
    this.size = GButtonSize.md,
    this.onTap,
    this.disabled = false,
    this.color,
  });

  /// 快速构造 - 主按钮
  const GButton.primary({
    super.key,
    this.text,
    this.child,
    this.icon,
    this.onTap,
    this.disabled = false,
    this.color,
  })  : variant = GButtonVariant.primary,
        size = GButtonSize.md;

  /// 快速构造 - 边框按钮
  const GButton.outline({
    super.key,
    this.text,
    this.child,
    this.icon,
    this.onTap,
    this.disabled = false,
    this.color,
  })  : variant = GButtonVariant.outline,
        size = GButtonSize.md;

  /// 快速构造 - 幽灵按钮
  const GButton.ghost({
    super.key,
    this.text,
    this.child,
    this.icon,
    this.onTap,
    this.disabled = false,
    this.color,
  })  : variant = GButtonVariant.ghost,
        size = GButtonSize.md;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? GColors.green;

    // Size dimensions
    final double height;
    final double fontSize;
    final double iconSize;
    final EdgeInsets padding;

    switch (size) {
      case GButtonSize.sm:
        height = 28;
        fontSize = 12;
        iconSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 10);
        break;
      case GButtonSize.md:
        height = 36;
        fontSize = 14;
        iconSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 14);
        break;
      case GButtonSize.lg:
        height = 44;
        fontSize = 15;
        iconSize = 18;
        padding = const EdgeInsets.symmetric(horizontal: 18);
        break;
    }

    // Variant styles
    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (variant) {
      case GButtonVariant.primary:
        bgColor = effectiveColor;
        textColor = Colors.black;
        borderColor = Colors.transparent;
        break;
      case GButtonVariant.secondary:
        bgColor = GColors.bgElevated;
        textColor = GColors.textPrimary;
        borderColor = GColors.borderLight;
        break;
      case GButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = effectiveColor;
        borderColor = effectiveColor;
        break;
      case GButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = GColors.textSecondary;
        borderColor = Colors.transparent;
        break;
    }

    if (disabled) {
      bgColor = bgColor.withAlpha(128);
      textColor = textColor.withAlpha(128);
    }

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(GRadius.md),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: textColor),
              if (text != null || child != null) const SizedBox(width: 4),
            ],
            if (child != null)
              child!
            else if (text != null)
              Text(
                text!,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 图标按钮
class GIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final Color? bgColor;
  final bool hasBorder;

  const GIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 36,
    this.color,
    this.bgColor,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor ?? GColors.bgElevated,
          borderRadius: BorderRadius.circular(GRadius.md),
          border: hasBorder ? Border.all(color: GColors.borderLight, width: 1) : null,
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: color ?? GColors.textSecondary,
        ),
      ),
    );
  }
}
