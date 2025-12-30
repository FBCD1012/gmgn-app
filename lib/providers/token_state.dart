import 'package:flutter/foundation.dart';
import '../models/token.dart';
import '../models/trade_history.dart';
import '../services/mock_api.dart';

/// 代币状态 - 只管理代币相关
class TokenState extends ChangeNotifier {
  final MockApi _api = MockApi();

  List<Token> _hotTokens = [];
  bool _isLoading = false;
  List<TradeHistory> _tradeHistory = [];

  // Getters
  List<Token> get hotTokens => _hotTokens;
  bool get isLoading => _isLoading;
  List<TradeHistory> get tradeHistory => _tradeHistory;

  /// 加载热门代币
  Future<void> loadHotTokens({String? category}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.getHotTokens(category: category);

    _isLoading = false;
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
  Future<TradeResult?> buyToken({
    required String tokenId,
    required double amount,
    required String walletId,
    String? tokenSymbol,
    String? tokenName,
  }) async {
    final response = await _api.buyToken(
      tokenId: tokenId,
      amount: amount,
      walletId: walletId,
    );

    if (response.success && response.data != null) {
      _addTradeHistory(
        tokenId: tokenId,
        tokenSymbol: tokenSymbol ?? 'TOKEN',
        tokenName: tokenName ?? 'Token',
        type: TradeType.buy,
        bnbAmount: amount,
        tokenAmount: response.data!.tokenAmount,
        txHash: response.data!.txHash,
      );
      notifyListeners();
    }

    return response.data;
  }

  /// 卖出代币
  Future<TradeResult?> sellToken({
    required String tokenId,
    required double tokenAmount,
    required String walletId,
    String? tokenSymbol,
    String? tokenName,
  }) async {
    final response = await _api.sellToken(
      tokenId: tokenId,
      tokenAmount: tokenAmount,
      walletId: walletId,
    );

    if (response.success && response.data != null) {
      _addTradeHistory(
        tokenId: tokenId,
        tokenSymbol: tokenSymbol ?? 'TOKEN',
        tokenName: tokenName ?? 'Token',
        type: TradeType.sell,
        bnbAmount: response.data!.received ?? 0,
        tokenAmount: tokenAmount,
        txHash: response.data!.txHash,
      );
      notifyListeners();
    }

    return response.data;
  }

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

  /// 清除数据
  void clear() {
    _hotTokens = [];
    _tradeHistory = [];
    notifyListeners();
  }
}
