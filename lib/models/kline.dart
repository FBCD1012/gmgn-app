class KLineData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  KLineData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  bool get isUp => close >= open;
  double get change => close - open;
  double get changePercent => open > 0 ? (change / open) * 100 : 0;
}

class TokenDetail {
  final String id;
  final String name;
  final String symbol;
  final String address;
  final String? avatar;
  final double price;
  final double priceChange24h;
  final double marketCap;
  final double volume24h;
  final double poolLiquidity;
  final double top10Percent;
  final int holders;
  final int dexPaid;
  final double mouseWarehouse; // 老鼠仓
  final double devHolding;
  final List<String> tags;
  final bool isVerified;
  final DateTime createdAt;

  TokenDetail({
    required this.id,
    required this.name,
    required this.symbol,
    required this.address,
    this.avatar,
    required this.price,
    this.priceChange24h = 0,
    required this.marketCap,
    this.volume24h = 0,
    this.poolLiquidity = 0,
    this.top10Percent = 0,
    this.holders = 0,
    this.dexPaid = 0,
    this.mouseWarehouse = 0,
    this.devHolding = 0,
    this.tags = const [],
    this.isVerified = false,
    required this.createdAt,
  });

  String get shortAddress {
    if (address.length > 12) {
      return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
    }
    return address;
  }

  String get formattedPrice {
    if (price < 0.0001) {
      // 科学计数法格式化
      String priceStr = price.toStringAsFixed(10);
      int zeroCount = 0;
      bool foundDot = false;
      for (int i = 0; i < priceStr.length; i++) {
        if (priceStr[i] == '.') {
          foundDot = true;
          continue;
        }
        if (foundDot && priceStr[i] == '0') {
          zeroCount++;
        } else if (foundDot) {
          break;
        }
      }
      if (zeroCount > 2) {
        String significant = priceStr.substring(priceStr.indexOf('.') + zeroCount + 1);
        if (significant.length > 5) significant = significant.substring(0, 5);
        return '\$0.0₃$significant';
      }
    }
    if (price < 1) {
      return '\$${price.toStringAsFixed(6)}';
    }
    return '\$${price.toStringAsFixed(2)}';
  }

  String get formattedMarketCap {
    if (marketCap >= 1e9) {
      return '\$${(marketCap / 1e9).toStringAsFixed(2)}B';
    } else if (marketCap >= 1e6) {
      return '\$${(marketCap / 1e6).toStringAsFixed(2)}M';
    } else if (marketCap >= 1e3) {
      return '\$${(marketCap / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${marketCap.toStringAsFixed(2)}';
  }

  String get formattedVolume {
    if (volume24h >= 1e9) {
      return '\$${(volume24h / 1e9).toStringAsFixed(2)}B';
    } else if (volume24h >= 1e6) {
      return '\$${(volume24h / 1e6).toStringAsFixed(2)}M';
    } else if (volume24h >= 1e3) {
      return '\$${(volume24h / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${volume24h.toStringAsFixed(2)}';
  }

  String get formattedHolders {
    if (holders >= 1000) {
      return '${(holders / 1000).toStringAsFixed(2)}K';
    }
    return holders.toString();
  }
}
