import 'package:flutter/foundation.dart';
import '../models/trader.dart';
import '../services/mock_api.dart';

/// 交易员状态 - 只管理交易员/排行榜相关
class TraderState extends ChangeNotifier {
  final MockApi _api = MockApi();

  List<Trader> _traders = [];
  List<Trader> _followedTraders = [];
  bool _isLoading = false;

  // Getters
  List<Trader> get traders => _traders;
  List<Trader> get followedTraders => _followedTraders;
  bool get isLoading => _isLoading;

  /// 加载排行榜
  Future<void> loadTraders({String category = 'hot', String period = '7d'}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.getLeaderboard(category: category, period: period);

    _isLoading = false;
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
      final updatedTrader = Trader(
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

      _traders[index] = updatedTrader;

      // 更新关注列表
      if (updatedTrader.isFollowing) {
        if (!_followedTraders.any((t) => t.id == traderId)) {
          _followedTraders.insert(0, updatedTrader);
        }
      } else {
        _followedTraders.removeWhere((t) => t.id == traderId);
      }

      notifyListeners();
      return true;
    }
    return false;
  }

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

  /// 清除数据
  void clear() {
    _traders = [];
    _followedTraders = [];
    notifyListeners();
  }
}
