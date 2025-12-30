import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/deposit_sheet.dart';
import '../models/trade_history.dart';
import 'token_detail_screen.dart';

const Color _kPrimaryColor = Color(0xFF5CE1D6);

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTimeRange = 2; // 7d

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    // 加载钱包数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadWallets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final wallet = appState.currentWallet;
        final totalBalance = appState.totalBalance;

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
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
                '总余额',
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
                  label: '充值',
                  isPrimary: true,
                  onTap: () => DepositSheet.show(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMainActionButton(
                  icon: Icons.swap_horiz,
                  label: '跨链/闪兑',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMainActionButton(
                  icon: Icons.more_horiz,
                  label: '更多',
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? _kPrimaryColor : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: isPrimary
              ? null
              : Border.all(color: const Color(0xFF333333), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
    final walletName = wallet?.name ?? '钱包1';
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
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      'https://pump.mypinata.cloud/ipfs/QmeSzchzEPqCU1jwTnsLjLsBgE6r6bVP9wEL8FfwXkh6mg?img-width=128',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF333333),
                        child: const Icon(Icons.person, color: Colors.white),
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
                            '粉丝 0',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '被备注 0',
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
    final tabs = ['PnL', '分析', '盈利分布', '钓鱼检测'];
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

  Widget _buildWalletCard(dynamic wallet) {
    final walletName = wallet?.name ?? '钱包1';
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
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      'https://pump.mypinata.cloud/ipfs/QmeSzchzEPqCU1jwTnsLjLsBgE6r6bVP9wEL8FfwXkh6mg?img-width=128',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF333333),
                        child: const Icon(Icons.person, color: Colors.white),
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
                            '粉丝 0',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '被备注 0',
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
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['PnL', '分析', '盈利分布', '钓鱼检测'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  color: isSelected ? Colors.black : const Color(0xFF1A1A1A),
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
              color: const Color(0xFF1A1A1A),
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
          _buildStatRow('已实现利润', '${isProfit ? '+' : ''}${totalProfit.toStringAsFixed(3)} BNB(${isProfit ? '+' : ''}${(totalProfit * 100).toStringAsFixed(1)}%)', isProfit),
          _buildStatRow('胜率', '0%', null),
          _buildStatRow('总盈亏', '${isProfit ? '+' : ''}${totalProfit.toStringAsFixed(3)} BNB(${isProfit ? '+' : ''}${(totalProfit * 100).toStringAsFixed(1)}%)', isProfit),
          _buildStatRow('未实现利润', '+0 BNB', true),
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
          _buildStatRow('7d 交易数', '$totalTrades (${buyTrades.length}/${sellTrades.length})', null),
          _buildStatRow('7d 平均持仓时长', holdings.isNotEmpty ? '3d' : '0s', null),
          _buildStatRow('7d 买入总成本', '${totalBuyCost.toStringAsFixed(3)} BNB', null),
          _buildStatRow('7d 代币平均买入成本', '${avgBuyCost.toStringAsFixed(4)} BNB', null),
          _buildStatRow('7d 代币平均实现利润', '+0.0528 BNB', true),
          _buildStatRow('7d 手续费', '${(totalBuyCost * 0.003).toStringAsFixed(4)} BNB', null),
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
          // 盈利分布图表占位
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[700]),
                  const SizedBox(height: 12),
                  Text(
                    '盈利分布图表',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '暂无足够数据生成图表',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
          // 安全状态卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2A20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1A4D3E)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF4ADE80),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '安全状态：良好',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4ADE80),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '未检测到钓鱼风险',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 检测项目列表
          _buildDetectionItem('合约授权检测', '已检查 0 个授权', true),
          _buildDetectionItem('可疑代币检测', '未发现可疑代币', true),
          _buildDetectionItem('钓鱼地址检测', '未发现钓鱼风险', true),
          _buildDetectionItem('恶意合约检测', '未发现恶意合约', true),
          const SizedBox(height: 24),
          // 扫描按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _kPrimaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '立即扫描',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionItem(String title, String status, bool isSecure) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        children: [
          Icon(
            isSecure ? Icons.check_circle_outline : Icons.warning_outlined,
            color: isSecure ? const Color(0xFF4ADE80) : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    final ranges = ['1D', '7D', '30D'];
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(ranges.length, (index) {
          final isSelected = _selectedTimeRange == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTimeRange = index),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _kPrimaryColor : const Color(0xFF1A1A1A),
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
      ),
    );
  }

  Widget _buildStatsGrid(AppState appState, dynamic wallet) {
    // 计算实际统计数据
    final tradeHistory = appState.tradeHistory;
    final holdings = wallet?.holdings ?? [];
    final now = DateTime.now();
    final periodDays = _selectedTimeRange == 0 ? 1 : (_selectedTimeRange == 1 ? 7 : 30);
    final periodStart = now.subtract(Duration(days: periodDays));
    final periodLabel = _selectedTimeRange == 0 ? '1d' : (_selectedTimeRange == 1 ? '7d' : '30d');

    // 筛选期间内的交易
    final periodTrades = tradeHistory.where((t) => t.createdAt.isAfter(periodStart)).toList();
    final buyTrades = periodTrades.where((t) => t.type == TradeType.buy).toList();
    final sellTrades = periodTrades.where((t) => t.type == TradeType.sell).toList();

    // 计算统计数据
    final totalTrades = periodTrades.length;
    final buyCount = buyTrades.length;
    final sellCount = sellTrades.length;

    // 总买入成本
    double totalBuyCost = 0;
    for (var trade in buyTrades) {
      totalBuyCost += trade.bnbAmount;
    }

    // 总卖出收益
    double totalSellRevenue = 0;
    for (var trade in sellTrades) {
      totalSellRevenue += trade.bnbAmount;
    }

    // 持仓总价值和利润
    double totalHoldingValue = 0;
    double totalProfit = 0;
    for (var holding in holdings) {
      totalHoldingValue += holding.value;
      totalProfit += holding.profit;
    }

    // 平均买入成本
    final avgBuyCost = buyCount > 0 ? totalBuyCost / buyCount : 0.0;

    // 实现利润 (卖出收益 - 买入成本中已卖出部分)
    final realizedProfit = totalSellRevenue - (sellCount > 0 ? totalBuyCost * (sellCount / (buyCount + 1)) : 0);

    // 手续费 (模拟 0.3% 手续费)
    final fees = (totalBuyCost + totalSellRevenue) * 0.003;

    // 平均持仓时长 (模拟数据)
    String avgHoldingTime = '0s';
    if (holdings.isNotEmpty) {
      final avgDays = periodDays ~/ 2;
      if (avgDays >= 1) {
        avgHoldingTime = '${avgDays}d';
      } else {
        avgHoldingTime = '${periodDays * 12}h';
      }
    }

    final stats = [
      {'label': '$periodLabel 交易数', 'value': '$totalTrades ($buyCount/$sellCount)'},
      {'label': '$periodLabel 平均持仓时长', 'value': avgHoldingTime},
      {'label': '$periodLabel 买入总成本', 'value': '${totalBuyCost.toStringAsFixed(3)} BNB'},
      {'label': '$periodLabel 代币平均买入成本', 'value': '${avgBuyCost.toStringAsFixed(4)} BNB'},
      {'label': '$periodLabel 代币平均实现利润', 'value': '${totalProfit >= 0 ? '+' : ''}${totalProfit.toStringAsFixed(3)} BNB', 'isProfit': totalProfit >= 0},
      {'label': '$periodLabel 手续费', 'value': '${fees.toStringAsFixed(4)} BNB'},
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
                        ? _kPrimaryColor
                        : (stat['isProfit'] == false ? const Color(0xFFEF4444) : Colors.white),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHoldingCard(dynamic wallet) {
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
          _buildHoldingTab('持仓', true),
          const SizedBox(width: 16),
          _buildHoldingTab('活动', false),
          const SizedBox(width: 16),
          _buildHoldingTab('订单', false),
          const Spacer(),
          Icon(Icons.sort, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            '最后活跃排序',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingTab(String text, bool isSelected) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? Colors.white : Colors.grey[600],
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
                '暂无持仓',
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
          const SizedBox(width: 16),
          Text(
            '订单',
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

  Widget _buildHoldingList(dynamic wallet) {
    final holdings = wallet?.holdings ?? [];

    if (holdings.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[700]),
              const SizedBox(height: 12),
              Text(
                '暂无持仓',
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
        return GestureDetector(
          onTap: () => _navigateToTokenDetail(holding),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
            children: [
              // Token icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kPrimaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    holding.symbol[0],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Token info
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
              // Value & Profit
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
                    '${isProfit ? '+' : ''}${(holding.profitPercent * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isProfit ? _kPrimaryColor : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToTokenDetail(dynamic holding) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TokenDetailScreen(
          tokenId: holding.tokenId ?? 'token_${holding.symbol}',
          tokenName: holding.name ?? holding.symbol,
          tokenSymbol: holding.symbol,
        ),
      ),
    );
  }

  Widget _buildTradeHistoryList(AppState appState) {
    final history = appState.tradeHistory;

    if (history.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey[700]),
              const SizedBox(height: 12),
              Text(
                '暂无交易记录',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '完成交易后记录将显示在这里',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '交易历史 (${history.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        ...history.map((trade) => _buildTradeHistoryItem(trade)),
      ],
    );
  }

  Widget _buildTradeHistoryItem(TradeHistory trade) {
    final isBuy = trade.type == TradeType.buy;
    final color = isBuy ? const Color(0xFF00D26A) : const Color(0xFFEF4444);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TokenDetailScreen(
              tokenId: trade.tokenId,
              tokenName: trade.tokenName,
              tokenSymbol: trade.tokenSymbol,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // 类型图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // 交易信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        trade.typeText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trade.tokenSymbol,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        trade.formattedTime,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        trade.shortTxHash,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 金额
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isBuy ? '-' : '+'}${trade.bnbAmount.toStringAsFixed(4)} BNB',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isBuy ? Colors.white : color,
                  ),
                ),
                Text(
                  '${isBuy ? '+' : '-'}${trade.tokenAmount.toStringAsFixed(2)} ${trade.tokenSymbol}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
