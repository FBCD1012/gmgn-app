import 'dart:math';
import '../models/user.dart';
import '../models/wallet.dart';
import '../models/token.dart';
import '../models/trader.dart';
import '../models/kline.dart';

/// Mock API 服务 - 模拟后端接口
class MockApi {
  static final MockApi _instance = MockApi._internal();
  factory MockApi() => _instance;
  MockApi._internal();

  final Random _random = Random();

  // 模拟网络延迟
  Future<T> _delay<T>(T data, {int ms = 500}) async {
    await Future.delayed(Duration(milliseconds: ms));
    return data;
  }

  // ============ 用户相关 API ============

  /// 登录
  Future<ApiResponse<User>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Validate
    if (!email.contains('@')) {
      return ApiResponse.error('Invalid email format');
    }

    // 返回模拟用户
    return ApiResponse.success(User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      nickname: email.split('@')[0],
      avatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=$email',
      createdAt: DateTime.now(),
    ));
  }

  /// 注册
  Future<ApiResponse<User>> register(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!email.contains('@')) {
      return ApiResponse.error('Invalid email format');
    }
    if (password.length < 6) {
      return ApiResponse.error('Password must be at least 6 characters');
    }

    return ApiResponse.success(User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      nickname: email.split('@')[0],
      avatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=$email',
      createdAt: DateTime.now(),
    ));
  }

  /// 第三方登录
  Future<ApiResponse<User>> socialLogin(String provider) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final email = '${provider.toLowerCase()}_user_${_random.nextInt(1000)}@example.com';
    return ApiResponse.success(User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      nickname: '$provider User',
      avatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=$email',
      createdAt: DateTime.now(),
    ));
  }

  // ============ 钱包相关 API ============

  /// 获取用户钱包列表
  Future<ApiResponse<List<Wallet>>> getWallets() async {
    return _delay(ApiResponse.success([
      Wallet(
        id: 'wallet_1',
        address: '0x89234f60876a79d78fe458d47184fa22a2634398',
        name: 'Wallet 1',
        balance: 0.707,
        chain: 'BSC',
        holdings: _generateMockHoldings(),
      ),
    ]));
  }

  /// 获取钱包详情
  Future<ApiResponse<Wallet>> getWalletDetail(String walletId) async {
    return _delay(ApiResponse.success(Wallet(
      id: walletId,
      address: '0x89234f60876a79d78fe458d47184fa22a2634398',
      name: 'Wallet 1',
      balance: 0.707,
      chain: 'BSC',
      holdings: _generateMockHoldings(),
    )));
  }

  List<TokenHolding> _generateMockHoldings() {
    return [
      TokenHolding(
        tokenId: 'token_1',
        symbol: 'H',
        name: 'H Token',
        amount: 1000000,
        value: 488.89,
        profit: 1.18,
        profitPercent: 0.243,
        lastActive: DateTime.now().subtract(const Duration(seconds: 3)),
      ),
      TokenHolding(
        tokenId: 'token_2',
        symbol: 'NIGHT',
        name: 'Night Token',
        amount: 500000,
        value: 4.62,
        profit: 0.0226,
        profitPercent: 0.489,
        lastActive: DateTime.now().subtract(const Duration(seconds: 42)),
      ),
      TokenHolding(
        tokenId: 'token_3',
        symbol: 'BLUAI',
        name: 'BluAI',
        amount: 2000000,
        value: 138.24,
        profit: -0.87,
        profitPercent: -0.63,
        lastActive: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  // ============ 代币相关 API ============

  /// 获取热门代币列表
  Future<ApiResponse<List<Token>>> getHotTokens({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _delay(ApiResponse.success(_generateMockTokens()), ms: 300);
  }

  /// 获取代币详情
  Future<ApiResponse<Token>> getTokenDetail(String tokenId) async {
    final tokens = _generateMockTokens();
    final token = tokens.firstWhere(
      (t) => t.id == tokenId,
      orElse: () => tokens.first,
    );
    return _delay(ApiResponse.success(token));
  }

  /// 搜索代币
  Future<ApiResponse<List<Token>>> searchTokens(String keyword) async {
    final tokens = _generateMockTokens();
    final results = tokens.where((t) =>
        t.name.toLowerCase().contains(keyword.toLowerCase()) ||
        t.symbol.toLowerCase().contains(keyword.toLowerCase())).toList();
    return _delay(ApiResponse.success(results), ms: 200);
  }

  List<Token> _generateMockTokens() {
    return [
      Token(
        id: 'token_rzusd',
        address: '0x26...7777',
        name: 'RZUSD',
        symbol: 'RZUSD',
        logo: 'https://cryptologos.cc/logos/usd-coin-usdc-logo.png',
        price: 978600,
        marketCap: 9990000000000,
        volume24h: 1110000,
        priceChange24h: -0.3,
        holders: 24060,
        txCount: 1450,
        liquidity: 500000,
        isVerified: true,
        tags: ['-0%'],
        social: TokenSocial(twitter: '@rzusd', telegram: 't.me/rzusd'),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Token(
        id: 'token_cong',
        address: '0x24...4444',
        name: 'Satoshi BTC',
        symbol: 'SBTC',
        logo: 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
        price: 295590,
        marketCap: 879000000000,
        volume24h: 49000,
        priceChange24h: 0.2,
        holders: 5090,
        txCount: 49,
        liquidity: 180000,
        isVerified: false,
        tags: ['+0%'],
        social: TokenSocial(twitter: '@congbi'),
        createdAt: DateTime.now().subtract(const Duration(days: 65)),
      ),
      Token(
        id: 'token_myx',
        address: '0x59...4444',
        name: 'MYX',
        symbol: 'MYX',
        logo: 'https://cryptologos.cc/logos/chainlink-link-logo.png',
        price: 690110,
        marketCap: 3570000000,
        volume24h: 5750000,
        priceChange24h: -0.8,
        holders: 58400,
        txCount: 5750,
        liquidity: 350000,
        isVerified: true,
        tags: ['-0.8%'],
        createdAt: DateTime.now().subtract(const Duration(days: 238)),
      ),
      Token(
        id: 'token_jpmorgan',
        address: '0xab...8888',
        name: 'JPMorgan',
        symbol: 'JP',
        logo: 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
        price: 2680,
        marketCap: 2900000000,
        volume24h: 35000,
        priceChange24h: 0.1,
        holders: 21770,
        txCount: 35,
        liquidity: 80000,
        isVerified: false,
        tags: ['+0%'],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Token(
        id: 'token_apx',
        address: '0xcd...9999',
        name: 'APX',
        symbol: 'APX',
        logo: 'https://cryptologos.cc/logos/apecoin-ape-logo.png',
        price: 1540,
        marketCap: 2400000000,
        volume24h: 81000,
        priceChange24h: -0.3,
        holders: 14630,
        txCount: 81,
        liquidity: 120000,
        isVerified: true,
        tags: ['-0.3%'],
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Token(
        id: 'token_beat',
        address: '0xef...1111',
        name: 'Beat',
        symbol: 'BEAT',
        logo: 'https://cryptologos.cc/logos/solana-sol-logo.png',
        price: 15780000,
        marketCap: 1750000000,
        volume24h: 156000,
        priceChange24h: 2.5,
        holders: 8920,
        txCount: 156,
        liquidity: 280000,
        isVerified: true,
        tags: ['+2.5%'],
        social: TokenSocial(twitter: '@beattoken'),
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Token(
        id: 'token_xai',
        address: '0x12...2222',
        name: 'XAI',
        symbol: 'XAI',
        logo: 'https://cryptologos.cc/logos/arbitrum-arb-logo.png',
        price: 3040,
        marketCap: 1100000000,
        volume24h: 99000,
        priceChange24h: -0.3,
        holders: 29320,
        txCount: 99,
        liquidity: 150000,
        isVerified: true,
        tags: ['-0.3%'],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Token(
        id: 'token_pepe',
        address: '0x34...3333',
        name: 'PEPE',
        symbol: 'PEPE',
        logo: 'https://cryptologos.cc/logos/pepe-pepe-logo.png',
        price: 18200,
        marketCap: 890000000,
        volume24h: 2340000,
        priceChange24h: 5.8,
        holders: 45600,
        txCount: 2340,
        liquidity: 450000,
        isVerified: true,
        tags: ['+5.8%'],
        social: TokenSocial(twitter: '@pepecoin'),
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      Token(
        id: 'token_doge2',
        address: '0x56...5555',
        name: 'DOGE2.0',
        symbol: 'DOGE2',
        logo: 'https://cryptologos.cc/logos/dogecoin-doge-logo.png',
        price: 8760,
        marketCap: 560000000,
        volume24h: 890000,
        priceChange24h: -2.1,
        holders: 32100,
        txCount: 890,
        liquidity: 320000,
        isVerified: false,
        tags: ['-2.1%'],
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Token(
        id: 'token_shib',
        address: '0x78...6666',
        name: 'SHIBA',
        symbol: 'SHIB',
        logo: 'https://cryptologos.cc/logos/shiba-inu-shib-logo.png',
        price: 2450,
        marketCap: 420000000,
        volume24h: 1560000,
        priceChange24h: 3.2,
        holders: 67800,
        txCount: 1560,
        liquidity: 580000,
        isVerified: true,
        tags: ['+3.2%'],
        social: TokenSocial(twitter: '@shibatoken', telegram: 't.me/shiba'),
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      Token(
        id: 'token_floki',
        address: '0x9a...7777',
        name: 'FLOKI',
        symbol: 'FLOKI',
        logo: 'https://cryptologos.cc/logos/floki-inu-floki-logo.png',
        price: 15600,
        marketCap: 380000000,
        volume24h: 670000,
        priceChange24h: 1.5,
        holders: 28900,
        txCount: 670,
        liquidity: 290000,
        isVerified: true,
        tags: ['+1.5%'],
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      Token(
        id: 'token_wojak',
        address: '0xbc...8888',
        name: 'WOJAK',
        symbol: 'WOJAK',
        logo: 'https://cryptologos.cc/logos/avalanche-avax-logo.png',
        price: 4320,
        marketCap: 125000000,
        volume24h: 234000,
        priceChange24h: -4.5,
        holders: 12300,
        txCount: 234,
        liquidity: 98000,
        isVerified: false,
        tags: ['-4.5%'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Token(
        id: 'token_bonk',
        address: '0xde...9999',
        name: 'BONK',
        symbol: 'BONK',
        logo: 'https://cryptologos.cc/logos/bonk-bonk-logo.png',
        price: 890,
        marketCap: 98000000,
        volume24h: 456000,
        priceChange24h: 8.9,
        holders: 56700,
        txCount: 456,
        liquidity: 180000,
        isVerified: true,
        tags: ['+8.9%'],
        social: TokenSocial(twitter: '@bonktoken'),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Token(
        id: 'token_ai',
        address: '0xf0...aaaa',
        name: 'AI Protocol',
        symbol: 'AIP',
        logo: 'https://cryptologos.cc/logos/render-token-rndr-logo.png',
        price: 45600,
        marketCap: 78000000,
        volume24h: 123000,
        priceChange24h: 12.3,
        holders: 8900,
        txCount: 123,
        liquidity: 65000,
        isVerified: true,
        tags: ['+12.3%'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Token(
        id: 'token_trump',
        address: '0x11...bbbb',
        name: 'TRUMP',
        symbol: 'TRUMP',
        logo: 'https://cryptologos.cc/logos/tron-trx-logo.png',
        price: 67800,
        marketCap: 56000000,
        volume24h: 890000,
        priceChange24h: -6.7,
        holders: 34500,
        txCount: 890,
        liquidity: 120000,
        isVerified: false,
        tags: ['-6.7%'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  // ============ 交易相关 API ============

  /// 买入代币
  Future<ApiResponse<TradeResult>> buyToken({
    required String tokenId,
    required double amount,
    required String walletId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    // 模拟交易
    return ApiResponse.success(TradeResult(
      txHash: '0x${_generateRandomHex(64)}',
      status: 'success',
      tokenAmount: amount * 1000000,
      spent: amount,
      fee: amount * 0.003,
    ));
  }

  /// 卖出代币
  Future<ApiResponse<TradeResult>> sellToken({
    required String tokenId,
    required double tokenAmount,
    required String walletId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    return ApiResponse.success(TradeResult(
      txHash: '0x${_generateRandomHex(64)}',
      status: 'success',
      tokenAmount: tokenAmount,
      received: tokenAmount * 0.00001,
      fee: tokenAmount * 0.00001 * 0.003,
    ));
  }

  // ============ 跟单相关 API ============

  /// 获取排行榜
  Future<ApiResponse<List<Trader>>> getLeaderboard({
    String category = 'hot',
    String period = '7d',
    int page = 1,
  }) async {
    return _delay(ApiResponse.success(_generateMockTraders()), ms: 400);
  }

  /// 获取交易者详情
  Future<ApiResponse<Trader>> getTraderDetail(String traderId) async {
    final traders = _generateMockTraders();
    final trader = traders.firstWhere(
      (t) => t.id == traderId,
      orElse: () => traders.first,
    );
    return _delay(ApiResponse.success(trader));
  }

  /// 关注交易者
  Future<ApiResponse<bool>> followTrader(String traderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success(true);
  }

  /// 取消关注
  Future<ApiResponse<bool>> unfollowTrader(String traderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success(true);
  }

  /// 设置跟单
  Future<ApiResponse<CopyTradeConfig>> setupCopyTrade({
    required String traderId,
    required double amount,
    required double maxPerTrade,
    required double stopLoss,
    required double takeProfit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return ApiResponse.success(CopyTradeConfig(
      id: 'copy_${DateTime.now().millisecondsSinceEpoch}',
      traderId: traderId,
      amount: amount,
      maxPerTrade: maxPerTrade,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      isActive: true,
      createdAt: DateTime.now(),
    ));
  }

  List<Trader> _generateMockTraders() {
    return [
      Trader(
        id: 'trader_1',
        address: '0xcc1234567890abcdef1234567890abcdef8741',
        nickname: 'Crypto Veteran',
        rank: 1,
        profit7d: 18696.62,
        profitPercent7d: 156.8,
        tradeCount7d: 14313,
        winRate: 72.96,
        followers: 1,
        followedBy: 3,
        balance: 0.707,
        holdings: _generateTraderHoldings(),
      ),
      Trader(
        id: 'trader_2',
        address: '0xdb1234567890abcdef1234567890abcdefb5fe',
        rank: 2,
        profit7d: 9902.22,
        profitPercent7d: 89.5,
        tradeCount7d: 8956,
        winRate: 68.2,
        followers: 1,
        followedBy: 2,
        balance: 1.234,
        holdings: _generateTraderHoldings(),
      ),
      Trader(
        id: 'trader_3',
        address: '0x9a1234567890abcdef1234567890abcdef0043',
        rank: 3,
        profit7d: 9456.38,
        profitPercent7d: 78.3,
        tradeCount7d: 7234,
        winRate: 65.8,
        followers: 2,
        followedBy: 1,
        balance: 0.892,
        holdings: _generateTraderHoldings(),
      ),
      Trader(
        id: 'trader_4',
        address: '0xdb1234567890abcdef1234567890abcdef4484',
        rank: 4,
        profit7d: 9333.35,
        profitPercent7d: 72.1,
        tradeCount7d: 6521,
        winRate: 63.5,
        followers: 1,
        followedBy: 3,
        balance: 0.567,
      ),
      Trader(
        id: 'trader_5',
        address: '0x0a1234567890abcdef1234567890abcdeff7b7',
        rank: 5,
        profit7d: 8969.34,
        profitPercent7d: 68.9,
        tradeCount7d: 5890,
        winRate: 61.2,
        followers: 1,
        followedBy: 1,
        balance: 0.445,
      ),
      Trader(
        id: 'trader_6',
        address: '0x1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c',
        nickname: 'Diamond Hands',
        rank: 6,
        profit7d: 8234.56,
        profitPercent7d: 62.3,
        tradeCount7d: 4521,
        winRate: 59.8,
        followers: 3,
        followedBy: 5,
        balance: 2.345,
      ),
      Trader(
        id: 'trader_7',
        address: '0x2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d',
        nickname: 'Whale Hunter',
        rank: 7,
        profit7d: 7856.23,
        profitPercent7d: 58.7,
        tradeCount7d: 3890,
        winRate: 57.4,
        followers: 2,
        followedBy: 4,
        balance: 1.876,
      ),
      Trader(
        id: 'trader_8',
        address: '0x3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e',
        nickname: 'Moon Boy',
        rank: 8,
        profit7d: 7234.89,
        profitPercent7d: 54.2,
        tradeCount7d: 3456,
        winRate: 55.6,
        followers: 4,
        followedBy: 6,
        balance: 0.998,
      ),
      Trader(
        id: 'trader_9',
        address: '0x4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f',
        nickname: 'Alpha Seeker',
        rank: 9,
        profit7d: 6789.45,
        profitPercent7d: 51.8,
        tradeCount7d: 2987,
        winRate: 53.2,
        followers: 1,
        followedBy: 2,
        balance: 0.654,
      ),
      Trader(
        id: 'trader_10',
        address: '0x5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a',
        nickname: 'Degen King',
        rank: 10,
        profit7d: 6345.67,
        profitPercent7d: 48.9,
        tradeCount7d: 2654,
        winRate: 51.7,
        followers: 5,
        followedBy: 8,
        balance: 1.234,
      ),
      Trader(
        id: 'trader_11',
        address: '0x6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b',
        nickname: 'Smart Money',
        rank: 11,
        profit7d: 5987.23,
        profitPercent7d: 46.5,
        tradeCount7d: 2345,
        winRate: 50.3,
        followers: 2,
        followedBy: 3,
        balance: 0.876,
      ),
      Trader(
        id: 'trader_12',
        address: '0x7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c',
        nickname: 'Crypto Ninja',
        rank: 12,
        profit7d: 5654.89,
        profitPercent7d: 44.2,
        tradeCount7d: 2123,
        winRate: 49.1,
        followers: 3,
        followedBy: 4,
        balance: 0.567,
      ),
      Trader(
        id: 'trader_13',
        address: '0x8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d',
        nickname: 'Bull Runner',
        rank: 13,
        profit7d: 5234.56,
        profitPercent7d: 41.8,
        tradeCount7d: 1987,
        winRate: 47.8,
        followers: 1,
        followedBy: 2,
        balance: 0.432,
      ),
      Trader(
        id: 'trader_14',
        address: '0x9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e',
        nickname: 'Gem Finder',
        rank: 14,
        profit7d: 4876.34,
        profitPercent7d: 39.5,
        tradeCount7d: 1765,
        winRate: 46.2,
        followers: 2,
        followedBy: 3,
        balance: 0.321,
      ),
      Trader(
        id: 'trader_15',
        address: '0x0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f',
        nickname: 'WAGMI Trader',
        rank: 15,
        profit7d: 4523.12,
        profitPercent7d: 37.2,
        tradeCount7d: 1543,
        winRate: 44.9,
        followers: 4,
        followedBy: 5,
        balance: 0.789,
      ),
      Trader(
        id: 'trader_16',
        address: '0x1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a',
        rank: 16,
        profit7d: 4234.78,
        profitPercent7d: 35.6,
        tradeCount7d: 1432,
        winRate: 43.5,
        followers: 1,
        followedBy: 2,
        balance: 0.456,
      ),
      Trader(
        id: 'trader_17',
        address: '0x2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b',
        nickname: 'Ape Master',
        rank: 17,
        profit7d: 3987.45,
        profitPercent7d: 33.4,
        tradeCount7d: 1298,
        winRate: 42.1,
        followers: 2,
        followedBy: 3,
        balance: 0.234,
      ),
      Trader(
        id: 'trader_18',
        address: '0x3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c',
        nickname: 'Profit King',
        rank: 18,
        profit7d: 3654.23,
        profitPercent7d: 31.2,
        tradeCount7d: 1165,
        winRate: 40.8,
        followers: 3,
        followedBy: 4,
        balance: 0.567,
      ),
      Trader(
        id: 'trader_19',
        address: '0x4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d',
        rank: 19,
        profit7d: 3345.67,
        profitPercent7d: 29.8,
        tradeCount7d: 1032,
        winRate: 39.4,
        followers: 1,
        followedBy: 1,
        balance: 0.123,
      ),
      Trader(
        id: 'trader_20',
        address: '0x5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e',
        nickname: 'LFG Legend',
        rank: 20,
        profit7d: 3012.34,
        profitPercent7d: 27.5,
        tradeCount7d: 923,
        winRate: 38.1,
        followers: 2,
        followedBy: 2,
        balance: 0.345,
      ),
    ];
  }

  List<TraderHolding> _generateTraderHoldings() {
    return [
      TraderHolding(
        symbol: 'H',
        name: 'H Token',
        balance: 0,
        value: 488.89,
        profit: 1.18,
        profitPercent: 0.243,
        duration: '3s',
      ),
      TraderHolding(
        symbol: 'NIGHT',
        name: 'Night',
        balance: 0,
        value: 4.62,
        profit: 0.0226,
        profitPercent: 0.489,
        duration: '42s',
      ),
      TraderHolding(
        symbol: 'BLUAI',
        name: 'BluAI',
        balance: 0,
        value: 138.24,
        profit: -0.87,
        profitPercent: -0.63,
        duration: '2m',
      ),
    ];
  }

  String _generateRandomHex(int length) {
    const chars = '0123456789abcdef';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  // ============ K线数据 API ============

  /// 获取K线数据
  Future<ApiResponse<List<KLineData>>> getKLineData({
    required String tokenId,
    String interval = '1d', // 1s, 30s, 1m, 1h, 1d
    int limit = 100,
  }) async {
    return _delay(ApiResponse.success(_generateMockKLineData(interval, limit)), ms: 300);
  }

  List<KLineData> _generateMockKLineData(String interval, int limit) {
    List<KLineData> data = [];
    DateTime now = DateTime.now();
    double basePrice = 0.00011; // 基础价格

    Duration duration;
    switch (interval) {
      case '1s':
        duration = const Duration(seconds: 1);
        break;
      case '30s':
        duration = const Duration(seconds: 30);
        break;
      case '1m':
        duration = const Duration(minutes: 1);
        break;
      case '1h':
        duration = const Duration(hours: 1);
        break;
      case '1d':
      default:
        duration = const Duration(days: 1);
    }

    for (int i = limit - 1; i >= 0; i--) {
      DateTime time = now.subtract(duration * i);

      // 模拟价格波动
      double volatility = 0.05 + _random.nextDouble() * 0.1;
      double trend = _random.nextDouble() > 0.5 ? 1 : -1;

      double open = basePrice * (1 + (_random.nextDouble() - 0.5) * volatility);
      double close = open * (1 + trend * _random.nextDouble() * volatility);
      double high = (open > close ? open : close) * (1 + _random.nextDouble() * 0.02);
      double low = (open < close ? open : close) * (1 - _random.nextDouble() * 0.02);
      double volume = 10000 + _random.nextDouble() * 90000;

      data.add(KLineData(
        time: time,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      basePrice = close; // 下一根K线的基础价格
    }

    return data;
  }

  /// 获取代币详细信息
  Future<ApiResponse<TokenDetail>> getTokenDetailInfo(String tokenId) async {
    return _delay(ApiResponse.success(_generateMockTokenDetail(tokenId)), ms: 200);
  }

  TokenDetail _generateMockTokenDetail(String tokenId) {
    return TokenDetail(
      id: tokenId,
      name: 'XAI',
      symbol: 'XAI',
      address: '0x30c9a4a6f2ea3e8e1234567890abcdef7148',
      price: 0.00011028,
      priceChange24h: -2.02,
      marketCap: 1100000000, // 1.1B
      volume24h: 3830,
      poolLiquidity: 119010,
      top10Percent: 0.1,
      holders: 29320,
      dexPaid: 0,
      mouseWarehouse: 0,
      devHolding: 0,
      tags: ['Verified'],
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }
}

/// API 响应包装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse._({required this.success, this.data, this.error});

  factory ApiResponse.success(T data) {
    return ApiResponse._(success: true, data: data);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse._(success: false, error: message);
  }
}

/// 交易结果
class TradeResult {
  final String txHash;
  final String status;
  final double tokenAmount;
  final double? spent;
  final double? received;
  final double fee;
  final bool success;
  final String? message;
  final double? bnbAmount;

  TradeResult({
    required this.txHash,
    required this.status,
    required this.tokenAmount,
    this.spent,
    this.received,
    required this.fee,
    this.success = true,
    this.message,
    this.bnbAmount,
  });
}

/// 跟单配置
class CopyTradeConfig {
  final String id;
  final String traderId;
  final double amount;
  final double maxPerTrade;
  final double stopLoss;
  final double takeProfit;
  final bool isActive;
  final DateTime createdAt;

  CopyTradeConfig({
    required this.id,
    required this.traderId,
    required this.amount,
    required this.maxPerTrade,
    required this.stopLoss,
    required this.takeProfit,
    required this.isActive,
    required this.createdAt,
  });
}
