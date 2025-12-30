import 'package:flutter/material.dart';
import 'theme.dart';

/// 通用卡片组件
class GCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Color? borderColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool flat; // 无圆角无边框的扁平样式

  const GCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.flat = false,
  });

  /// 扁平列表项样式 (无圆角，只有底部边框)
  const GCard.flat({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.onTap,
  }) : flat = true;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(GSpacing.lg),
      margin: margin ?? (flat
          ? const EdgeInsets.symmetric(horizontal: GSpacing.lg)
          : const EdgeInsets.symmetric(horizontal: GSpacing.lg, vertical: GSpacing.xs)),
      decoration: flat
          ? BoxDecoration(
              color: color ?? Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: borderColor ?? const Color(0xFF1A1A1A),
                  width: 1,
                ),
              ),
            )
          : BoxDecoration(
              color: color ?? const Color(0xFF000000),
              borderRadius: BorderRadius.circular(borderRadius ?? GRadius.lg),
              border: Border.all(
                color: borderColor ?? const Color(0xFF1A1A1A),
                width: 1,
              ),
            ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}

/// 列表项卡片
class GListCard extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const GListCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GCard(
      onTap: onTap,
      child: Row(
        children: [
          leading,
          const SizedBox(width: GSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: GSpacing.xs),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: GSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}
