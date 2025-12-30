import 'package:flutter/foundation.dart';
import '../models/wallet.dart';
import '../services/mock_api.dart';

/// 钱包状态 - 只管理钱包相关
class WalletState extends ChangeNotifier {
  final MockApi _api = MockApi();

  List<Wallet> _wallets = [];
  Wallet? _currentWallet;
  bool _isLoading = false;

  // Getters
  List<Wallet> get wallets => _wallets;
  Wallet? get currentWallet => _currentWallet;
  double get totalBalance => _wallets.fold(0, (sum, w) => sum + w.balance);
  bool get isLoading => _isLoading;

  /// 加载钱包列表
  Future<void> loadWallets() async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.getWallets();

    _isLoading = false;
    if (response.success && response.data != null) {
      _wallets = response.data!;
      if (_wallets.isNotEmpty && _currentWallet == null) {
        _currentWallet = _wallets.first;
      }
    }
    notifyListeners();
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

  /// 充值 BNB
  Future<bool> deposit(double amount) async {
    if (_currentWallet == null) return false;

    final updatedWallet = Wallet(
      id: _currentWallet!.id,
      name: _currentWallet!.name,
      address: _currentWallet!.address,
      balance: _currentWallet!.balance + amount,
      chain: _currentWallet!.chain,
      holdings: _currentWallet!.holdings,
    );

    _currentWallet = updatedWallet;
    final index = _wallets.indexWhere((w) => w.id == updatedWallet.id);
    if (index >= 0) {
      _wallets[index] = updatedWallet;
    }
    notifyListeners();
    return true;
  }

  /// 切换当前钱包
  void setCurrentWallet(Wallet wallet) {
    _currentWallet = wallet;
    notifyListeners();
  }

  /// 清除钱包数据（登出时调用）
  void clear() {
    _wallets = [];
    _currentWallet = null;
    notifyListeners();
  }
}
