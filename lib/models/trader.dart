class Trader {
  final String id;
  final String address;
  final String? nickname;
  final String? avatar;
  final int rank;
  final double profit7d;
  final double profitPercent7d;
  final int tradeCount7d;
  final double winRate;
  final int followers;
  final int followedBy;
  final double balance;
  final List<TraderHolding> holdings;
  final bool isFollowing;

  Trader({
    required this.id,
    required this.address,
    this.nickname,
    this.avatar,
    required this.rank,
    required this.profit7d,
    required this.profitPercent7d,
    required this.tradeCount7d,
    required this.winRate,
    required this.followers,
    required this.followedBy,
    required this.balance,
    this.holdings = const [],
    this.isFollowing = false,
  });

  factory Trader.fromJson(Map<String, dynamic> json) {
    return Trader(
      id: json['id'],
      address: json['address'],
      nickname: json['nickname'],
      avatar: json['avatar'],
      rank: json['rank'],
      profit7d: (json['profit_7d'] as num).toDouble(),
      profitPercent7d: (json['profit_percent_7d'] as num).toDouble(),
      tradeCount7d: json['trade_count_7d'],
      winRate: (json['win_rate'] as num).toDouble(),
      followers: json['followers'],
      followedBy: json['followed_by'],
      balance: (json['balance'] as num).toDouble(),
      holdings: (json['holdings'] as List?)
              ?.map((e) => TraderHolding.fromJson(e))
              .toList() ??
          [],
      isFollowing: json['is_following'] ?? false,
    );
  }

  String get shortAddress {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }

  String get displayName => nickname ?? shortAddress;
}

class TraderHolding {
  final String symbol;
  final String name;
  final double balance;
  final double value;
  final double profit;
  final double profitPercent;
  final String duration;

  TraderHolding({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.value,
    required this.profit,
    required this.profitPercent,
    required this.duration,
  });

  factory TraderHolding.fromJson(Map<String, dynamic> json) {
    return TraderHolding(
      symbol: json['symbol'],
      name: json['name'],
      balance: (json['balance'] as num).toDouble(),
      value: (json['value'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      profitPercent: (json['profit_percent'] as num).toDouble(),
      duration: json['duration'],
    );
  }
}
