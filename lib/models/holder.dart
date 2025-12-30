import 'package:flutter/material.dart';

/// 持有者标签类型
enum HolderTag {
  whale,      // 鲸鱼
  smartMoney, // 聪明钱
  kol,        // KOL
  developer,  // 开发者
  newWallet,  // 新钱包
  diamond,    // 钻石手
}

/// 持有者数据
class Holder {
  final String id;
  final String address;
  final String? nickname;
  final String? avatar;
  final int rank;
  final double holdingPercent;
  final double previousPercent;
  final double holdingValue;
  final double profitUsd;
  final double profitPercent;
  final List<HolderTag> tags;
  final Color avatarColor;

  Holder({
    required this.id,
    required this.address,
    this.nickname,
    this.avatar,
    required this.rank,
    required this.holdingPercent,
    this.previousPercent = 0,
    required this.holdingValue,
    required this.profitUsd,
    required this.profitPercent,
    this.tags = const [],
    required this.avatarColor,
  });

  String get shortAddress {
    if (address.length > 10) {
      return '${address.substring(0, 4)}...${address.substring(address.length - 4)}';
    }
    return address;
  }

  String get rankLabel {
    switch (rank) {
      case 1: return '1st';
      case 2: return '2nd';
      case 3: return '3rd';
      default: return '$rank';
    }
  }

  String get formattedHoldingValue {
    if (holdingValue >= 1e6) {
      return '\$${(holdingValue / 1e6).toStringAsFixed(2)}M';
    } else if (holdingValue >= 1e3) {
      return '\$${(holdingValue / 1e3).toStringAsFixed(2)}K';
    }
    return '\$${holdingValue.toStringAsFixed(2)}';
  }

  String get formattedProfit {
    final prefix = profitUsd >= 0 ? '+' : '';
    if (profitUsd.abs() >= 1e6) {
      return '$prefix\$${(profitUsd / 1e6).toStringAsFixed(2)}M';
    } else if (profitUsd.abs() >= 1e3) {
      return '$prefix\$${(profitUsd / 1e3).toStringAsFixed(2)}K';
    }
    return '$prefix\$${profitUsd.toStringAsFixed(2)}';
  }

  String get holdingChange {
    return '${previousPercent.toStringAsFixed(0)}%→${holdingPercent.toStringAsFixed(2)}%';
  }

  bool get isProfitable => profitUsd >= 0;
}

/// 生成测试持有者数据
List<Holder> generateMockHolders() {
  final List<Map<String, dynamic>> mockData = [
    {'address': '0xcf8a...cce6', 'percent': 19.32, 'value': 1310000, 'profit': -548920, 'profitPct': -27.4, 'tags': [HolderTag.whale, HolderTag.smartMoney], 'color': 0xFFE91E63},
    {'address': '0x5b9e...ede5', 'percent': 16.33, 'value': 1110000, 'profit': -238670, 'profitPct': -19.74, 'tags': [HolderTag.kol, HolderTag.whale], 'color': 0xFF9C27B0},
    {'address': '0x9f72...b8ca', 'percent': 10.00, 'value': 683370, 'profit': 0, 'profitPct': 0, 'tags': [HolderTag.whale, HolderTag.smartMoney, HolderTag.diamond], 'color': 0xFF2196F3},
    {'address': '0xd53f...060a', 'percent': 9.13, 'value': 623820, 'profit': -163180, 'profitPct': -23.87, 'tags': [HolderTag.whale, HolderTag.smartMoney, HolderTag.diamond], 'color': 0xFF4CAF50},
    {'address': '0x2678...787a', 'percent': 9.06, 'value': 618700, 'profit': 10380, 'profitPct': 1.68, 'tags': [HolderTag.newWallet, HolderTag.smartMoney], 'color': 0xFFFF9800},
    {'address': '0xa3b2...1234', 'percent': 7.82, 'value': 534200, 'profit': 45320, 'profitPct': 9.27, 'tags': [HolderTag.kol], 'color': 0xFFE91E63},
    {'address': '0xb4c3...5678', 'percent': 5.45, 'value': 372100, 'profit': -89450, 'profitPct': -19.38, 'tags': [HolderTag.whale], 'color': 0xFF00BCD4},
    {'address': '0xc5d4...9abc', 'percent': 4.21, 'value': 287600, 'profit': 23100, 'profitPct': 8.73, 'tags': [HolderTag.smartMoney, HolderTag.diamond], 'color': 0xFF8BC34A},
    {'address': '0xd6e5...def0', 'percent': 3.89, 'value': 265700, 'profit': -45600, 'profitPct': -14.65, 'tags': [HolderTag.newWallet], 'color': 0xFFFF5722},
    {'address': '0xe7f6...1234', 'percent': 3.12, 'value': 213100, 'profit': 67800, 'profitPct': 46.67, 'tags': [HolderTag.smartMoney], 'color': 0xFF673AB7},
    {'address': '0xf8a7...5678', 'percent': 2.78, 'value': 189800, 'profit': -23400, 'profitPct': -10.98, 'tags': [HolderTag.kol, HolderTag.whale], 'color': 0xFF3F51B5},
    {'address': '0x19b8...9abc', 'percent': 2.45, 'value': 167300, 'profit': 12300, 'profitPct': 7.93, 'tags': [HolderTag.diamond], 'color': 0xFF009688},
    {'address': '0x2ac9...def0', 'percent': 2.11, 'value': 144100, 'profit': -34500, 'profitPct': -19.32, 'tags': [HolderTag.newWallet, HolderTag.smartMoney], 'color': 0xFFCDDC39},
    {'address': '0x3bda...1234', 'percent': 1.89, 'value': 129000, 'profit': 8900, 'profitPct': 7.41, 'tags': [HolderTag.whale], 'color': 0xFFFFEB3B},
    {'address': '0x4ceb...5678', 'percent': 1.67, 'value': 114000, 'profit': -56700, 'profitPct': -33.21, 'tags': [HolderTag.kol], 'color': 0xFFFFC107},
    {'address': '0x5dfc...9abc', 'percent': 1.45, 'value': 99000, 'profit': 34500, 'profitPct': 53.49, 'tags': [HolderTag.smartMoney, HolderTag.diamond], 'color': 0xFFFF9800},
    {'address': '0x6e0d...def0', 'percent': 1.23, 'value': 84000, 'profit': -12300, 'profitPct': -12.78, 'tags': [HolderTag.newWallet], 'color': 0xFFFF5722},
    {'address': '0x7f1e...1234', 'percent': 1.01, 'value': 69000, 'profit': 23400, 'profitPct': 51.32, 'tags': [HolderTag.whale, HolderTag.kol], 'color': 0xFF795548},
    {'address': '0x802f...5678', 'percent': 0.89, 'value': 60800, 'profit': -8900, 'profitPct': -12.77, 'tags': [HolderTag.smartMoney], 'color': 0xFF607D8B},
    {'address': '0x9140...9abc', 'percent': 0.78, 'value': 53300, 'profit': 5600, 'profitPct': 11.74, 'tags': [HolderTag.diamond, HolderTag.newWallet], 'color': 0xFF9E9E9E},
  ];

  return List.generate(mockData.length, (index) {
    final data = mockData[index];
    return Holder(
      id: 'holder_$index',
      address: data['address'] as String,
      rank: index + 1,
      holdingPercent: data['percent'] as double,
      previousPercent: 0,
      holdingValue: data['value'] as double,
      profitUsd: data['profit'] as double,
      profitPercent: data['profitPct'] as double,
      tags: data['tags'] as List<HolderTag>,
      avatarColor: Color(data['color'] as int),
    );
  });
}
