import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../components/components.dart';
import 'animated_dogecoin.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 背景狗狗动画
        const Positioned(
          right: 16,
          top: 0,
          child: RepaintBoundary(
            child: AnimatedDogecoin(
              size: 120,
              opacity: 0.15,
            ),
          ),
        ),
        // 内容
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GSpacing.lg),
          child: Column(
            children: [
              const Gap(GSpacing.xl),
              // 标题
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Faster Discovery, Instant Trading',
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
                'Fast on-chain operations, one-click trading; auto take-profit & stop-loss.',
                style: GTextStyle.caption,
              ),
              const Gap(GSpacing.xxl),
              // 按钮组
              Row(
                children: [
                  // 注册按钮
                  Expanded(
                    child: GButton(
                      text: 'Sign Up',
                      variant: GButtonVariant.secondary,
                      size: GButtonSize.lg,
                    ),
                  ),
                  const Gap(GSpacing.lg),
                  // 登录按钮
                  Expanded(
                    child: GButton.primary(
                      text: 'Login',
                      color: GColors.primary,
                    ),
                  ),
                ],
              ),
              const Gap(GSpacing.xl),
            ],
          ),
        ),
      ],
    );
  }
}
