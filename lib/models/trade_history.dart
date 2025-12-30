/// 交易记录类型
enum TradeType { buy, sell }

/// 交易记录
class TradeHistory {
  final String id;
  final String tokenId;
  final String tokenSymbol;
  final String tokenName;
  final TradeType type;
  final double bnbAmount;
  final double tokenAmount;
  final double price;
  final String txHash;
  final DateTime createdAt;
  final bool success;

  TradeHistory({
    required this.id,
    required this.tokenId,
    required this.tokenSymbol,
    required this.tokenName,
    required this.type,
    required this.bnbAmount,
    required this.tokenAmount,
    required this.price,
    required this.txHash,
    required this.createdAt,
    this.success = true,
  });

  String get typeText => type == TradeType.buy ? 'Buy' : 'Sell';

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.month}/${createdAt.day}';
  }

  String get shortTxHash {
    if (txHash.length > 16) {
      return '${txHash.substring(0, 8)}...${txHash.substring(txHash.length - 6)}';
    }
    return txHash;
  }
}
