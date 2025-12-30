import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
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
import 'components/components.dart';

// 使用组件库的主题色 - GMGN 原版配色
const Color kPrimaryColor = GColors.primary;
const Color kBackgroundColor = Color(0xFF000000);  // 纯黑背景
const Color kCardColor = Color(0xFF1C1C1E);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kBackgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
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
    // 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadHotTokens();
      context.read<AppState>().loadTraders();
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
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isLoggedIn = appState.isLoggedIn;

        return Scaffold(
          backgroundColor: kBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: [
                // 首页 (发现)
                _buildHomeScreen(appState),
                // 钱包跟单
                isLoggedIn
                    ? const CopyTradeScreen()
                    : _buildNeedLoginScreen(const CopyTradeScreen()),
                // 交易 (跟单记录)
                isLoggedIn
                    ? const TradeHistoryScreen()
                    : _buildNeedLoginScreen(const TradeHistoryScreen()),
                // 监控
                isLoggedIn
                    ? const MonitorScreen()
                    : _buildNeedLoginScreen(const MonitorScreen()),
                // 资产
                isLoggedIn
                    ? const AssetScreen()
                    : _buildNeedLoginScreen(const AssetScreen()),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
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

  Widget _buildHomeScreen(AppState appState) {
    return Stack(
      children: [
        // 主内容
        Column(
          children: [
            const AppHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await appState.loadHotTokens();
                },
                color: kPrimaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Hero section
                      if (appState.isLoggedIn)
                        _buildLoggedInHero(appState)
                      else
                        GestureDetector(
                          onTap: _handleLogin,
                          child: const PromoBanner(),
                        ),
                      // Tabs
                      const AppTabs(),
                      Container(height: 1, color: const Color(0xFF1C1C1E)),
                      // Filters
                      const AppFilters(),
                      // Token list
                      if (appState.isLoadingTokens)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: kPrimaryColor),
                        )
                      else
                        ...appState.hotTokens.map((token) => TokenCard(
                              token: TokenData(
                                id: token.id,
                                name: token.name,
                                symbol: token.symbol,
                                price: token.formattedPrice,
                                marketCap: token.formattedMarketCap,
                                fee: '0.1',
                                tx: '${(token.txCount / 1000).toStringAsFixed(2)}K',
                                time: _formatTime(token.createdAt),
                                holders: token.holders,
                                comments: 0,
                                ratio: '1/1',
                                badges: token.tags,
                                txPositive: token.priceChange24h >= 0,
                                hasVerified: token.isVerified,
                                imageUrl: token.logo,
                              ),
                            )),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Widget _buildLoggedInHero(AppState appState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '总余额',
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
                      appState.totalBalance.toStringAsFixed(3),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0B90B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.diamond_outlined,
                              size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'BNB',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                    '充值',
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
    );
  }

  Widget _buildBottomNav() {
    return Container(
      color: const Color(0xFF000000),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.layers_outlined, Icons.layers, '发现'),
              _buildNavItem(1, Icons.cases_outlined, Icons.cases, '钱包跟单'),
              _buildNavItem(2, Icons.trending_up, Icons.trending_up, '交易'),
              _buildNavItem(
                  3, Icons.location_on_outlined, Icons.location_on, '监控'),
              _buildNavItem(4, Icons.apartment_outlined, Icons.apartment, '资产'),
            ],
          ),
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
