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

  /// Add or update token holding after buying
  void addHolding({
    required String tokenId,
    required String symbol,
    required String name,
    required double amount,
    required double bnbCost,
  }) {
    if (_currentWallet == null) {
      // Create default wallet if not exists
      _currentWallet = Wallet(
        id: 'wallet_default',
        address: '0x89234f60876a79d78fe458d47184fa22a2634398',
        name: 'Wallet 1',
        balance: 1.0,
        chain: 'BSC',
        holdings: [],
      );
      _wallets = [_currentWallet!];
    }

    // Calculate value (mock price)
    final mockPrice = 0.0001; // Mock token price in USD
    final value = amount * mockPrice;

    // Check if token already exists in holdings
    final existingIndex = _currentWallet!.holdings.indexWhere((h) => h.tokenId == tokenId);

    List<TokenHolding> newHoldings = List.from(_currentWallet!.holdings);

    if (existingIndex >= 0) {
      // Update existing holding
      final existing = newHoldings[existingIndex];
      newHoldings[existingIndex] = TokenHolding(
        tokenId: tokenId,
        symbol: symbol,
        name: name,
        amount: existing.amount + amount,
        value: existing.value + value,
        profit: existing.profit,
        profitPercent: existing.profitPercent,
        logo: existing.logo,
        lastActive: DateTime.now(),
      );
    } else {
      // Add new holding
      newHoldings.insert(0, TokenHolding(
        tokenId: tokenId,
        symbol: symbol,
        name: name,
        amount: amount,
        value: value,
        profit: 0.0,
        profitPercent: 0.0,
        lastActive: DateTime.now(),
      ));
    }

    // Update wallet with new balance and holdings
    _currentWallet = Wallet(
      id: _currentWallet!.id,
      name: _currentWallet!.name,
      address: _currentWallet!.address,
      balance: _currentWallet!.balance - bnbCost,
      chain: _currentWallet!.chain,
      holdings: newHoldings,
    );

    final index = _wallets.indexWhere((w) => w.id == _currentWallet!.id);
    if (index >= 0) {
      _wallets[index] = _currentWallet!;
    }
    notifyListeners();
  }

  /// Update or remove token holding after selling
  void removeHolding({
    required String tokenId,
    required double amount,
    required double bnbReceived,
  }) {
    if (_currentWallet == null) return;

    final existingIndex = _currentWallet!.holdings.indexWhere((h) => h.tokenId == tokenId);
    if (existingIndex < 0) return;

    List<TokenHolding> newHoldings = List.from(_currentWallet!.holdings);
    final existing = newHoldings[existingIndex];

    final newAmount = existing.amount - amount;
    if (newAmount <= 0) {
      // Remove holding completely
      newHoldings.removeAt(existingIndex);
    } else {
      // Update holding
      final ratio = newAmount / existing.amount;
      newHoldings[existingIndex] = TokenHolding(
        tokenId: tokenId,
        symbol: existing.symbol,
        name: existing.name,
        amount: newAmount,
        value: existing.value * ratio,
        profit: existing.profit,
        profitPercent: existing.profitPercent,
        logo: existing.logo,
        lastActive: DateTime.now(),
      );
    }

    // Update wallet with new balance and holdings
    _currentWallet = Wallet(
      id: _currentWallet!.id,
      name: _currentWallet!.name,
      address: _currentWallet!.address,
      balance: _currentWallet!.balance + bnbReceived,
      chain: _currentWallet!.chain,
      holdings: newHoldings,
    );

    final index = _wallets.indexWhere((w) => w.id == _currentWallet!.id);
    if (index >= 0) {
      _wallets[index] = _currentWallet!;
    }
    notifyListeners();
  }
}
