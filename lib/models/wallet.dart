class Wallet {
  final String id;
  final String address;
  final String name;
  final double balance;
  final String chain;
  final List<TokenHolding> holdings;

  Wallet({
    required this.id,
    required this.address,
    required this.name,
    required this.balance,
    required this.chain,
    this.holdings = const [],
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      address: json['address'],
      name: json['name'],
      balance: (json['balance'] as num).toDouble(),
      chain: json['chain'],
      holdings: (json['holdings'] as List?)
              ?.map((e) => TokenHolding.fromJson(e))
              .toList() ??
          [],
    );
  }

  String get shortAddress {
    if (address.length > 10) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }
}

class TokenHolding {
  final String tokenId;
  final String symbol;
  final String name;
  final double amount;
  final double value;
  final double profit;
  final double profitPercent;
  final String? logo;
  final DateTime lastActive;

  TokenHolding({
    required this.tokenId,
    required this.symbol,
    required this.name,
    required this.amount,
    required this.value,
    required this.profit,
    required this.profitPercent,
    this.logo,
    required this.lastActive,
  });

  factory TokenHolding.fromJson(Map<String, dynamic> json) {
    return TokenHolding(
      tokenId: json['token_id'],
      symbol: json['symbol'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      value: (json['value'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      profitPercent: (json['profit_percent'] as num).toDouble(),
      logo: json['logo'],
      lastActive: DateTime.parse(json['last_active']),
    );
  }
}
