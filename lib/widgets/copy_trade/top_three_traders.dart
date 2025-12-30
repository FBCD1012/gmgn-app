import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/trader.dart';

const Color _kPrimaryGreen = Color(0xFF00D26A);
const Color _kBorderColor = Color(0xFF333333);
const Color _kGoldColor = Color(0xFFD4AF37);
const Color _kSilverColor = Color(0xFF8A8A8A);
const Color _kBronzeColor = Color(0xFFCD7F32);

/// 排行榜前三名展示组件
class TopThreeTraders extends StatelessWidget {
  final List<Trader> traders;
  final Function(Trader) onTraderTap;

  const TopThreeTraders({
    super.key,
    required this.traders,
    required this.onTraderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (traders.length < 3) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 第2名 (左)
          _TopTraderCard(
            trader: traders[1],
            rank: 2,
            borderColor: _kSilverColor,
            cardHeight: 150,
            onTap: () => onTraderTap(traders[1]),
          ),
          const SizedBox(width: 10),
          // 第1名 (中)
          _TopTraderCard(
            trader: traders[0],
            rank: 1,
            borderColor: _kGoldColor,
            cardHeight: 170,
            onTap: () => onTraderTap(traders[0]),
          ),
          const SizedBox(width: 10),
          // 第3名 (右)
          _TopTraderCard(
            trader: traders[2],
            rank: 3,
            borderColor: _kBronzeColor,
            cardHeight: 150,
            onTap: () => onTraderTap(traders[2]),
          ),
        ],
      ),
    );
  }
}

class _TopTraderCard extends StatelessWidget {
  final Trader trader;
  final int rank;
  final Color borderColor;
  final double cardHeight;
  final VoidCallback onTap;

  const _TopTraderCard({
    required this.trader,
    required this.rank,
    required this.borderColor,
    required this.cardHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    final cardWidth = isFirst ? 130.0 : 105.0;

    final gradientColors = _getGradientColors();

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: cardWidth,
              height: cardHeight,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withAlpha(77),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFirst) const Text('👑', style: TextStyle(fontSize: 16)),
                  if (isFirst) const SizedBox(height: 2),
                  _buildAvatar(isFirst),
                  const SizedBox(height: 6),
                  _buildName(),
                  const SizedBox(height: 2),
                  _buildFollowers(),
                  const SizedBox(height: 4),
                  _buildProfit(isFirst),
                ],
              ),
            ),
            // 排名徽章
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Center(child: _buildRankBadge()),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (rank == 1) {
      return [const Color(0xFF3D3D1F), const Color(0xFF2A2A15)];
    } else if (rank == 2) {
      return [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)];
    } else {
      return [const Color(0xFF2A2015), const Color(0xFF1F1A15)];
    }
  }

  Widget _buildAvatar(bool isFirst) {
    final size = isFirst ? 48.0 : 40.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withAlpha(102),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: trader.avatar ?? 'https://api.dicebear.com/7.x/pixel-art/png?seed=${trader.address}',
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(
            color: _kBorderColor,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildName() {
    return Text(
      trader.displayName,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFollowers() {
    return Text(
      '${trader.followers} Followers',
      style: TextStyle(fontSize: 9, color: Colors.grey[400]),
    );
  }

  Widget _buildProfit(bool isFirst) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _kPrimaryGreen.withAlpha(38),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '+\$${_formatMoney(trader.profit7d)}',
        style: TextStyle(
          fontSize: isFirst ? 12 : 11,
          fontWeight: FontWeight.bold,
          color: _kPrimaryGreen,
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: borderColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  static String _formatMoney(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(2);
  }
}
