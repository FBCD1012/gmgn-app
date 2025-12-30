import 'package:flutter/material.dart';
import 'theme.dart';

/// 下拉选择器
class GDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final double? width;

  const GDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        height: 32,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: GColors.bgElevated,
          borderRadius: BorderRadius.circular(GRadius.sm),
          border: Border.all(color: GColors.borderLight, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GTextStyle.caption,
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: GColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GRadius.xl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: GColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ...options.map((option) {
                final isSelected = option == value;
                return GestureDetector(
                  onTap: () {
                    onChanged(option);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    color: isSelected ? GColors.bgHover : Colors.transparent,
                    child: Row(
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 15,
                            color: isSelected ? GColors.green : GColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check, size: 18, color: GColors.green),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// 搜索框
class GSearchInput extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const GSearchInput({
    super.key,
    this.placeholder,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: GColors.bgInput,
        borderRadius: BorderRadius.circular(GRadius.md),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, size: 18, color: GColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GTextStyle.body,
              decoration: InputDecoration(
                hintText: placeholder ?? '搜索',
                hintStyle: GTextStyle.caption,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

/// 数值输入框
class GNumberInput extends StatelessWidget {
  final String value;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final double width;

  const GNumberInput({
    super.key,
    required this.value,
    this.suffix,
    this.onChanged,
    this.width = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: GColors.bgElevated,
        borderRadius: BorderRadius.circular(GRadius.sm),
        border: Border.all(color: GColors.borderLight, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            child: TextField(
              controller: TextEditingController(text: value),
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: GColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 4),
            Text(
              suffix!,
              style: GTextStyle.small,
            ),
          ],
        ],
      ),
    );
  }
}
