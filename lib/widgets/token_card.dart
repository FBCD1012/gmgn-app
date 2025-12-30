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
  final String volume;        // 成交量 Vol
  final String txCount;       // 交易数
  final String changePercent; // 涨跌幅 1h%

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
    this.volume = '\$0',
    this.txCount = '0',
    this.changePercent = '0%',
  });
}

class TokenCard extends StatelessWidget {
  final TokenData token;

  const TokenCard({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final isPositive = !token.changePercent.startsWith('-');

    return GCard.flat(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TokenDetailScreen(tokenId: token.id)),
      ),
      child: Row(
        children: [
          // ========== 左列: 头像 + 名称 + 持有者 (flex 5) ==========
          Expanded(
            flex: 5,
            child: Row(
              children: [
                // 头像
                Stack(
                  children: [
                    GAvatar(
                      imageUrl: token.imageUrl,
                      name: token.symbol,
                      size: 44,
                      borderRadius: 12,
                    ),
                    if (token.hasVerified)
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: GVerifiedBadge(size: 14),
                      ),
                  ],
                ),
                const Gap(GSpacing.md),
                // 名称信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 名称 + 图标
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              token.name,
                              style: GTextStyle.subtitle.copyWith(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Gap(4),
                          // 小图标组
                          Icon(Icons.copy_outlined, size: 12, color: GColors.textTertiary),
                          const Gap(4),
                          Icon(Icons.search, size: 12, color: GColors.textTertiary),
                        ],
                      ),
                      const Gap(4),
                      // 时间 / 持有者
                      Row(
                        children: [
                          if (token.time.isNotEmpty) ...[
                            Text(
                              token.time,
                              style: TextStyle(fontSize: 11, color: GColors.textTertiary),
                            ),
                            Text(' / ', style: TextStyle(fontSize: 11, color: GColors.textTertiary)),
                          ],
                          Text(
                            _formatNumber(token.holders),
                            style: TextStyle(fontSize: 11, color: GColors.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ========== 中列: Vol / 交易数 (flex 3) ==========
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  token.volume,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const Gap(4),
                Text(
                  token.txCount,
                  style: TextStyle(
                    fontSize: 11,
                    color: GColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const Gap(GSpacing.lg),

          // ========== 右列: 市值 / 涨跌幅 (flex 3) ==========
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  token.marketCap,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const Gap(4),
                Text(
                  token.changePercent,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isPositive ? GColors.green : GColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(2)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(2)}K';
    }
    return num.toString();
  }

}
