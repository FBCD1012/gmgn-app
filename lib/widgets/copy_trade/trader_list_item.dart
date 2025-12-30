import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/trader.dart';

const Color _kPrimaryGreen = Color(0xFF00D26A);
const Color _kBorderColor = Color(0xFF333333);

/// 交易员列表项 - 可复用组件
class TraderListItem extends StatelessWidget {
  final Trader trader;
  final VoidCallback? onTap;

  const TraderListItem({
    super.key,
    required this.trader,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF1A1A1A), width: 1),
          ),
        ),
        child: Row(
          children: [
            // 排名
            _buildRank(),
            const SizedBox(width: 10),
            // 头像
            _buildAvatar(),
            const SizedBox(width: 10),
            // 信息
            Expanded(child: _buildInfo()),
            // 收益
            _buildProfit(),
          ],
        ),
      ),
    );
  }

  Widget _buildRank() {
    return SizedBox(
      width: 24,
      child: Text(
        '${trader.rank}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorderColor, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: trader.avatar ?? 'https://api.dicebear.com/7.x/pixel-art/png?seed=${trader.address}',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: _kBorderColor,
            child: const Icon(Icons.person, color: Colors.white54, size: 20),
          ),
          errorWidget: (context, url, error) => Container(
            color: _kBorderColor,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trader.displayName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${trader.followers} Followers  ${trader.followedBy} Notes',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildProfit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '+\$${_formatMoney(trader.profit7d)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _kPrimaryGreen,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // BSC 图标
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFF0B90B),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('◆', style: TextStyle(fontSize: 6, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '+${trader.profitPercent7d.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
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
