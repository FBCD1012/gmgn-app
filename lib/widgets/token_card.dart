import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../components/components.dart';
import '../screens/token_detail_screen.dart';

class TokenData {
  final String id;
  final String name;
  final String symbol;
  final String? subName;
  final String price;
  final String marketCap;
  final String fee;
  final String tx;
  final String time;
  final int holders;
  final int comments;
  final String ratio;
  final List<String> badges;
  final List<String> socialIcons;
  final bool txPositive;
  final String? imageUrl;
  final bool hasVerified;

  const TokenData({
    required this.id,
    required this.name,
    required this.symbol,
    this.subName,
    required this.price,
    required this.marketCap,
    required this.fee,
    required this.tx,
    required this.time,
    required this.holders,
    required this.comments,
    required this.ratio,
    this.badges = const [],
    this.socialIcons = const [],
    this.txPositive = true,
    this.imageUrl,
    this.hasVerified = false,
  });
}

class TokenCard extends StatelessWidget {
  final TokenData token;

  const TokenCard({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return GCard.flat(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TokenDetailScreen(tokenId: token.id)),
      ),
      child: Row(
        children: [
          // 头像
          GAvatar(
            imageUrl: token.imageUrl,
            text: token.symbol,
            badge: token.hasVerified ? const GVerifiedBadge() : null,
          ),
          const Gap(GSpacing.lg),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 名称行
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        token.name,
                        style: GTextStyle.subtitle.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(GSpacing.xs),
                    Text(token.symbol, style: GTextStyle.small),
                  ],
                ),
                const Gap(GSpacing.xs),
                // 统计行
                Row(
                  children: [
                    _StatItem(Icons.access_time, token.time),
                    const Gap(GSpacing.sm),
                    _StatItem(Icons.people_outline, '${token.holders}'),
                    const Gap(GSpacing.sm),
                    Text(
                      token.tx,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: token.txPositive ? GColors.green : GColors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(GSpacing.md),
          // 市值和涨跌
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('MC ', style: GTextStyle.tiny),
                  Text(
                    token.marketCap,
                    style: GTextStyle.subtitle.copyWith(fontSize: 13),
                  ),
                ],
              ),
              const Gap(GSpacing.xs),
              token.badges.isNotEmpty
                  ? _buildBadge(token.badges.first)
                  : GTag(
                      label: token.txPositive ? '+5.2%' : '-3.1%',
                      color: token.txPositive ? GColors.green : GColors.red,
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String badge) {
    if (badge.contains('%')) {
      final isNegative = badge.startsWith('-');
      return GTag(
        label: badge,
        color: isNegative ? GColors.red : GColors.green,
      );
    }
    return GTag.neutral(label: badge);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatItem(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: GColors.textTertiary),
        const Gap(2),
        Text(value, style: GTextStyle.small),
      ],
    );
  }
}
