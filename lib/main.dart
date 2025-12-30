import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'models/token.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/asset_screen.dart';
import 'screens/monitor_screen.dart';
import 'screens/copy_trade_screen.dart';
import 'screens/trade_history_screen.dart';
import 'widgets/app_header.dart';
import 'widgets/promo_banner.dart';
import 'widgets/app_tabs.dart';
import 'widgets/app_filters.dart';
import 'widgets/token_card.dart';
import 'widgets/deposit_sheet.dart';
import 'widgets/login_prompt.dart';
import 'widgets/animated_dogecoin.dart';
import 'widgets/shimmer_loading.dart';
import 'components/components.dart';
import 'services/image_cache_config.dart';

// Theme colors - GMGN original colors
const Color kPrimaryColor = GColors.primary;
const Color kBackgroundColor = Color(0xFF000000);  // Pure black bg
const Color kCardColor = Color(0xFF1C1C1E);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化图片缓存配置
  ImageCacheConfig.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kBackgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        // 核心状态 - 拆分后更精确的状态管理
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => WalletState()),
        ChangeNotifierProvider(create: (_) => TokenState()),
        ChangeNotifierProvider(create: (_) => TraderState()),
        // 保留原 AppState 用于复杂跟单功能
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const GMGNApp(),
    ),
  );
}

class GMGNApp extends StatelessWidget {
  const GMGNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GMGN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: kPrimaryColor,
          secondary: const Color(0xFFF97316),
          surface: kBackgroundColor,
        ),
        scaffoldBackgroundColor: kBackgroundColor,
        fontFamily: 'SF Pro Display',
      ),
      builder: (context, child) {
        // Global MediaQuery lock - keyboard won't affect any layout
        final originalMediaQuery = MediaQuery.of(context);
        final fixedMediaQuery = originalMediaQuery.copyWith(
          viewInsets: EdgeInsets.zero, // Always zero, ignore keyboard
        );
        return MediaQuery(
          data: fixedMediaQuery,
          child: child!,
        );
      },
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 使用拆分后的 Provider 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TokenState>().loadHotTokens();
      context.read<TraderState>().loadTraders();
      context.read<WalletState>().loadWallets();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _handleLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _handleRegister() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 AuthState 监听登录状态
    return Selector<AuthState, bool>(
      selector: (_, state) => state.isLoggedIn,
      builder: (context, isLoggedIn, child) {
        return Scaffold(
          backgroundColor: kBackgroundColor,
          body: Stack(
            children: [
              // 主内容区域
              SafeArea(
                bottom: false,
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    // Home (Discover)
                    const _HomeScreen(),
                    // Copy Trade
                    isLoggedIn
                        ? const CopyTradeScreen()
                        : _buildNeedLoginScreen(const CopyTradeScreen()),
                    // Trade History
                    isLoggedIn
                        ? const TradeHistoryScreen()
                        : _buildNeedLoginScreen(const TradeHistoryScreen()),
                    // Monitor
                    isLoggedIn
                        ? const MonitorScreen()
                        : _buildNeedLoginScreen(const MonitorScreen()),
                    // Assets
                    isLoggedIn
                        ? const AssetScreen()
                        : _buildNeedLoginScreen(const AssetScreen()),
                  ],
                ),
              ),
              // 浮动底部导航栏
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomNav(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeedLoginScreen(Widget child) {
    return Stack(
      children: [
        child,
        LoginPrompt(
          onLogin: _handleLogin,
          onRegister: _handleRegister,
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.layers_outlined, Icons.layers, 'Discover'),
            _buildNavItem(1, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Copy Trade'),
            _buildNavItem(2, Icons.trending_up, Icons.trending_up, 'Trade'),
            _buildNavItem(
                3, Icons.location_on_outlined, Icons.location_on, 'Monitor'),
            _buildNavItem(4, Icons.apartment_outlined, Icons.apartment, 'Assets'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? kPrimaryColor : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: isSelected ? kPrimaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Optimized Home Screen - using split providers for precise rebuilds
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // 使用拆分后的 TokenState
              await context.read<TokenState>().loadHotTokens();
            },
            color: kPrimaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Hero section - 使用 AuthState 和 WalletState
                SliverToBoxAdapter(
                  child: Consumer2<AuthState, WalletState>(
                    builder: (context, authState, walletState, _) {
                      if (authState.isLoggedIn) {
                        return _LoggedInHero(balance: walletState.totalBalance);
                      }
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: const PromoBanner(),
                      );
                    },
                  ),
                ),
                // Tabs
                const SliverToBoxAdapter(child: AppTabs()),
                SliverToBoxAdapter(
                  child: Container(height: 1, color: const Color(0xFF1C1C1E)),
                ),
                // Filters
                const SliverToBoxAdapter(child: AppFilters()),
                // 表头
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Left column header
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Token / Time / Holders',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ),
                        // Middle column header
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Vol / Txns',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right column header
                        Expanded(
                          flex: 3,
                          child: Text(
                            'MCap / 1h%',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Token list - 使用拆分后的 TokenState
                Selector<TokenState, ({bool isLoading, List<Token> tokens})>(
                  selector: (_, state) => (isLoading: state.isLoading, tokens: state.hotTokens),
                  builder: (context, data, _) {
                    if (data.isLoading) {
                      return const SliverToBoxAdapter(child: ShimmerLoading());
                    }
                    return SliverList.builder(
                      itemCount: data.tokens.length + 1,
                      itemBuilder: (context, index) {
                        if (index == data.tokens.length) {
                          return const SizedBox(height: 100);
                        }
                        final token = data.tokens[index];
                        return RepaintBoundary(
                          child: TokenCard(
                            token: TokenData(
                              id: token.id,
                              name: token.name,
                              symbol: token.symbol,
                              price: token.formattedPrice,
                              marketCap: token.formattedMarketCap,
                              fee: '0.1',
                              tx: token.formattedTxCount,
                              time: _formatTime(token.createdAt),
                              holders: token.holders,
                              comments: 0,
                              ratio: '1/1',
                              badges: token.tags,
                              txPositive: token.priceChange24h >= 0,
                              hasVerified: token.isVerified,
                              imageUrl: token.logo,
                              // 新增三列布局字段
                              volume: token.formattedVolume,
                              txCount: token.formattedTxCount,
                              changePercent: token.formattedPriceChange,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// Logged in hero section - extracted for const optimization
class _LoggedInHero extends StatelessWidget {
  final double balance;

  const _LoggedInHero({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background dog animation - RepaintBoundary 隔离动画重绘
          const Positioned(
            right: 0,
            top: 10,
            child: RepaintBoundary(
              child: AnimatedDogecoin(
                size: 140,
                opacity: 0.2,
              ),
            ),
          ),
          // Content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.visibility_outlined,
                            size: 16, color: Colors.grey[500]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          balance.toStringAsFixed(3),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Row(
                          children: [
                            _BNBIcon(),
                            SizedBox(width: 4),
                            Text(
                              'BNB',
                              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => DepositSheet.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.download, size: 18, color: Colors.black),
                      SizedBox(width: 6),
                      Text(
                        'Deposit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BNBIcon extends StatelessWidget {
  const _BNBIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Color(0xFFF0B90B),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.diamond_outlined, size: 12, color: Colors.white),
    );
  }
}
