import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/wallet.dart';
import '../models/token.dart';
import '../models/trader.dart';
import '../models/copy_trade.dart';
import '../models/trade_history.dart';
import '../services/mock_api.dart';

/// 全局应用状态管理
class AppState extends ChangeNotifier {
  final MockApi _api = MockApi();

  // 用户状态
  User? _user;
  bool _isLoading = false;
  String? _error;

  // 钱包状态
  List<Wallet> _wallets = [];
  Wallet? _currentWallet;

  // 代币状态
  List<Token> _hotTokens = [];
  bool _isLoadingTokens = false;

  // 交易者状态
  List<Trader> _traders = [];
  bool _isLoadingTraders = false;

  // 跟单记录 (设置详情)
  List<CopyTradeRecord> _copyTradeRecords = [];

  // 当前跟单列表 (UI展示)
  List<CopyTrade> _copyTrades = [];

  // 历史跟单列表
  List<CopyTrade> _historyCopyTrades = [];

  // 交易历史
  List<TradeHistory> _tradeHistory = _generateMockTradeHistory();

  // 已关注的交易者
  List<Trader> _followedTraders = [];

  // 活动数据
  List<Map<String, dynamic>> _activities = [];
  int _unreadActivityCount = 0;

  // 生成模拟交易历史
  static List<TradeHistory> _generateMockTradeHistory() {
    final now = DateTime.now();
    return [
      TradeHistory(
        id: 'trade_1',
        tokenId: 'token_1',
        tokenSymbol: 'H',
        tokenName: 'H Token',
        type: TradeType.buy,
        bnbAmount: 0.15,
        tokenAmount: 500000,
        price: 0.0000003,
        txHash: '0x1234...abcd',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TradeHistory(
        id: 'trade_2',
        tokenId: 'token_1',
        tokenSymbol: 'H',
        tokenName: 'H Token',
        type: TradeType.buy,
        bnbAmount: 0.12,
        tokenAmount: 500000,
        price: 0.00000024,
        txHash: '0x2345...bcde',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      TradeHistory(
        id: 'trade_3',
        tokenId: 'token_2',
        tokenSymbol: 'NIGHT',
        tokenName: 'Night Token',
        type: TradeType.buy,
        bnbAmount: 0.05,
        tokenAmount: 500000,
        price: 0.0000001,
        txHash: '0x3456...cdef',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      TradeHistory(
        id: 'trade_4',
        tokenId: 'token_3',
        tokenSymbol: 'BLUAI',
        tokenName: 'BluAI',
        type: TradeType.buy,
        bnbAmount: 0.25,
        tokenAmount: 2000000,
        price: 0.000000125,
        txHash: '0x4567...def0',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      TradeHistory(
        id: 'trade_5',
        tokenId: 'token_1',
        tokenSymbol: 'H',
        tokenName: 'H Token',
        type: TradeType.sell,
        bnbAmount: 0.08,
        tokenAmount: 200000,
        price: 0.0000004,
        txHash: '0x5678...ef01',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Wallet> get wallets => _wallets;
  Wallet? get currentWallet => _currentWallet;
  double get totalBalance => _wallets.fold(0, (sum, w) => sum + w.balance);

  List<Token> get hotTokens => _hotTokens;
  bool get isLoadingTokens => _isLoadingTokens;

  List<Trader> get traders => _traders;
  bool get isLoadingTraders => _isLoadingTraders;

  List<CopyTradeRecord> get copyTradeRecords => _copyTradeRecords;
  List<CopyTradeRecord> get activeCopyTradeRecords =>
      _copyTradeRecords.where((r) => r.status == CopyTradeStatus.active).toList();

  // 当前跟单 (进行中)
  List<CopyTrade> get copyTrades => _copyTrades;
  List<CopyTrade> get activeCopyTrades =>
      _copyTrades.where((t) => t.status == CopyTradeStatus.active).toList();

  // 历史跟单 (已停止)
  List<CopyTrade> get historyCopyTrades => _historyCopyTrades;

  List<TradeHistory> get tradeHistory => _tradeHistory;

  // 已关注交易者
  List<Trader> get followedTraders => _followedTraders;

  // 活动数据
  List<Map<String, dynamic>> get activities => _activities;
  int get unreadActivityCount => _unreadActivityCount;

  // ============ 用户操作 ============

  /// 登录
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.login(email, password);

    _isLoading = false;
    if (response.success) {
      _user = response.data;
      await _loadUserData();
      notifyListeners();
      return true;
    } else {
      _error = response.error;
      notifyListeners();
      return false;
    }
  }

  /// 注册
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.register(email, password);

    _isLoading = false;
    if (response.success) {
      _user = response.data;
      await _loadUserData();
      notifyListeners();
      return true;
    } else {
      _error = response.error;
      notifyListeners();
      return false;
    }
  }

  /// 第三方登录
  Future<bool> socialLogin(String provider) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.socialLogin(provider);

    _isLoading = false;
    if (response.success) {
      _user = response.data;
      await _loadUserData();
      notifyListeners();
      return true;
    } else {
      _error = response.error;
      notifyListeners();
      return false;
    }
  }

  /// 登出
  void logout() {
    _user = null;
    _wallets = [];
    _currentWallet = null;
    notifyListeners();
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    await Future.wait([
      loadWallets(),
      loadHotTokens(),
    ]);
  }

  // ============ 钱包操作 ============

  /// 加载钱包列表
  Future<void> loadWallets() async {
    final response = await _api.getWallets();
    if (response.success && response.data != null) {
      _wallets = response.data!;
      if (_wallets.isNotEmpty && _currentWallet == null) {
        _currentWallet = _wallets.first;
      }
      notifyListeners();
    }
  }

  /// 刷新钱包
  Future<void> refreshWallet() async {
    if (_currentWallet == null) return;

    final response = await _api.getWalletDetail(_currentWallet!.id);
    if (response.success && response.data != null) {
      _currentWallet = response.data;
      final index = _wallets.indexWhere((w) => w.id == _currentWallet!.id);
      if (index >= 0) {
        _wallets[index] = _currentWallet!;
      }
      notifyListeners();
    }
  }

  // ============ 代币操作 ============

  /// 加载热门代币
  Future<void> loadHotTokens({String? category}) async {
    _isLoadingTokens = true;
    notifyListeners();

    final response = await _api.getHotTokens(category: category);

    _isLoadingTokens = false;
    if (response.success && response.data != null) {
      _hotTokens = response.data!;
    }
    notifyListeners();
  }

  /// 搜索代币
  Future<List<Token>> searchTokens(String keyword) async {
    final response = await _api.searchTokens(keyword);
    return response.success ? response.data! : [];
  }

  /// 买入代币
  Future<TradeResult?> buyToken(String tokenId, double amount, {String? tokenSymbol, String? tokenName}) async {
    if (_currentWallet == null) return null;

    _isLoading = true;
    notifyListeners();

    final response = await _api.buyToken(
      tokenId: tokenId,
      amount: amount,
      walletId: _currentWallet!.id,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      await refreshWallet();
      // 添加交易历史
      _addTradeHistory(
        tokenId: tokenId,
        tokenSymbol: tokenSymbol ?? 'TOKEN',
        tokenName: tokenName ?? 'Token',
        type: TradeType.buy,
        bnbAmount: amount,
        tokenAmount: response.data!.tokenAmount,
        txHash: response.data!.txHash,
      );
    }
    notifyListeners();

    return response.data;
  }

  /// 卖出代币
  Future<TradeResult?> sellToken(String tokenId, double tokenAmount, {String? tokenSymbol, String? tokenName}) async {
    if (_currentWallet == null) return null;

    _isLoading = true;
    notifyListeners();

    final response = await _api.sellToken(
      tokenId: tokenId,
      tokenAmount: tokenAmount,
      walletId: _currentWallet!.id,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      await refreshWallet();
      // 添加交易历史
      _addTradeHistory(
        tokenId: tokenId,
        tokenSymbol: tokenSymbol ?? 'TOKEN',
        tokenName: tokenName ?? 'Token',
        type: TradeType.sell,
        bnbAmount: response.data!.received ?? 0,
        tokenAmount: tokenAmount,
        txHash: response.data!.txHash,
      );
    }
    notifyListeners();

    return response.data;
  }

  /// 添加交易历史
  void _addTradeHistory({
    required String tokenId,
    required String tokenSymbol,
    required String tokenName,
    required TradeType type,
    required double bnbAmount,
    required double tokenAmount,
    required String txHash,
  }) {
    final history = TradeHistory(
      id: 'trade_${DateTime.now().millisecondsSinceEpoch}',
      tokenId: tokenId,
      tokenSymbol: tokenSymbol,
      tokenName: tokenName,
      type: type,
      bnbAmount: bnbAmount,
      tokenAmount: tokenAmount,
      price: tokenAmount > 0 ? bnbAmount / tokenAmount : 0,
      txHash: txHash,
      createdAt: DateTime.now(),
    );
    _tradeHistory.insert(0, history);
  }

  // ============ 跟单操作 ============

  /// 加载排行榜
  Future<void> loadTraders({String category = 'hot', String period = '7d'}) async {
    _isLoadingTraders = true;
    notifyListeners();

    final response = await _api.getLeaderboard(category: category, period: period);

    _isLoadingTraders = false;
    if (response.success && response.data != null) {
      _traders = response.data!;
    }
    notifyListeners();
  }

  /// 关注/取消关注交易者
  Future<bool> toggleFollowTrader(String traderId) async {
    final index = _traders.indexWhere((t) => t.id == traderId);
    if (index < 0) return false;

    final trader = _traders[index];
    final response = trader.isFollowing
        ? await _api.unfollowTrader(traderId)
        : await _api.followTrader(traderId);

    if (response.success) {
      // 更新本地状态
      _traders[index] = Trader(
        id: trader.id,
        address: trader.address,
        nickname: trader.nickname,
        avatar: trader.avatar,
        rank: trader.rank,
        profit7d: trader.profit7d,
        profitPercent7d: trader.profitPercent7d,
        tradeCount7d: trader.tradeCount7d,
        winRate: trader.winRate,
        followers: trader.isFollowing ? trader.followers - 1 : trader.followers + 1,
        followedBy: trader.followedBy,
        balance: trader.balance,
        holdings: trader.holdings,
        isFollowing: !trader.isFollowing,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 设置跟单
  Future<CopyTradeConfig?> setupCopyTrade({
    required String traderId,
    required double amount,
    required double maxPerTrade,
    required double stopLoss,
    required double takeProfit,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.setupCopyTrade(
      traderId: traderId,
      amount: amount,
      maxPerTrade: maxPerTrade,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );

    _isLoading = false;
    notifyListeners();

    return response.data;
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============ 跟单记录操作 ============

  /// 添加跟单记录
  void addCopyTradeRecord(CopyTradeRecord record) {
    _copyTradeRecords.insert(0, record);
    notifyListeners();
  }

  /// 暂停跟单
  void pauseCopyTrade(String recordId) {
    final index = _copyTradeRecords.indexWhere((r) => r.id == recordId);
    if (index >= 0) {
      final old = _copyTradeRecords[index];
      _copyTradeRecords[index] = CopyTradeRecord(
        id: old.id,
        targetAddress: old.targetAddress,
        targetNickname: old.targetNickname,
        walletName: old.walletName,
        amount: old.amount,
        positionCount: old.positionCount,
        noBuyHolding: old.noBuyHolding,
        autoFollowSell: old.autoFollowSell,
        batchTakeProfit: old.batchTakeProfit,
        takeProfitRules: old.takeProfitRules,
        devSell: old.devSell,
        devSellThreshold: old.devSellThreshold,
        devAutoSellRatio: old.devAutoSellRatio,
        migrationAutoSell: old.migrationAutoSell,
        migrationSellRatio: old.migrationSellRatio,
        singleTakeProfit: old.singleTakeProfit,
        slippageAuto: old.slippageAuto,
        slippageCustom: old.slippageCustom,
        gasAverage: old.gasAverage,
        gasCustom: old.gasCustom,
        maxAutoGas: old.maxAutoGas,
        antiMEV: old.antiMEV,
        autoApprove: old.autoApprove,
        createdAt: old.createdAt,
        status: CopyTradeStatus.paused,
      );
      notifyListeners();
    }
  }

  /// 停止跟单
  void stopCopyTrade(String recordId) {
    final index = _copyTradeRecords.indexWhere((r) => r.id == recordId);
    if (index >= 0) {
      final old = _copyTradeRecords[index];
      _copyTradeRecords[index] = CopyTradeRecord(
        id: old.id,
        targetAddress: old.targetAddress,
        targetNickname: old.targetNickname,
        walletName: old.walletName,
        amount: old.amount,
        positionCount: old.positionCount,
        noBuyHolding: old.noBuyHolding,
        autoFollowSell: old.autoFollowSell,
        batchTakeProfit: old.batchTakeProfit,
        takeProfitRules: old.takeProfitRules,
        devSell: old.devSell,
        devSellThreshold: old.devSellThreshold,
        devAutoSellRatio: old.devAutoSellRatio,
        migrationAutoSell: old.migrationAutoSell,
        migrationSellRatio: old.migrationSellRatio,
        singleTakeProfit: old.singleTakeProfit,
        slippageAuto: old.slippageAuto,
        slippageCustom: old.slippageCustom,
        gasAverage: old.gasAverage,
        gasCustom: old.gasCustom,
        maxAutoGas: old.maxAutoGas,
        antiMEV: old.antiMEV,
        autoApprove: old.autoApprove,
        createdAt: old.createdAt,
        status: CopyTradeStatus.stopped,
      );
      notifyListeners();
    }
  }

  /// 删除跟单记录
  void removeCopyTradeRecord(String recordId) {
    _copyTradeRecords.removeWhere((r) => r.id == recordId);
    notifyListeners();
  }

  // ============ 当前跟单操作 (UI展示) ============

  /// 添加跟单
  void addCopyTrade(CopyTrade trade) {
    _copyTrades.insert(0, trade);
    notifyListeners();
  }

  /// 暂停跟单
  void pauseCopyTradeItem(String tradeId) {
    final index = _copyTrades.indexWhere((t) => t.id == tradeId);
    if (index >= 0) {
      _copyTrades[index] = _copyTrades[index].copyWith(status: CopyTradeStatus.paused);
      notifyListeners();
    }
  }

  /// 恢复跟单
  void resumeCopyTradeItem(String tradeId) {
    final index = _copyTrades.indexWhere((t) => t.id == tradeId);
    if (index >= 0) {
      _copyTrades[index] = _copyTrades[index].copyWith(status: CopyTradeStatus.active);
      notifyListeners();
    }
  }

  /// 停止跟单 (移到历史)
  void stopCopyTradeItem(String tradeId) {
    final index = _copyTrades.indexWhere((t) => t.id == tradeId);
    if (index >= 0) {
      final trade = _copyTrades[index].copyWith(status: CopyTradeStatus.stopped);
      _copyTrades.removeAt(index);
      _historyCopyTrades.insert(0, trade);
      notifyListeners();
    }
  }

  /// 删除跟单
  void removeCopyTradeItem(String tradeId) {
    _copyTrades.removeWhere((t) => t.id == tradeId);
    _historyCopyTrades.removeWhere((t) => t.id == tradeId);
    notifyListeners();
  }

  // ============ 关注操作 ============

  /// 添加关注
  void addFollowedTrader(Trader trader) {
    if (!_followedTraders.any((t) => t.id == trader.id)) {
      _followedTraders.insert(0, trader);
      notifyListeners();
    }
  }

  /// 取消关注
  void removeFollowedTrader(String traderId) {
    _followedTraders.removeWhere((t) => t.id == traderId);
    notifyListeners();
  }

  /// 检查是否已关注
  bool isTraderFollowed(String traderId) {
    return _followedTraders.any((t) => t.id == traderId);
  }

  // ============ 活动数据操作 ============

  /// 添加活动
  void addActivity(Map<String, dynamic> activity) {
    _activities.insert(0, activity);
    _unreadActivityCount++;
    // 保留最多50条
    if (_activities.length > 50) {
      _activities.removeLast();
    }
    notifyListeners();
  }

  /// 清除未读数
  void clearUnreadActivityCount() {
    _unreadActivityCount = 0;
    notifyListeners();
  }

  /// 生成模拟活动数据
  void generateMockActivity() {
    final mockActivities = [
      {
        'walletAddress': '0xef...274d',
        'walletName': '0xef...274d',
        'avatar': 'https://pump.mypinata.cloud/ipfs/QmeSzchzEPqCU1jwTnsLjLsBgE6r6bVP9wEL8FfwXkh6mg?img-width=64',
        'action': 'add',
        'amount': '0.107',
        'tokenSymbol': 'ZRC',
        'tokenIcon': 'https://pump.mypinata.cloud/ipfs/QmNPuK8RSriVLrQxVmAqMXkpbqWe9pS1mKLqCrhb85b4uw?img-width=64',
        'tokenAge': '28d',
        'marketCap': '\$1.12M',
        'time': DateTime.now(),
      },
      {
        'walletAddress': '0xef...274d',
        'walletName': '0xef...274d',
        'avatar': 'https://pump.mypinata.cloud/ipfs/QmeSzchzEPqCU1jwTnsLjLsBgE6r6bVP9wEL8FfwXkh6mg?img-width=64',
        'action': 'reduce',
        'amount': '0.579',
        'tokenSymbol': 'Q',
        'tokenIcon': 'https://pump.mypinata.cloud/ipfs/QmR7BRzAoLY9BfpKGXkPRxqaNt3AXsZGSQKVhFknzYqPjy?img-width=64',
        'tokenAge': '120d',
        'marketCap': '\$58.76M',
        'pnl': '-13.59%',
        'time': DateTime.now(),
      },
      {
        'walletAddress': '0xdb...b5fe',
        'walletName': '币圈老韭菜',
        'avatar': 'https://pump.mypinata.cloud/ipfs/QmNPuK8RSriVLrQxVmAqMXkpbqWe9pS1mKLqCrhb85b4uw?img-width=64',
        'action': 'add',
        'amount': '0.341',
        'tokenSymbol': 'ZENT',
        'tokenIcon': 'https://pump.mypinata.cloud/ipfs/QmZL8bPCwwUKvSRqJwkeYmTyXzDFgchDxXH4rMKxVjE7UQ?img-width=64',
        'tokenAge': '122d',
        'marketCap': '\$654.28K',
        'time': DateTime.now(),
      },
      {
        'walletAddress': '0x9a...0043',
        'walletName': '0x9a...0043',
        'avatar': 'https://pump.mypinata.cloud/ipfs/QmR7BRzAoLY9BfpKGXkPRxqaNt3AXsZGSQKVhFknzYqPjy?img-width=64',
        'action': 'add',
        'amount': '0.0614',
        'tokenSymbol': 'LA',
        'tokenIcon': 'https://pump.mypinata.cloud/ipfs/QmPGrciJwkDJAqBmQZ4N8RyHmGrMAaErPqW5ys3tAw3qAa?img-width=64',
        'tokenAge': '15d',
        'marketCap': '\$1.77M',
        'time': DateTime.now(),
      },
      {
        'walletAddress': '0xdb...4484',
        'walletName': 'SmartMoney',
        'avatar': 'https://pump.mypinata.cloud/ipfs/QmZL8bPCwwUKvSRqJwkeYmTyXzDFgchDxXH4rMKxVjE7UQ?img-width=64',
        'action': 'reduce',
        'amount': '0.69',
        'tokenSymbol': 'PIEVERSE',
        'tokenIcon': 'https://pump.mypinata.cloud/ipfs/QmNPuK8RSriVLrQxVmAqMXkpbqWe9pS1mKLqCrhb85b4uw?img-width=64',
        'tokenAge': '37d',
        'marketCap': '\$60.17M',
        'pnl': '+28.5%',
        'time': DateTime.now(),
      },
    ];

    // 随机选择一个活动
    final random = DateTime.now().millisecondsSinceEpoch % mockActivities.length;
    final activity = Map<String, dynamic>.from(mockActivities[random]);
    activity['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    activity['time'] = DateTime.now();
    addActivity(activity);
  }
}
