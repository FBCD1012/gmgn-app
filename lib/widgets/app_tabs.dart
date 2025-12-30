import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../components/components.dart';

class AppTabs extends StatefulWidget {
  const AppTabs({super.key});

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  int _selectedMainTab = 1;
  int _selectedChain = 2; // BSC 默认选中

  final _mainTabs = ['收藏', '热门', '战壕', '新币'];
  final _chains = ['推荐', 'SOL', 'BSC', 'MONAD', 'BA'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 主Tab行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GSpacing.xl),
          child: Row(
            children: List.generate(_mainTabs.length, (i) => Padding(
              padding: EdgeInsets.only(right: i < _mainTabs.length - 1 ? GSpacing.xxxl : 0),
              child: _MainTab(
                label: _mainTabs[i],
                selected: _selectedMainTab == i,
                onTap: () => setState(() => _selectedMainTab = i),
              ),
            )),
          ),
        ),
        const Gap(GSpacing.xl),
        // 链选择行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GSpacing.xl),
          child: Row(
            children: [
              // 推荐 chip (带图标) - 尖角矩形
              GestureDetector(
                onTap: () => setState(() => _selectedChain = 0),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _selectedChain == 0 ? GColors.green : GColors.bgElevated,
                    borderRadius: BorderRadius.zero, // 尖角矩形
                    border: Border.all(
                      color: _selectedChain == 0 ? GColors.green : GColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('🐰', style: TextStyle(fontSize: 14)),
                      const Gap(4),
                      Text(
                        '推荐',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _selectedChain == 0 ? Colors.black : GColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(GSpacing.md),
              // 链 chips
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_chains.length - 1, (i) => Padding(
                      padding: const EdgeInsets.only(right: GSpacing.md),
                      child: GChainChip(
                        chain: _chains[i + 1],
                        selected: _selectedChain == i + 1,
                        onTap: () => setState(() => _selectedChain = i + 1),
                      ),
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(GSpacing.lg),
      ],
    );
  }
}

class _MainTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MainTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? GColors.textPrimary : GColors.textSecondary,
            ),
          ),
          const Gap(GSpacing.md),
          Container(
            height: 2,
            width: 20,
            decoration: BoxDecoration(
              color: selected ? GColors.textPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
