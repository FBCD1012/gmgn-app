import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/trader.dart';
import '../models/copy_trade.dart';
import '../widgets/deposit_sheet.dart';
import 'trader_detail_screen.dart';

// 颜色常量
const Color _kPrimaryGreen = Color(0xFF00D26A);
const Color _kOrange = Color(0xFFF97316);
const Color _kBackgroundColor = Color(0xFF0D0D0D);
const Color _kCardColor = Color(0xFF1A1A1A);
const Color _kBorderColor = Color(0xFF333333);
const Color _kGoldColor = Color(0xFFD4AF37);
const Color _kSilverColor = Color(0xFF8A8A8A);
const Color _kBronzeColor = Color(0xFFCD7F32);
const Color _kCyan = Color(0xFF5CE1D6);

class CopyTradeScreen extends StatefulWidget {
  const CopyTradeScreen({super.key});

  @override
  State<CopyTradeScreen> createState() => _CopyTradeScreenState();
}

class _CopyTradeScreenState extends State<CopyTradeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _activityTimer;

  // 钱包跟单 sub tab
  int _walletSubTab = 0; // 0: 当前跟单, 1: 历史跟单

  // 牛人榜 filters
  int _rankSubTab = 0; // 热门榜, 全部, KOL, 聪明钱, 内盘聪明钱, 新
  int _rankTimeRange = 1; // 0: 1D, 1: 7D, 2: 30D

  // 活动 filters
  int _activitySubTab = 0; // 全部, 默认

  // 关注 filters
  int _followSubTab = 0; // 全部, 默认(0)
  int _followTimeRange = 2; // 30D

  // 备注 filters
  int _noteTimeRange = 2; // 30D

  final List<String> _mainTabs = ['钱包跟单', '牛人榜', '活动', '关注', '备注'];
  final List<String> _rankSubTabs = ['热门榜', '全部', 'KOL', '聪明钱', '内盘聪明钱', '新'];
  final List<String> _timeRanges = ['1D', '7D', '30D'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _mainTabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
      // 切换到活动 Tab 时清除未读数
      if (_tabController.index == 2) {
        context.read<AppState>().clearUnreadActivityCount();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadTraders();
      // 启动活动推送定时器 - 每3秒推送一条
      _startActivityTimer();
    });
  }

  void _startActivityTimer() {
    _activityTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        context.read<AppState>().generateMockActivity();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final traders = appState.traders;
        final isLoading = appState.isLoadingTraders;
        final balance = appState.totalBalance;

        return Scaffold(
          backgroundColor: _kBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Main Tab Bar
                    _buildMainTabBar(),
                    // Content based on selected tab
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: _kCyan),
                            )
                          : _buildTabContent(traders),
                    ),
                  ],
                ),
                // 底部充值提示横幅
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildDepositBanner(balance),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainTabBar() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          height: 44,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF262626), width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: _mainTabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              // 活动 tab (index 2) 显示小红心徽章
              if (index == 2 && appState.unreadActivityCount > 0) {
                return Tab(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(tab),
                      Positioned(
                        right: -16,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4D6A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
                          child: Center(
                            child: Text(
                              appState.unreadActivityCount > 99
                                  ? '99+'
                                  : '${appState.unreadActivityCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Tab(text: tab);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTabContent(List<Trader> traders) {
    switch (_tabController.index) {
      case 0:
        return _buildWalletCopyTab();
      case 1:
        return _buildRankTab(traders);
      case 2:
        return _buildActivityTab(traders);
      case 3:
        return _buildFollowTab();
      case 4:
        return _buildNoteTab();
      default:
        return _buildWalletCopyTab();
    }
  }

  // ==================== 钱包跟单 Tab ====================
  Widget _buildWalletCopyTab() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final currentTrades = _walletSubTab == 0
            ? appState.activeCopyTrades
            : appState.historyCopyTrades;

        return Column(
          children: [
            // Sub tabs: 当前跟单, 历史跟单 + 新建按钮 + 粉色小鸟图标
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildWalletSubTab('当前跟单', 0),
                  const SizedBox(width: 8),
                  _buildWalletSubTab('历史跟单', 1),
                  const SizedBox(width: 8),
                  // 粉色小鸟图标
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF69B4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('🐦', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showNewCopyTradeDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kCardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            '新建',
                            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 跟单列表或空状态
            Expanded(
              child: currentTrades.isEmpty
                  ? _buildEmptyState(
                      _walletSubTab == 0 ? '暂无跟单' : '暂无历史跟单',
                      '发现顶级牛人钱包',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: currentTrades.length + 1, // +1 for "到底了"
                      itemBuilder: (context, index) {
                        if (index == currentTrades.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                '到底了',
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }
                        return _buildCopyTradeCard(currentTrades[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // 跟单卡片
  Widget _buildCopyTradeCard(CopyTrade trade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像 + 地址 + 钱包名
          Row(
            children: [
              // 头像
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: trade.avatarColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: trade.traderAvatar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          trade.traderAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              trade.traderAddress.substring(2, 4).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          trade.traderAddress.substring(2, 4).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // 地址信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          trade.displayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.edit, size: 14, color: Colors.grey[600]),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          trade.shortAddress,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _copyAddress(trade.traderAddress),
                          child: Icon(Icons.copy, size: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 更多按钮 + 钱包名
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('--', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _kBorderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trade.walletName,
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 配置信息展示
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // 跟单金额
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '跟单金额',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trade.configuredAmountText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF0B90B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 加仓次数
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '加仓次数',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trade.positionCountText,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // 自动跟卖
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '自动跟卖',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: trade.autoFollowSell
                                  ? _kPrimaryGreen.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              trade.autoFollowSell ? '开启' : '关闭',
                              style: TextStyle(
                                fontSize: 12,
                                color: trade.autoFollowSell ? _kPrimaryGreen : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // 跟单买/卖
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '跟单买/卖',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${trade.buyCount} / ${trade.sellCount}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _kPrimaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 总买入/总卖出
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '总买入/总卖出',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${trade.totalBuyText} / ${trade.totalSellText}',
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // 最近交易时间
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '最近交易',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trade.lastTradeTimeText,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: _buildActionButton('分享', Icons.share, () => _shareCopyTrade(trade)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  trade.isPaused ? '恢复' : '暂停',
                  trade.isPaused ? Icons.play_arrow : Icons.pause,
                  () => _togglePauseCopyTrade(trade),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('详情', Icons.info_outline, () => _showCopyTradeDetail(trade)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _kBorderColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('地址已复制'),
        backgroundColor: _kPrimaryGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareCopyTrade(CopyTrade trade) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('分享功能即将上线'),
        backgroundColor: _kOrange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _togglePauseCopyTrade(CopyTrade trade) {
    final appState = context.read<AppState>();
    if (trade.isPaused) {
      appState.resumeCopyTradeItem(trade.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已恢复跟单'),
          backgroundColor: _kPrimaryGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      appState.pauseCopyTradeItem(trade.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已暂停跟单'),
          backgroundColor: Colors.grey[700],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCopyTradeDetail(CopyTrade trade) {
    // TODO: 显示跟单详情配置页面
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCopyTradeDetailSheet(trade),
    );
  }

  Widget _buildCopyTradeDetailSheet(CopyTrade trade) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                const Text(
                  '跟单详情',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _kBorderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          // 内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 跟单地址
                  _buildDetailSection('跟单地址', trade.displayName),
                  _buildDetailSection('钱包', trade.walletName),
                  const SizedBox(height: 16),
                  const Divider(color: _kBorderColor),
                  const SizedBox(height: 16),
                  // 跟单统计
                  Text('跟单统计', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard('跟单买入', '${trade.buyCount}次'),
                      const SizedBox(width: 12),
                      _buildStatCard('跟单卖出', '${trade.sellCount}次'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard('总买入', trade.totalBuyText),
                      const SizedBox(width: 12),
                      _buildStatCard('总卖出', trade.totalSellText),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _togglePauseCopyTrade(trade);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: trade.isPaused ? _kPrimaryGreen : _kBorderColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                trade.isPaused ? '恢复跟单' : '暂停跟单',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: trade.isPaused ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<AppState>().stopCopyTradeItem(trade.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('已停止跟单'),
                                backgroundColor: Color(0xFFEF4444),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '停止跟单',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSubTab(String text, int index) {
    final isSelected = _walletSubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _walletSubTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : _kCardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: _kBorderColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  // ==================== 牛人榜 Tab ====================
  Widget _buildRankTab(List<Trader> traders) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Sub tabs row - 黑色矩形框标签
          _buildRankSubTabs(),
          // Time range + RANK header
          _buildRankHeader(),
          // Top 3 traders - 使用 AnimatedSwitcher 实现顺滑切换
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: traders.length >= 3
                ? _buildTopThree(traders, key: ValueKey('top3_$_rankSubTab'))
                : const SizedBox.shrink(),
          ),
          // Rank list (4+) - 使用动画
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _buildRankList(traders, key: ValueKey('list_$_rankSubTab')),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildRankSubTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _rankSubTabs.length,
        itemBuilder: (context, index) {
          final isSelected = _rankSubTab == index;
          return GestureDetector(
            onTap: () {
              if (_rankSubTab != index) {
                setState(() => _rankSubTab = index);
                // 根据选中的标签加载不同的数据
                _loadTradersByCategory(index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: index < _rankSubTabs.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // 黑色矩形框 - 不要圆角
                color: isSelected ? Colors.black : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.zero, // 矩形，无圆角
                border: Border.all(
                  color: isSelected ? Colors.white : const Color(0xFF333333),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  _rankSubTabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.white, // 白色字体
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _loadTradersByCategory(int index) {
    final appState = context.read<AppState>();
    String category;
    switch (index) {
      case 0:
        category = 'hot'; // 热门榜
        break;
      case 1:
        category = 'all'; // 全部
        break;
      case 2:
        category = 'kol'; // KOL
        break;
      case 3:
        category = 'smart'; // 聪明钱
        break;
      case 4:
        category = 'insider'; // 内盘聪明钱
        break;
      case 5:
        category = 'new'; // 新
        break;
      default:
        category = 'hot';
    }
    appState.loadTraders(category: category);
  }

  Widget _buildRankHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // RANK 标题
          const Text(
            'RANK',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _kCyan,
              letterSpacing: 3,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Spacer(),
          // 时间范围选择
          Container(
            decoration: BoxDecoration(
              color: _kCardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: List.generate(_timeRanges.length, (index) {
                final isSelected = _rankTimeRange == index;
                return GestureDetector(
                  onTap: () => setState(() => _rankTimeRange = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? _kBorderColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _timeRanges[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[500],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree(List<Trader> traders, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 第2名 - 银色 (左边，较矮)
          _buildTopTraderCard(traders[1], 2, _kSilverColor, 155),
          const SizedBox(width: 12),
          // 第1名 - 金色 (中间，最高)
          _buildTopTraderCard(traders[0], 1, _kGoldColor, 190),
          const SizedBox(width: 12),
          // 第3名 - 铜色 (右边，较矮)
          _buildTopTraderCard(traders[2], 3, _kBronzeColor, 155),
        ],
      ),
    );
  }

  Widget _buildTopTraderCard(Trader trader, int rank, Color borderColor, double cardHeight) {
    final isFirst = rank == 1;
    final cardWidth = isFirst ? 130.0 : 105.0;

    // 根据排名设置不同的背景渐变
    List<Color> gradientColors;
    if (rank == 1) {
      gradientColors = [
        const Color(0xFF3D3D1F), // 金色深底
        const Color(0xFF2A2A15),
      ];
    } else if (rank == 2) {
      gradientColors = [
        const Color(0xFF2A2A2A), // 银色深底
        const Color(0xFF1F1F1F),
      ];
    } else {
      gradientColors = [
        const Color(0xFF2A2015), // 铜色深底
        const Color(0xFF1F1A15),
      ];
    }

    return GestureDetector(
      onTap: () => _navigateToTraderDetail(trader),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: cardWidth,
              height: cardHeight,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 皇冠 (仅第1名)
                  if (isFirst)
                    const Text('👑', style: TextStyle(fontSize: 16)),
                  if (isFirst) const SizedBox(height: 2),
                  // 头像
                  Container(
                    width: isFirst ? 48 : 40,
                    height: isFirst ? 48 : 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        trader.avatar ?? 'https://api.dicebear.com/7.x/pixel-art/png?seed=${trader.address}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: _kBorderColor,
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 地址
                  Text(
                    trader.displayName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // 粉丝
                  Text(
                    '${trader.followers} 粉丝',
                    style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 4),
                  // 收益 - 更突出显示
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _kPrimaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+\$${_formatMoney(trader.profit7d)}',
                      style: TextStyle(
                        fontSize: isFirst ? 12 : 11,
                        fontWeight: FontWeight.w700,
                        color: _kPrimaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 排名徽章 - 更有质感
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      borderColor,
                      borderColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: rank == 1 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankList(List<Trader> traders, {Key? key}) {
    final otherTraders = traders.length > 3 ? traders.sublist(3) : <Trader>[];
    return Container(
      key: key,
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        children: otherTraders.map((trader) => _buildTraderRow(trader)).toList(),
      ),
    );
  }

  Widget _buildTraderRow(Trader trader) {
    return GestureDetector(
      onTap: () => _navigateToTraderDetail(trader),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF1A1A1A), width: 1),
          ),
        ),
        child: Row(
          children: [
            // 排名
            SizedBox(
              width: 24,
              child: Text(
                '${trader.rank}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 头像
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorderColor, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  trader.avatar ?? 'https://api.dicebear.com/7.x/pixel-art/png?seed=${trader.address}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _kBorderColor,
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trader.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trader.followers} 粉丝  ${trader.followedBy} 被备注',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            // 收益
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+\$${_formatMoney(trader.profit7d)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _kPrimaryGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0B90B),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('◆', style: TextStyle(fontSize: 6, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${trader.profitPercent7d.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 活动 Tab ====================
  Widget _buildActivityTab(List<Trader> traders) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final activities = appState.activities;

        return Column(
          children: [
            // Sub tabs + filters
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // 全部
                  _buildActivitySubTab('全部', 0),
                  const SizedBox(width: 8),
                  // 默认
                  _buildActivitySubTab('默认', 1),
                  const Spacer(),
                  // Filter icons
                  _buildFilterChip('买入', Icons.arrow_downward),
                  const SizedBox(width: 8),
                  _buildFilterChip('BNB', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('P1', null),
                ],
              ),
            ),
            // 活动列表或空状态
            Expanded(
              child: activities.isEmpty
                  ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              _buildEmptyIcon(),
                              const SizedBox(height: 12),
                              Text('暂无活动数据', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            ],
                          ),
                        ),
                        // 推荐关注
                        _buildRecommendedSection(traders),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        return _buildActivityItem(activities[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // 活动项
  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final action = activity['action'] as String? ?? 'add';
    final isAdd = action == 'add';
    final pnl = activity['pnl'] as String?;
    final time = activity['time'] as DateTime?;
    final timeText = time != null ? _formatActivityTime(time) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：头像 + 钱包名 + 时间
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    activity['avatar'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _kBorderColor,
                      child: const Icon(Icons.person, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      activity['walletName'] ?? '',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 12, color: Colors.grey[600]),
                  ],
                ),
              ),
              Text(timeText, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 10),
          // 内容：操作 + 代币信息
          Row(
            children: [
              // 操作标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdd ? const Color(0xFF00D26A).withOpacity(0.15) : const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isAdd ? '加仓' : '减仓',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isAdd ? const Color(0xFF00D26A) : const Color(0xFFEF4444),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 金额
              Text(
                activity['amount'] ?? '',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(width: 8),
              // 代币图标
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.network(
                    activity['tokenIcon'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _kBorderColor),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                activity['tokenSymbol'] ?? '',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  activity['tokenAge'] ?? '',
                  style: TextStyle(fontSize: 10, color: _kOrange),
                ),
              ),
              const Spacer(),
              // 买入按钮
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: _kPrimaryGreen),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 14, color: _kPrimaryGreen),
                    const SizedBox(width: 4),
                    Text('买入', style: TextStyle(fontSize: 12, color: _kPrimaryGreen)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 底部：市值 + PnL
          Row(
            children: [
              Text('市值 ${activity['marketCap'] ?? ''}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              if (pnl != null) ...[
                const SizedBox(width: 12),
                Text(
                  'PnL $pnl',
                  style: TextStyle(
                    fontSize: 11,
                    color: pnl.startsWith('-') ? const Color(0xFFEF4444) : const Color(0xFF00D26A),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatActivityTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }

  Widget _buildActivitySubTab(String text, int index) {
    final isSelected = _activitySubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activitySubTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : _kCardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: _kBorderColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.black : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String text, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(List<Trader> traders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '推荐关注',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[400]),
          ),
        ),
        ...traders.take(5).map((trader) => _buildRecommendedTraderRow(trader)),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildRecommendedTraderRow(Trader trader) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // 头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                trader.avatar ?? 'https://api.dicebear.com/7.x/pixel-art/png?seed=${trader.address}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: _kBorderColor,
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      trader.displayName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.campaign, size: 14, color: Colors.grey[600]),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatNumber(trader.followers)} 粉丝  +\$${_formatMoney(trader.profit7d)} PnL',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // 关注按钮
          GestureDetector(
            onTap: () => _toggleFollow(trader),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kCardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kPrimaryGreen),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_outlined, size: 14, color: _kPrimaryGreen),
                  const SizedBox(width: 4),
                  Text('关注', style: TextStyle(fontSize: 12, color: _kPrimaryGreen)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 关注 Tab ====================
  Widget _buildFollowTab() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final followedTraders = appState.followedTraders;
        return Column(
          children: [
            // Sub tabs + filters
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _buildFollowSubTab('全部', 0),
                  const SizedBox(width: 8),
                  _buildFollowSubTab('默认(${followedTraders.length})', 1),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _kCardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _kBorderColor),
                      ),
                      child: Icon(Icons.add, size: 16, color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
                ],
              ),
            ),
            // Filter row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  _buildDropdownChip('30D'),
                  const SizedBox(width: 8),
                  _buildDropdownChip('关注时间'),
                  const SizedBox(width: 8),
                  Icon(Icons.volume_up, size: 18, color: Colors.grey[500]),
                  const Spacer(),
                  Icon(Icons.add, size: 20, color: Colors.grey[500]),
                  const SizedBox(width: 16),
                  Icon(Icons.tune, size: 18, color: Colors.grey[500]),
                  const SizedBox(width: 16),
                  Icon(Icons.search, size: 20, color: Colors.grey[500]),
                ],
              ),
            ),
            // Content
            Expanded(
              child: followedTraders.isEmpty
                  ? _buildEmptyState('暂无关注', '发现顶级牛人钱包')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: followedTraders.length,
                      itemBuilder: (context, index) {
                        return _buildFollowedTraderCard(followedTraders[index], appState);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFollowedTraderCard(Trader trader, AppState appState) {
    final pnlStr = '${trader.profitPercent7d >= 0 ? '+' : ''}${(trader.profitPercent7d * 100).toStringAsFixed(1)}%';
    final winRateStr = '${(trader.winRate * 100).toStringAsFixed(0)}%';
    final profitStr = '${trader.profit7d >= 0 ? '+' : ''}${trader.profit7d.toStringAsFixed(3)} BNB';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF333333),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: trader.avatar != null
                  ? Image.network(
                      trader.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          trader.displayName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        trader.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        trader.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: trader.profitPercent7d >= 0
                            ? const Color(0xFF1A3A2F)
                            : const Color(0xFF3A1A1A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        pnlStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: trader.profitPercent7d >= 0
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFFEF4444),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '胜率 $winRateStr  |  7d收益 $profitStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Unfollow button
          GestureDetector(
            onTap: () {
              appState.removeFollowedTrader(trader.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Text(
                '取消关注',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowSubTab(String text, int index) {
    final isSelected = _followSubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _followSubTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : _kCardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: _kBorderColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.black : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }

  // ==================== 备注 Tab ====================
  Widget _buildNoteTab() {
    return Column(
      children: [
        // Filter row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              _buildDropdownChip('30D'),
              const SizedBox(width: 8),
              _buildDropdownChip('备注时间排序'),
              const Spacer(),
              Icon(Icons.tune, size: 18, color: Colors.grey[500]),
              const SizedBox(width: 16),
              Icon(Icons.search, size: 20, color: Colors.grey[500]),
            ],
          ),
        ),
        // Empty state
        Expanded(
          child: _buildEmptyState('暂无数据', '发现顶级牛人钱包'),
        ),
      ],
    );
  }

  // ==================== 共用组件 ====================
  Widget _buildEmptyState(String message, String buttonText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEmptyIcon(),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              // 切换到牛人榜
              _tabController.animateTo(1);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _kCardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _kBorderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    buttonText,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.folder_open,
          size: 40,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildDepositBanner(double balance) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    children: [
                      const TextSpan(text: '为您的钱包 '),
                      TextSpan(
                        text: 'Wallet1',
                        style: TextStyle(color: _kPrimaryGreen, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' (${balance.toStringAsFixed(1)} BNB) 充值'),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '完成充值，秒启交易！',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => DepositSheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kCardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kBorderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, size: 12, color: _kPrimaryGreen),
                  const SizedBox(width: 4),
                  Text('充值', style: TextStyle(fontSize: 12, color: _kPrimaryGreen)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ==================== 辅助方法 ====================
  String _formatMoney(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  void _showNewCopyTradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kCardColor,
        title: const Text('新建跟单', style: TextStyle(color: Colors.white)),
        content: const Text(
          '请先在牛人榜中选择要跟单的钱包',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(1);
            },
            child: const Text('去选择', style: TextStyle(color: _kPrimaryGreen)),
          ),
        ],
      ),
    );
  }

  void _toggleFollow(Trader trader) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已关注 ${trader.displayName}'),
        backgroundColor: _kPrimaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToTraderDetail(Trader trader) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TraderDetailScreen(trader: {
          'id': trader.id,
          'address': trader.shortAddress,
          'nickname': trader.nickname,
          'rank': trader.rank,
          'profit': '+\$${trader.profit7d.toStringAsFixed(2)}',
          'followers': trader.followers,
          'followedBy': trader.followedBy,
          'balance': trader.balance,
          'winRate': trader.winRate,
          'tradeCount': trader.tradeCount7d,
        }),
      ),
    );
  }
}
