import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_state.dart';
import '../providers/wallet_state.dart';
import '../widgets/deposit_sheet.dart';
import '../models/trade_history.dart';

const Color _kPrimaryColor = Color(0xFF5CE1D6);

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late TabController _tabController;
  int _holdingTabIndex = 0; // 0: 持仓, 1: 活动, 2: 订单

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    // 加载钱包数据 - 使用 WalletState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletState>().loadWallets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    // 使用 Consumer2 组合 WalletState 和 AppState
    return Consumer2<WalletState, AppState>(
      builder: (context, walletState, appState, child) {
        final wallet = walletState.currentWallet;
        final totalBalance = walletState.totalBalance;

        return Scaffold(
          backgroundColor: const Color(0xFF000000),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(totalBalance),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 钱包卡片（包含标签栏和内容）
                        _buildWalletCardWithTabs(wallet, appState),
                        const SizedBox(height: 16),
                        // 持仓部分（单独盒子）
                        _buildHoldingCard(wallet),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double totalBalance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总余额 - 左上角
          Row(
            children: [
              Text(
                'Total Balance',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(width: 6),
              Icon(Icons.visibility_outlined, size: 16, color: Colors.grey[500]),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalBalance.toStringAsFixed(3),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0B90B),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Center(
                      child: Text(
                        'B',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'BNB',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 三大操作按钮 - 中间一行等宽排列
          Row(
            children: [
              Expanded(
                child: _buildMainActionButton(
                  icon: Icons.download,
                  label: 'Deposit',
                  isPrimary: true,
                  onTap: () => DepositSheet.show(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMainActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Bridge/Swap',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMainActionButton(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? _kPrimaryColor : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFF333333), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isPrimary ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCardWithTabs(dynamic wallet, AppState appState) {
    final walletName = wallet?.name ?? 'Wallet 1';
    final walletAddress = wallet?.shortAddress ?? '0x89...4398';
    final walletBalance = wallet?.balance ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        children: [
          // 钱包选择器头部
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF262626), width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, size: 18, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  walletName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[500]),
                const Spacer(),
                Text(
                  '${walletBalance.toStringAsFixed(3)} BNB',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // 钱包详情
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar - Doge头像
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFD4A853),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: 'https://upload.wikimedia.org/wikipedia/en/5/5f/Original_Doge_meme.jpg',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFD4A853),
                        child: const Icon(Icons.pets, color: Colors.white),
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
                          Text(
                            walletAddress,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.copy_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Icon(Icons.edit_outlined, size: 14, color: Colors.grey[500]),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Followers 0',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Notes 0',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 外部链接图标
                Icon(Icons.open_in_new, size: 20, color: Colors.grey[500]),
              ],
            ),
          ),
          // Tab Bar (在卡片内)
          _buildTabBarInCard(),
          // Tab Content (在卡片内)
          _buildTabContent(appState, wallet),
        ],
      ),
    );
  }

  Widget _buildTabBarInCard() {
    final tabs = ['PnL', 'Analysis', 'Profit Dist.', 'Phishing'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF262626), width: 1),
        ),
      ),
      child: Row(
        children: [
          // 四个标签
          ...List.generate(tabs.length, (index) {
            final isSelected = _tabController.index == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _tabController.animateTo(index);
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : const Color(0xFF252525),
                  borderRadius: BorderRadius.zero, // 矩形，无圆角
                  border: Border.all(
                    color: isSelected ? Colors.white : const Color(0xFF333333),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          // 时间范围选择器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '7d',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AppState appState, dynamic wallet) {
    switch (_tabController.index) {
      case 0: // PnL
        return _buildPnLContent(appState, wallet);
      case 1: // 分析
        return _buildAnalysisContent(appState, wallet);
      case 2: // 盈利分布
        return _buildProfitDistributionContent(appState, wallet);
      case 3: // 钓鱼检测
        return _buildPhishingDetectionContent();
      default:
        return _buildPnLContent(appState, wallet);
    }
  }

  Widget _buildPnLContent(AppState appState, dynamic wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PnL 统计
        _buildPnLStats(appState, wallet),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPnLStats(AppState appState, dynamic wallet) {
    final holdings = wallet?.holdings ?? [];
    double totalProfit = 0;
    for (var holding in holdings) {
      totalProfit += holding.profit;
    }
    final isProfit = totalProfit >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildStatRow('Realized Profit', '${isProfit ? '+' : ''}${totalProfit.toStringAsFixed(3)} BNB(${isProfit ? '+' : ''}${(totalProfit * 100).toStringAsFixed(1)}%)', isProfit),
          _buildStatRow('Win Rate', '0%', null),
          _buildStatRow('Total PnL', '${isProfit ? '+' : ''}${totalProfit.toStringAsFixed(3)} BNB(${isProfit ? '+' : ''}${(totalProfit * 100).toStringAsFixed(1)}%)', isProfit),
          _buildStatRow('Unrealized Profit', '+0 BNB', true),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool? isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isPositive == null
                  ? Colors.white
                  : (isPositive ? _kPrimaryColor : const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(AppState appState, dynamic wallet) {
    final holdings = wallet?.holdings ?? [];
    final tradeHistory = appState.tradeHistory;

    // 计算统计数据
    final buyTrades = tradeHistory.where((t) => t.type == TradeType.buy).toList();
    final sellTrades = tradeHistory.where((t) => t.type == TradeType.sell).toList();
    final totalTrades = tradeHistory.length;

    double totalBuyCost = 0;
    for (var trade in buyTrades) {
      totalBuyCost += trade.bnbAmount;
    }

    final avgBuyCost = buyTrades.isNotEmpty ? totalBuyCost / buyTrades.length : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow('7d Trades', '$totalTrades (${buyTrades.length}/${sellTrades.length})', null),
          _buildStatRow('7d Avg Hold Time', holdings.isNotEmpty ? '3d' : '0s', null),
          _buildStatRow('7d Total Buy Cost', '${totalBuyCost.toStringAsFixed(3)} BNB', null),
          _buildStatRow('7d Avg Buy Cost', '${avgBuyCost.toStringAsFixed(4)} BNB', null),
          _buildStatRow('7d Avg Realized Profit', '+0.0528 BNB', true),
          _buildStatRow('7d Fees', '${(totalBuyCost * 0.003).toStringAsFixed(4)} BNB', null),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfitDistributionContent(AppState appState, dynamic wallet) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 分布统计
          _buildDistributionRow('> 500%', '0', Colors.green[400]!),
          _buildDistributionRow('200% ~ 500%', '0', Colors.green[300]!),
          _buildDistributionRow('100% ~ 200%', '0', Colors.green[200]!),
          _buildDistributionRow('50% ~ 100%', '0', Colors.lightGreen[200]!),
          _buildDistributionRow('0% ~ 50%', '0', Colors.yellow[200]!),
          _buildDistributionRow('-50% ~ 0%', '0', Colors.orange[200]!),
          _buildDistributionRow('-100% ~ -50%', '0', Colors.red[200]!),
          _buildDistributionRow('< -100%', '0', Colors.red[400]!),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(String range, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              range,
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ),
          Text(
            count,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPhishingDetectionContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPhishingRow('Blacklist:', '--'),
          _buildPhishingRow('Not Purchased:', '--'),
          _buildPhishingRow('Sell > Buy:', '--'),
          _buildPhishingRow('Buy/Sell in 10s:', '--'),
        ],
      ),
    );
  }

  Widget _buildPhishingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingCard(dynamic wallet) {
    // 只有活动和订单 tab 需要监听 activities，持仓 tab 不需要
    if (_holdingTabIndex == 0) {
      // 持仓 tab 不需要监听 AppState
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333), width: 1),
        ),
        child: Column(
          children: [
            _buildHoldingHeaderInCard(),
            _buildHoldingListInCard(wallet),
          ],
        ),
      );
    }
    // 活动/订单 tab 使用 Selector 只监听 activities
    return Selector<AppState, List<Map<String, dynamic>>>(
      selector: (_, state) => state.activities,
      builder: (context, activities, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF333333), width: 1),
          ),
          child: Column(
            children: [
              _buildHoldingHeaderInCard(),
              _holdingTabIndex == 1
                  ? _buildActivityListInCard(activities)
                  : _buildOrderListInCard(activities),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityListInCard(List<Map<String, dynamic>> activities) {
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey[700]),
              const SizedBox(height: 12),
              Text(
                'No transactions yet',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Records will appear here after deposit',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: activities.map<Widget>((activity) {
        // 判断活动类型
        final type = activity['type']?.toString() ?? '';
        final action = activity['action']?.toString() ?? '';
        final isDeposit = type == 'deposit';
        final isBuy = action == 'add';
        final isSell = action == 'reduce';

        // 获取金额
        final amountRaw = activity['amount'];
        final amount = amountRaw is double ? amountRaw : double.tryParse(amountRaw.toString()) ?? 0.0;

        // 获取货币/代币符号
        final currency = activity['currency']?.toString() ?? activity['tokenSymbol']?.toString() ?? 'BNB';

        // 获取时间
        final timeRaw = activity['createdAt'] ?? activity['time'];
        final createdAt = timeRaw is DateTime ? timeRaw : DateTime.now();
        final timeStr = '${createdAt.month}/${createdAt.day} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

        // 根据类型设置显示
        String actionText;
        IconData actionIcon;
        Color actionColor;
        String amountPrefix;

        if (isDeposit) {
          actionText = 'Deposit';
          actionIcon = Icons.download;
          actionColor = const Color(0xFF4ADE80);
          amountPrefix = '+';
        } else if (isBuy) {
          actionText = 'Buy $currency';
          actionIcon = Icons.shopping_cart;
          actionColor = const Color(0xFF4ADE80);
          amountPrefix = '-';
        } else if (isSell) {
          actionText = 'Sell $currency';
          actionIcon = Icons.sell;
          actionColor = const Color(0xFFFF4757);
          amountPrefix = '+';
        } else {
          actionText = 'Trade';
          actionIcon = Icons.swap_horiz;
          actionColor = Colors.grey;
          amountPrefix = '';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF262626), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: actionColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  actionIcon,
                  size: 18,
                  color: actionColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actionText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix$amount ${isDeposit ? currency : "BNB"}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: actionColor,
                    ),
                  ),
                  Text(
                    'Completed',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderListInCard(List<Map<String, dynamic>> activities) {
    // 只显示充值/提现记录
    final deposits = activities.where((a) => a['type'] == 'deposit').toList();

    if (deposits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[700]),
              const SizedBox(height: 12),
              Text(
                'No deposit records',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: deposits.map<Widget>((activity) {
        final amountRaw = activity['amount'];
        final amount = amountRaw is double ? amountRaw : double.tryParse(amountRaw.toString()) ?? 0.0;
        final currency = activity['currency']?.toString() ?? 'BNB';
        final timeRaw = activity['createdAt'] ?? activity['time'];
        final createdAt = timeRaw is DateTime ? timeRaw : DateTime.now();
        final timeStr = '${createdAt.month}/${createdAt.day} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF262626), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80).withAlpha(38),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.download,
                  size: 18,
                  color: Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deposit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+$amount $currency',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4ADE80),
                    ),
                  ),
                  Text(
                    'Completed',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHoldingHeaderInCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF262626), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildHoldingTab('Holdings', 0),
          const SizedBox(width: 16),
          _buildHoldingTab('Activity', 1),
          const SizedBox(width: 16),
          _buildHoldingTab('Orders', 2),
          const Spacer(),
          Icon(Icons.sort, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            'Last Active',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingTab(String text, int index) {
    final isSelected = _holdingTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _holdingTabIndex = index),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildHoldingListInCard(dynamic wallet) {
    final holdings = wallet?.holdings ?? [];
    if (holdings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[700]),
              const SizedBox(height: 12),
              Text(
                'No holdings',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: holdings.map<Widget>((holding) {
        final isProfit = holding.profit >= 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF262626), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    holding.symbol[0],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${holding.amount.toStringAsFixed(0)} tokens',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${holding.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${isProfit ? '+' : ''}${(holding.profit * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isProfit ? _kPrimaryColor : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

}
