class Token {
  final String id;
  final String address;
  final String name;
  final String symbol;
  final String? logo;
  final double price;
  final double marketCap;
  final double volume24h;
  final double priceChange24h;
  final int holders;
  final int txCount;
  final double liquidity;
  final bool isVerified;
  final List<String> tags;
  final TokenSocial? social;
  final DateTime createdAt;

  Token({
    required this.id,
    required this.address,
    required this.name,
    required this.symbol,
    this.logo,
    required this.price,
    required this.marketCap,
    required this.volume24h,
    required this.priceChange24h,
    required this.holders,
    required this.txCount,
    required this.liquidity,
    this.isVerified = false,
    this.tags = const [],
    this.social,
    required this.createdAt,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'],
      address: json['address'],
      name: json['name'],
      symbol: json['symbol'],
      logo: json['logo'],
      price: (json['price'] as num).toDouble(),
      marketCap: (json['market_cap'] as num).toDouble(),
      volume24h: (json['volume_24h'] as num).toDouble(),
      priceChange24h: (json['price_change_24h'] as num).toDouble(),
      holders: json['holders'],
      txCount: json['tx_count'],
      liquidity: (json['liquidity'] as num).toDouble(),
      isVerified: json['is_verified'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      social: json['social'] != null
          ? TokenSocial.fromJson(json['social'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get formattedPrice {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(2)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(2)}K';
    }
    return '\$${price.toStringAsFixed(4)}';
  }

  String get formattedMarketCap {
    if (marketCap >= 1000000) {
      return '\$${(marketCap / 1000000).toStringAsFixed(2)}M';
    } else if (marketCap >= 1000) {
      return '\$${(marketCap / 1000).toStringAsFixed(2)}K';
    }
    return '\$${marketCap.toStringAsFixed(2)}';
  }
}

class TokenSocial {
  final String? twitter;
  final String? telegram;
  final String? website;
  final String? discord;

  TokenSocial({
    this.twitter,
    this.telegram,
    this.website,
    this.discord,
  });

  factory TokenSocial.fromJson(Map<String, dynamic> json) {
    return TokenSocial(
      twitter: json['twitter'],
      telegram: json['telegram'],
      website: json['website'],
      discord: json['discord'],
    );
  }
}
