import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../components/components.dart';

class AppFilters extends StatefulWidget {
  const AppFilters({super.key});

  @override
  State<AppFilters> createState() => _AppFiltersState();
}

class _AppFiltersState extends State<AppFilters> {
  String _platform = '多平台';
  String _time = '24h';
  String _sort = '市值排序';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GSpacing.xl, vertical: GSpacing.md),
      child: Row(
        children: [
          // 筛选图标
          _FilterIcon(),
          const Gap(GSpacing.md),
          // 筛选下拉菜单
          _FilterDropdown(
            value: _platform,
            options: const ['多平台', 'Pump', 'Raydium', 'PancakeSwap'],
            onChanged: (v) => setState(() => _platform = v),
          ),
          const Gap(GSpacing.md),
          _FilterDropdown(
            value: _time,
            options: const ['1h', '6h', '24h', '7d'],
            onChanged: (v) => setState(() => _time = v),
          ),
          const Gap(GSpacing.md),
          _FilterDropdown(
            value: _sort,
            icon: Icons.arrow_downward,
            options: const ['市值排序', '交易量', '涨跌幅', '持有人'],
            onChanged: (v) => setState(() => _sort = v),
          ),
        ],
      ),
    );
  }
}

class _FilterIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: GColors.bgElevated,
        borderRadius: BorderRadius.zero, // 尖角矩形
        border: Border.all(color: GColors.borderLight, width: 1),
      ),
      child: const Icon(
        Icons.filter_list,
        size: 18,
        color: GColors.textSecondary,
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final IconData? icon;

  const _FilterDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: GColors.bgElevated,
          borderRadius: BorderRadius.zero, // 尖角矩形
          border: Border.all(color: GColors.borderLight, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: GColors.textSecondary),
              const Gap(4),
            ],
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: GColors.textPrimary,
              ),
            ),
            const Gap(4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
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
              const Gap(16),
            ],
          ),
        );
      },
    );
  }
}
