import 'package:flutter/material.dart';

/// 跟单状态
enum CopyTradeStatus {
  active,   // 进行中
  paused,   // 已暂停
  stopped,  // 已停止
}

/// 止盈规则
class TakeProfitRule {
  final double stopLoss;
  final double sellRatio;

  TakeProfitRule({
    required this.stopLoss,
    required this.sellRatio,
  });
}

/// 跟单记录模型 (用于设置页面)
class CopyTradeRecord {
  final String id;
  final String targetAddress;
  final String targetNickname;
  final String walletName;
  final double amount;
  final int positionCount;
  final bool noBuyHolding;
  final bool autoFollowSell;
  final bool batchTakeProfit;
  final List<TakeProfitRule> takeProfitRules;
  final bool devSell;
  final double devSellThreshold;
  final double devAutoSellRatio;
  final bool migrationAutoSell;
  final double migrationSellRatio;
  final bool singleTakeProfit;
  final bool slippageAuto;
  final double? slippageCustom;
  final bool gasAverage;
  final double? gasCustom;
  final double? maxAutoGas;
  final bool antiMEV;
  final bool autoApprove;
  final DateTime createdAt;
  final CopyTradeStatus status;

  CopyTradeRecord({
    required this.id,
    required this.targetAddress,
    this.targetNickname = '',
    required this.walletName,
    required this.amount,
    this.positionCount = 1,
    this.noBuyHolding = false,
    this.autoFollowSell = true,
    this.batchTakeProfit = false,
    this.takeProfitRules = const [],
    this.devSell = false,
    this.devSellThreshold = 25,
    this.devAutoSellRatio = 100,
    this.migrationAutoSell = false,
    this.migrationSellRatio = 100,
    this.singleTakeProfit = false,
    this.slippageAuto = true,
    this.slippageCustom,
    this.gasAverage = true,
    this.gasCustom,
    this.maxAutoGas,
    this.antiMEV = true,
    this.autoApprove = true,
    required this.createdAt,
    this.status = CopyTradeStatus.active,
  });

  String get statusText {
    switch (status) {
      case CopyTradeStatus.active:
        return 'Active';
      case CopyTradeStatus.paused:
        return 'Paused';
      case CopyTradeStatus.stopped:
        return 'Stopped';
    }
  }

  String get shortAddress {
    if (targetAddress.length > 10) {
      return '${targetAddress.substring(0, 6)}...${targetAddress.substring(targetAddress.length - 4)}';
    }
    return targetAddress;
  }
}

/// 当前跟单数据 (用于列表展示)
class CopyTrade {
  final String id;
  final String traderId;
  final String traderAddress;
  final String? traderNickname;
  final String? traderAvatar;
  final String walletName;
  final int buyCount;
  final int sellCount;
  final double totalBuyAmount;
  final double totalSellAmount;
  final DateTime? lastTradeTime;
  final DateTime createdAt;
  final CopyTradeStatus status;
  final Color avatarColor;

  // 跟单配置参数
  final double configuredAmount;      // 配置的跟单金额
  final int configuredPositionCount;  // 配置的加仓次数
  final bool autoFollowSell;          // 自动跟卖
  final bool devSell;                 // Dev卖
  final double devSellThreshold;      // Dev卖阈值

  CopyTrade({
    required this.id,
    required this.traderId,
    required this.traderAddress,
    this.traderNickname,
    this.traderAvatar,
    this.walletName = 'Wallet1',
    this.buyCount = 0,
    this.sellCount = 0,
    this.totalBuyAmount = 0,
    this.totalSellAmount = 0,
    this.lastTradeTime,
    required this.createdAt,
    this.status = CopyTradeStatus.active,
    required this.avatarColor,
    this.configuredAmount = 0,
    this.configuredPositionCount = 1,
    this.autoFollowSell = true,
    this.devSell = false,
    this.devSellThreshold = 25,
  });

  String get shortAddress {
    if (traderAddress.length > 10) {
      return '${traderAddress.substring(0, 4)}...${traderAddress.substring(traderAddress.length - 3)}';
    }
    return traderAddress;
  }

  String get displayName => traderNickname ?? shortAddress;

  String get totalBuyText {
    // 如果有实际交易金额，显示实际值
    if (totalBuyAmount > 0) {
      if (totalBuyAmount >= 1000) {
        return '${(totalBuyAmount / 1000).toStringAsFixed(2)}K';
      }
      return totalBuyAmount.toStringAsFixed(2);
    }
    // 如果没有实际交易，显示配置的金额
    if (configuredAmount > 0) {
      return '${configuredAmount.toStringAsFixed(1)} BNB';
    }
    return '--';
  }

  String get totalSellText {
    if (totalSellAmount == 0) return '--';
    if (totalSellAmount >= 1000) {
      return '${(totalSellAmount / 1000).toStringAsFixed(2)}K';
    }
    return totalSellAmount.toStringAsFixed(2);
  }

  // 获取配置信息的显示文本
  String get configuredAmountText {
    if (configuredAmount > 0) {
      return '${configuredAmount.toStringAsFixed(1)} BNB';
    }
    return '--';
  }

  String get positionCountText => '$configuredPositionCount times';

  String get lastTradeTimeText {
    if (lastTradeTime == null) return '--';
    final now = DateTime.now();
    final diff = now.difference(lastTradeTime!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  bool get isActive => status == CopyTradeStatus.active;
  bool get isPaused => status == CopyTradeStatus.paused;

  CopyTrade copyWith({
    CopyTradeStatus? status,
    int? buyCount,
    int? sellCount,
    double? totalBuyAmount,
    double? totalSellAmount,
    DateTime? lastTradeTime,
    double? configuredAmount,
    int? configuredPositionCount,
    bool? autoFollowSell,
    bool? devSell,
    double? devSellThreshold,
  }) {
    return CopyTrade(
      id: id,
      traderId: traderId,
      traderAddress: traderAddress,
      traderNickname: traderNickname,
      traderAvatar: traderAvatar,
      walletName: walletName,
      buyCount: buyCount ?? this.buyCount,
      sellCount: sellCount ?? this.sellCount,
      totalBuyAmount: totalBuyAmount ?? this.totalBuyAmount,
      totalSellAmount: totalSellAmount ?? this.totalSellAmount,
      lastTradeTime: lastTradeTime ?? this.lastTradeTime,
      createdAt: createdAt,
      status: status ?? this.status,
      avatarColor: avatarColor,
      configuredAmount: configuredAmount ?? this.configuredAmount,
      configuredPositionCount: configuredPositionCount ?? this.configuredPositionCount,
      autoFollowSell: autoFollowSell ?? this.autoFollowSell,
      devSell: devSell ?? this.devSell,
      devSellThreshold: devSellThreshold ?? this.devSellThreshold,
    );
  }
}
