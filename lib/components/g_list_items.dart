import 'package:flutter/material.dart';
import 'theme.dart';
import 'g_image.dart';

/// Reusable trader list item with performance optimization
class GTraderListItem extends StatelessWidget {
  final int? rank;
  final String? avatarUrl;
  final String displayName;
  final String subtitle;
  final String profitText;
  final double? profitPercent;
  final VoidCallback? onTap;

  const GTraderListItem({
    super.key,
    this.rank,
    this.avatarUrl,
    required this.displayName,
    required this.subtitle,
    required this.profitText,
    this.profitPercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: GColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Rank
              if (rank != null)
                SizedBox(
                  width: 24,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              if (rank != null) const SizedBox(width: 10),
              // Avatar
              GAvatar(
                imageUrl: avatarUrl,
                name: displayName,
                size: 44,
                borderRadius: 10,
                borderColor: GColors.borderLight,
                borderWidth: 2,
              ),
              const SizedBox(width: 10),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: GColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // Profit
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    profitText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GColors.green,
                    ),
                  ),
                  if (profitPercent != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: GColors.bsc,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('◆', style: TextStyle(fontSize: 6, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${profitPercent!.toStringAsFixed(1)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable token card with performance optimization
class GTokenListItem extends StatelessWidget {
  final String? avatarUrl;
  final Color? avatarColor;
  final String name;
  final String symbol;
  final String price;
  final String marketCap;
  final String? priceChange;
  final bool isPriceUp;
  final String? time;
  final List<String>? badges;
  final VoidCallback? onTap;
  final VoidCallback? onBuyTap;

  const GTokenListItem({
    super.key,
    this.avatarUrl,
    this.avatarColor,
    required this.name,
    required this.symbol,
    required this.price,
    required this.marketCap,
    this.priceChange,
    this.isPriceUp = true,
    this.time,
    this.badges,
    this.onTap,
    this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GColors.bgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GColors.borderLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: avatarColor ?? GColors.bgElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: avatarUrl != null
                    ? GNetworkImage(
                        imageUrl: avatarUrl,
                        width: 40,
                        height: 40,
                        borderRadius: 10,
                      )
                    : Center(
                        child: Text(
                          name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: GColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          symbol,
                          style: GTextStyle.caption,
                        ),
                      ],
                    ),
                    if (badges != null && badges!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: badges!
                            .take(4)
                            .map((badge) => _buildBadge(badge))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Price info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MC $marketCap',
                    style: GTextStyle.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isPriceUp ? GColors.green : GColors.red,
                    ),
                  ),
                  if (priceChange != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      priceChange!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isPriceUp ? GColors.green : GColors.red,
                      ),
                    ),
                  ],
                  if (onBuyTap != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onBuyTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: GColors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Buy',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(38),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: GColors.textSecondary),
      ),
    );
  }
}

/// Activity item widget
class GActivityItem extends StatelessWidget {
  final String? avatarUrl;
  final String walletName;
  final String action; // 'add' or 'reduce'
  final String amount;
  final String tokenSymbol;
  final String? tokenIcon;
  final String? marketCap;
  final String? pnl;
  final String timeText;
  final VoidCallback? onBuyTap;

  const GActivityItem({
    super.key,
    this.avatarUrl,
    required this.walletName,
    required this.action,
    required this.amount,
    required this.tokenSymbol,
    this.tokenIcon,
    this.marketCap,
    this.pnl,
    required this.timeText,
    this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAdd = action == 'add';
    final actionColor = isAdd ? GColors.green : GColors.red;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: GColors.bgElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                GAvatar(
                  imageUrl: avatarUrl,
                  name: walletName,
                  size: 32,
                  borderRadius: 8,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    walletName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: GColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  timeText,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Content
            Row(
              children: [
                // Action tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: actionColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isAdd ? 'Add' : 'Reduce',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: actionColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Amount
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                // Token
                if (tokenIcon != null)
                  GNetworkImage(
                    imageUrl: tokenIcon,
                    width: 20,
                    height: 20,
                    borderRadius: 10,
                  ),
                const SizedBox(width: 6),
                Text(
                  tokenSymbol,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: GColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // Buy button
                if (onBuyTap != null)
                  GestureDetector(
                    onTap: onBuyTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: GColors.green),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline, size: 14, color: GColors.green),
                          const SizedBox(width: 4),
                          Text('Buy', style: TextStyle(fontSize: 12, color: GColors.green)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Footer
            if (marketCap != null || pnl != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (marketCap != null)
                    Text(
                      'MC $marketCap',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  if (pnl != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      'PnL $pnl',
                      style: TextStyle(
                        fontSize: 11,
                        color: pnl!.startsWith('-') ? GColors.red : GColors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
