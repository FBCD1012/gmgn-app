import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../components/components.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GSpacing.lg),
      child: Column(
        children: [
          const Gap(GSpacing.xl),
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '更快发现，秒级交易',
                style: GTextStyle.subtitle.copyWith(
                  color: GColors.primary,
                  fontSize: 17,
                ),
              ),
              const Gap(GSpacing.xs),
              const Text('🚀', style: TextStyle(fontSize: 16)),
            ],
          ),
          const Gap(GSpacing.md),
          // 副标题
          Text(
            '快速链上操作，一键交易；自动止盈止损。',
            style: GTextStyle.caption,
          ),
          const Gap(GSpacing.xxl),
          // 按钮组
          Row(
            children: [
              // 注册按钮
              Expanded(
                child: GButton(
                  text: '注册',
                  variant: GButtonVariant.secondary,
                  size: GButtonSize.lg,
                ),
              ),
              const Gap(GSpacing.lg),
              // 登录按钮
              Expanded(
                child: GButton.primary(
                  text: '登录',
                  color: GColors.primary,
                ),
              ),
            ],
          ),
          const Gap(GSpacing.xl),
        ],
      ),
    );
  }
}
