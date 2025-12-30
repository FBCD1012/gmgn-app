import 'package:flutter/material.dart';
import 'theme.dart';

/// 标签/芯片组件
class GChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? activeColor;
  final Widget? leading;

  const GChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.activeColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? GColors.green;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? color : GColors.bgInput,
          borderRadius: BorderRadius.circular(GRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.black : GColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 标签组件 (小号，用于显示状态)
class GTag extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const GTag({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });

  /// 成功标签
  const GTag.success({super.key, required this.label, this.icon}) : color = GColors.green;

  /// 错误标签
  const GTag.error({super.key, required this.label, this.icon}) : color = GColors.red;

  /// 警告标签
  const GTag.warning({super.key, required this.label, this.icon}) : color = GColors.yellow;

  /// 中性标签
  const GTag.neutral({super.key, required this.label, this.icon}) : color = null;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? GColors.textTertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: effectiveColor.withAlpha(30),
        borderRadius: BorderRadius.circular(GRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: effectiveColor),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 链芯片组件 - 选中时使用链的专属颜色，尖角矩形
class GChainChip extends StatelessWidget {
  final String chain;
  final bool selected;
  final VoidCallback? onTap;

  const GChainChip({
    super.key,
    required this.chain,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color chainColor;
    String chainIcon;

    switch (chain.toUpperCase()) {
      case 'SOL':
      case 'SOLANA':
        chainColor = GColors.solana;
        chainIcon = '◎';
        break;
      case 'BSC':
        chainColor = GColors.bsc;
        chainIcon = '◆';
        break;
      case 'BASE':
        chainColor = GColors.base;
        chainIcon = '●';
        break;
      case 'MONAD':
        chainColor = GColors.monad;
        chainIcon = '●';
        break;
      default:
        chainColor = GColors.textSecondary;
        chainIcon = '●';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? chainColor : GColors.bgElevated,
          borderRadius: BorderRadius.zero, // 尖角矩形
          border: Border.all(
            color: selected ? chainColor : GColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              chainIcon,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.black : chainColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              chain,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.black : GColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
