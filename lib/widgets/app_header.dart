import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../components/components.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GSpacing.lg, vertical: GSpacing.lg),
      child: Row(
        children: [
          // Logo头像
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GRadius.md),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D5A3D), Color(0xFF1A3D2A)],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GRadius.md),
              child: Image.network(
                'https://pump.mypinata.cloud/ipfs/QmeSzchzEPqCU1jwTnsLjLsBgE6r6bVP9wEL8FfwXkh6mg?img-width=128&img-dpr=2',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.pets, color: Colors.white, size: 20),
              ),
            ),
          ),
          const Gap(GSpacing.lg),
          // 搜索框
          const Expanded(child: GSearchInput(placeholder: '搜索代币/钱包')),
          const Gap(GSpacing.lg),
          // 扫码按钮
          GIconButton(
            icon: Icons.qr_code_scanner,
            bgColor: GColors.bgInput,
            hasBorder: false,
          ),
          const Gap(GSpacing.md),
          // 用户菜单
          _ChainSelector(),
        ],
      ),
    );
  }
}

class _ChainSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GSpacing.md, vertical: GSpacing.md),
      decoration: BoxDecoration(
        color: GColors.bgInput,
        borderRadius: BorderRadius.circular(GRadius.md),
      ),
      child: Row(
        children: [
          // 四色小方块
          SizedBox(
            width: 20,
            height: 20,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              children: const [
                _ColorBlock(GColors.green),
                _ColorBlock(GColors.blue),
                _ColorBlock(GColors.orange),
                _ColorBlock(GColors.purple),
              ],
            ),
          ),
          const Gap(GSpacing.xs),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: GColors.textSecondary),
        ],
      ),
    );
  }
}

class _ColorBlock extends StatelessWidget {
  final Color color;
  const _ColorBlock(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
