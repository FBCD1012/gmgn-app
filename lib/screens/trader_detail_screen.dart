import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/trader.dart';
import 'copy_trade_settings_screen.dart';

class TraderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> trader;

  const TraderDetailScreen({super.key, required this.trader});

  @override
  State<TraderDetailScreen> createState() => _TraderDetailScreenState();
}

class _TraderDetailScreenState extends State<TraderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTimeRange = 1; // 7d

  // Mock 持仓数据
  final List<Map<String, dynamic>> _holdings = [
    {
      'name': 'H',
      'symbol': 'H',
      'time': '3s',
      'balance': '0 BNB',
      'value': '488.89 BNB',
      'profit': '+1.18 BNB',
      'profitPercent': '+0.243%',
    },
    {
      'name': 'NIGHT',
      'symbol': 'NIGHT',
      'time': '42s',
      'balance': '0 BNB',
      'value': '4.62 BNB',
      'profit': '+0.0226 BNB',
      'profitPercent': '+0.489%',
    },
    {
      'name': 'BLUAI',
      'symbol': 'BLUAI',
      'time': '2m',
      'balance': '0 BNB',
      'value': '138.24 BNB',
      'profit': '-0.87 BNB',
      'profitPercent': '-0.63%',
      'isNegative': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // 主内容
          Column(
            children: [
              // 顶部横幅
              _buildHeader(),
              // 内容区域
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // 用户信息卡片
                      _buildUserCard(),
                      // 钱包余额
                      _buildWalletBalance(),
                      // Tab Bar
                      _buildTabBar(),
                      // 时间范围选择
                      _buildTimeRangeSelector(),
                      // 数据统计
                      _buildStatsGrid(),
                      // 持仓标题
                      _buildHoldingHeader(),
                      // 持仓列表
                      _buildHoldingList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 底部按钮
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 150,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF8A65), // 橙红色
            Color(0xFFFFAB91), // 浅橙色
            Color(0xFFFFCC80), // 黄色
            Color(0xFFA5D6A7), // 浅绿色
            Color(0xFF80DEEA), // 青色
            Color(0xFF80CBC4), // 浅青绿
          ],
          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // 返回按钮 - 黑色半透明背景
            Positioned(
              left: 12,
              top: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            // GMGN Logo - 像素风字体间距
            Center(
              child: Text(
                'G M G N',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 12,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            // 像素风头像装饰 - 右侧
            Positioned(
              right: 16,
              top: 20,
              bottom: 20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    'https://api.dicebear.com/7.x/pixel-art/png?seed=${widget.trader['address']}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.white, size: 32),
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

  Widget _buildUserCard() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // 根据trader数据创建Trader对象
        final traderId = widget.trader['address'] as String? ?? 'unknown';
        final trader = Trader(
          id: traderId,
          address: widget.trader['address'] as String? ?? '',
          nickname: widget.trader['nickname'] as String?,
          avatar: 'https://api.dicebear.com/7.x/pixel-art/png?seed=${widget.trader['address']}',
          rank: widget.trader['rank'] as int? ?? 0,
          profit7d: (widget.trader['profit7d'] as num?)?.toDouble() ?? 0.0,
          profitPercent7d: (widget.trader['profitPercent7d'] as num?)?.toDouble() ?? 0.0,
          tradeCount7d: widget.trader['tradeCount7d'] as int? ?? 0,
          winRate: (widget.trader['winRate'] as num?)?.toDouble() ?? 0.0,
          followers: widget.trader['followers'] as int? ?? 1,
          followedBy: widget.trader['followedBy'] as int? ?? 3,
          balance: (widget.trader['balance'] as num?)?.toDouble() ?? 0.0,
        );

        final isFollowing = appState.isTraderFollowed(trader.id);

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 头像
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333333), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    trader.avatar ?? 'https://api.dicebear.com/7.x/pixel-art/png?seed=${trader.address}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF333333),
                      child: const Icon(Icons.person, color: Colors.white),
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
                          widget.trader['address'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit_outlined, size: 16, color: Colors.grey[500]),
                        Icon(Icons.open_in_new, size: 16, color: Colors.grey[500]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '粉丝 ${widget.trader['followers'] ?? 1}  被备注 ${widget.trader['followedBy'] ?? 3}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // 关注按钮
              GestureDetector(
                onTap: () {
                  if (isFollowing) {
                    appState.removeFollowedTrader(trader.id);
                  } else {
                    appState.addFollowedTrader(trader);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFollowing
                        ? const Color(0xFF333333)
                        : const Color(0xFF4ADE80),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFollowing ? Icons.check : Icons.add,
                        size: 16,
                        color: isFollowing ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFollowing ? '已关注' : '关注',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isFollowing ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletBalance() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 18, color: Colors.grey[500]),
          const SizedBox(width: 8),
          const Text(
            '钱包余额',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Text(
            '0.707 BNB',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.refresh, size: 18, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        indicatorColor: const Color(0xFF4ADE80),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'PnL'),
          Tab(text: '分析'),
          Tab(text: '盈利分布'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    final ranges = ['1d', '7d', '30d'];
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 钓鱼检测标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '钓鱼检测',
              style: TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
          const Spacer(),
          ...List.generate(ranges.length, (index) {
            final isSelected = _selectedTimeRange == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeRange = index),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ranges[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.black : Colors.grey[500],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'label': '7d 交易数', 'value': '14313 (7017/7296)'},
      {'label': '7d 平均持仓时长', 'value': '3d'},
      {'label': '7d 买入总成本', 'value': '2.24K BNB'},
      {'label': '7d 代币平均买入成本', 'value': '0.319 BNB'},
      {'label': '7d 代币平均实现利润', 'value': '+0.0x528 BNB', 'isProfit': true},
      {'label': '7d 手续费', 'value': '0.0856 BNB'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: stats.map((stat) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stat['label'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: stat['isProfit'] == true
                        ? const Color(0xFF4ADE80)
                        : Colors.white,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHoldingHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Text(
            '持仓',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '活动',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Spacer(),
          Icon(Icons.filter_list, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '最后活跃排序',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 表头
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '币种/最后活跃',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
                Expanded(
                  child: Text(
                    '余额/总买入',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    '总利润与',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // 持仓项
          ..._holdings.map((holding) => _buildHoldingItem(holding)),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(Map<String, dynamic> holding) {
    final isNegative = holding['isNegative'] == true;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1A1A1A), width: 1),
        ),
      ),
      child: Row(
        children: [
          // 代币信息
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      holding['name'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding['symbol'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      holding['time'] as String,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 余额
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  holding['balance'] as String,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                Text(
                  holding['value'] as String,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // 利润
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  holding['profit'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isNegative
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF4ADE80),
                  ),
                ),
                Text(
                  holding['profitPercent'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isNegative
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        border: Border(
          top: BorderSide(color: Color(0xFF262626), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CopyTradeSettingsScreen(trader: widget.trader),
              ),
            );
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF00D26A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D26A).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '立即跟单',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
