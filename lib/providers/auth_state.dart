import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/mock_api.dart';

/// 用户认证状态 - 只管理登录相关
class AuthState extends ChangeNotifier {
  final MockApi _api = MockApi();

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 登录
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.login(email, password);

    _isLoading = false;
    if (response.success) {
      _user = response.data;
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
    _error = null;
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
