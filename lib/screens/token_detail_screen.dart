import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kline.dart';
import '../models/holder.dart';
import '../services/mock_api.dart';
import '../providers/app_state.dart';
import '../providers/auth_state.dart';
import '../providers/wallet_state.dart';

const Color _kPrimaryGreen = Color(0xFF00D26A);
const Color _kRed = Color(0xFFEF4444);
const Color _kBackgroundColor = Color(0xFF000000); // Pure black
const Color _kCardColor = Color(0xFF1A1A1A);

class TokenDetailScreen extends StatefulWidget {
  final String tokenId;
  final String? tokenName;
  final String? tokenSymbol;

  const TokenDetailScreen({
    super.key,
    required this.tokenId,
    this.tokenName,
    this.tokenSymbol,
  });

  @override
  State<TokenDetailScreen> createState() => _TokenDetailScreenState();
}

class _TokenDetailScreenState extends State<TokenDetailScreen> {
  final MockApi _api = MockApi();

  TokenDetail? _tokenDetail;
  List<KLineData> _klineData = [];
  bool _isLoading = true;

  String _selectedInterval = '1d';
  final List<String> _intervals = ['1s', '30s', '1m', '1h', '1d'];
  final Map<String, String> _intervalMap = {
    '1s': '1s',
    '30s': '30s',
    '1m': '1m',
    '1h': '1h',
    '1d': '1d',
  };

  int _selectedTab = 1; // 持有者
  final List<String> _tabs = ['Activity', 'Holders(17.1K)', 'Traders', 'Orders', 'Holdings', 'Devs'];

  int _selectedOrderType = 0; // 即时
  final List<String> _orderTypes = ['Instant', 'Market', 'Limit'];

  // 持有者相关
  List<Holder> _holders = [];
  int _selectedHolderFilter = 0;
  final List<String> _holderFilters = ['All', 'KOL 35', 'Following', 'Notes', 'Devs', 'Smart Money'];

  // 交易相关
  bool _isTrading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _holders = generateMockHolders();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final detailResponse = await _api.getTokenDetailInfo(widget.tokenId);
    final klineResponse = await _api.getKLineData(
      tokenId: widget.tokenId,
      interval: _intervalMap[_selectedInterval] ?? '1d',
      limit: 200, // 增加数据量
    );

    setState(() {
      if (detailResponse.success) {
        _tokenDetail = detailResponse.data;
      }
      if (klineResponse.success) {
        _klineData = klineResponse.data ?? [];
      }
      _isLoading = false;
    });
  }

  Future<void> _changeInterval(String interval) async {
    setState(() => _selectedInterval = interval);
    final response = await _api.getKLineData(
      tokenId: widget.tokenId,
      interval: _intervalMap[interval] ?? '1d',
      limit: 200, // 增加数据量
    );
    if (response.success) {
      setState(() => _klineData = response.data ?? []);
    }
  }

  String _getSymbol() {
    return widget.tokenSymbol ?? _tokenDetail?.symbol ?? 'TOKEN';
  }

  String _getName() {
    return widget.tokenName ?? _tokenDetail?.name ?? 'Token';
  }

  // 执行买入
  Future<void> _executeBuy(double amount) async {
    final authState = context.read<AuthState>();
    if (!authState.isLoggedIn) {
      _showLoginRequired();
      return;
    }

    setState(() => _isTrading = true);

    final appState = context.read<AppState>();
    final walletState = context.read<WalletState>();
    final result = await appState.buyToken(
      widget.tokenId,
      amount,
      tokenSymbol: _getSymbol(),
      tokenName: _getName(),
    );

    // Update wallet holdings
    if (result != null && result.success) {
      walletState.addHolding(
        tokenId: widget.tokenId,
        symbol: _getSymbol(),
        name: _getName(),
        amount: result.tokenAmount,
        bnbCost: amount,
      );
    }

    if (!mounted) return;
    setState(() => _isTrading = false);

    if (result != null && result.success) {
      _showTradeResult(true, amount, result.tokenAmount);
    } else {
      _showTradeError(result?.message ?? 'Trade failed');
    }
  }

  // 执行卖出
  Future<void> _executeSell(double percent) async {
    final authState = context.read<AuthState>();
    if (!authState.isLoggedIn) {
      _showLoginRequired();
      return;
    }

    // 计算卖出数量 (模拟)
    double tokenAmount = 1000 * percent / 100;

    setState(() => _isTrading = true);

    final appState = context.read<AppState>();
    final walletState = context.read<WalletState>();
    final result = await appState.sellToken(
      widget.tokenId,
      tokenAmount,
      tokenSymbol: _getSymbol(),
      tokenName: _getName(),
    );

    // Update wallet holdings
    if (result != null && result.success) {
      walletState.removeHolding(
        tokenId: widget.tokenId,
        amount: tokenAmount,
        bnbReceived: result.bnbAmount ?? 0,
      );
    }

    if (!mounted) return;
    setState(() => _isTrading = false);

    if (result != null && result.success) {
      _showTradeResult(false, result.bnbAmount ?? 0, tokenAmount);
    } else {
      _showTradeError(result?.message ?? 'Trade failed');
    }
  }

  void _showLoginRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login first'),
        backgroundColor: _kRed,
      ),
    );
  }

  void _showTradeResult(bool isBuy, double bnbAmount, double tokenAmount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kCardColor,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: _kPrimaryGreen, size: 28),
            const SizedBox(width: 8),
            Text(isBuy ? 'Buy Success' : 'Sell Success', style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBuy
                ? 'Spent $bnbAmount BNB to buy ${tokenAmount.toStringAsFixed(2)} ${_getSymbol()}'
                : 'Sold ${tokenAmount.toStringAsFixed(2)} ${_getSymbol()} for ${bnbAmount.toStringAsFixed(4)} BNB',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: _kPrimaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showTradeError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _kRed,
      ),
    );
  }

  void _showTradeConfirm(bool isBuy, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kCardColor,
        title: Text(
          isBuy ? 'Confirm Buy' : 'Confirm Sell',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBuy
                ? 'Spend $amount BNB to buy ${_getSymbol()}?'
                : 'Sell ${amount.toStringAsFixed(0)}% of ${_getSymbol()} holdings?',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Est. Price: ', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                Text(
                  _tokenDetail?.formattedPrice ?? '\$0.00',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isBuy) {
                _executeBuy(amount);
              } else {
                _executeSell(amount);
              }
            },
            child: Text(
              isBuy ? 'Confirm' : 'Confirm',
              style: TextStyle(color: isBuy ? _kPrimaryGreen : _kRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航
            _buildAppBar(),
            // 主内容
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _kPrimaryGreen))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // 价格信息
                          _buildPriceSection(),
                          // 池信息
                          _buildPoolInfo(),
                          // 时间选择器
                          _buildIntervalSelector(),
                          // K线图
                          _buildKLineChart(),
                          // 指标选择
                          _buildIndicators(),
                          // Tab栏
                          _buildTabBar(),
                          // 持有者内容 (当选中持有者Tab时)
                          if (_selectedTab == 1) _buildHoldersContent(),
                        ],
                      ),
                    ),
            ),
            // 交易面板
            _buildTradingPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          // Token Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kCardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getSymbol().substring(0, _getSymbol().length > 2 ? 2 : _getSymbol().length),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Token Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_getSymbol(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(width: 6),
                    Text(_getName(), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
                Text(
                  _tokenDetail?.shortAddress ?? '0x30...7148',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Action Icons
          Icon(Icons.notifications_outlined, size: 22, color: Colors.grey[500]),
          const SizedBox(width: 16),
          Icon(Icons.star_border, size: 22, color: Colors.grey[500]),
          const SizedBox(width: 16),
          Icon(Icons.more_horiz, size: 22, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final change = _tokenDetail?.priceChange24h ?? -2.02;
    final isNegative = change < 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Price', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(width: 4),
              Text('5', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$0.0₃11028',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isNegative ? _kRed : _kPrimaryGreen).withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      isNegative ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                      size: 16,
                      color: isNegative ? _kRed : _kPrimaryGreen,
                    ),
                    Text(
                      '${change.abs().toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isNegative ? _kRed : _kPrimaryGreen),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text('MC', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(width: 4),
              Text(_tokenDetail?.formattedMarketCap ?? '\$1.1B', style: const TextStyle(fontSize: 13, color: Colors.white)),
              const SizedBox(width: 12),
              Text('V', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(width: 4),
              Text(_tokenDetail?.formattedVolume ?? '\$3.83K', style: const TextStyle(fontSize: 13, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoolInfo() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPoolInfoItem('Pool', '\$119.01K', Colors.white),
          _buildPoolInfoItem('Top10', '0.1%', _kPrimaryGreen),
          _buildPoolInfoItem('Holders', _tokenDetail?.formattedHolders ?? '29.32K', Colors.white),
          _buildPoolInfoItem('Dex Paid', '0', Colors.white),
          _buildPoolInfoItem('Insider', '0%', Colors.white),
          _buildPoolInfoItem('Dev Hold', '0%', Colors.white),
        ],
      ),
    );
  }

  Widget _buildPoolInfoItem(String label, String value, Color valueColor) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ..._intervals.map((interval) {
            final isSelected = _selectedInterval == interval;
            return GestureDetector(
              onTap: () => _changeInterval(interval),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Text(
                  interval,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Icon(Icons.auto_awesome, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 16),
          Icon(Icons.camera_alt_outlined, size: 18, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildKLineChart() {
    return Container(
      height: 320,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomPaint(
        size: const Size(double.infinity, 320),
        painter: KLineChartPainter(data: _klineData),
      ),
    );
  }

  Widget _buildIndicators() {
    final indicators = ['MA', 'EMA', 'BOLL', 'SAR', 'VOL', 'MACD', 'KDJ', 'RSI', 'StochRsi', 'TRIX', 'OBV'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: indicators.map((ind) => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(ind, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTradingPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 订单类型选择
          Row(
            children: [
              const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              ...List.generate(_orderTypes.length, (index) {
                final isSelected = _selectedOrderType == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedOrderType = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _orderTypes[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _kBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Text('P1', style: TextStyle(fontSize: 12, color: Colors.white)),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[500]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.settings_outlined, size: 20, color: Colors.grey[500]),
            ],
          ),
          const SizedBox(height: 12),
          // 买入区域
          _buildBuySection(),
          const SizedBox(height: 12),
          // 卖出区域
          _buildSellSection(),
        ],
      ),
    );
  }

  Widget _buildBuySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Buy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _kPrimaryGreen)),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 14, color: _kPrimaryGreen),
            const Spacer(),
            Text('Balance', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(width: 4),
            Container(
              width: 14, height: 14,
              decoration: const BoxDecoration(color: Color(0xFFF0B90B), shape: BoxShape.circle),
              child: const Center(child: Text('◆', style: TextStyle(fontSize: 8, color: Colors.white))),
            ),
            const SizedBox(width: 4),
            const Text('0', style: TextStyle(fontSize: 12, color: Colors.white)),
            const SizedBox(width: 4),
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(color: _kPrimaryGreen, borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.add, size: 12, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildAmountButton('0.01', _kPrimaryGreen, onTap: () => _showTradeConfirm(true, 0.01)),
            const SizedBox(width: 8),
            _buildAmountButton('0.02', _kPrimaryGreen, onTap: () => _showTradeConfirm(true, 0.02)),
            const SizedBox(width: 8),
            _buildAmountButton('0.5', _kPrimaryGreen, onTap: () => _showTradeConfirm(true, 0.5)),
            const SizedBox(width: 8),
            _buildAmountButton('1', _kPrimaryGreen, onTap: () => _showTradeConfirm(true, 1.0)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('⚡ Auto', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(width: 8),
            Text('⛽ 0.12', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(width: 8),
            Text('🛡 On', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(width: 8),
            Text('👤 On', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const Spacer(),
            Text('TP/SL Not Set', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildSellSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Sell', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _kRed)),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 14, color: _kRed),
            const Spacer(),
            Text('Balance', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const Text(' 0 XAI ', style: TextStyle(fontSize: 12, color: Colors.white)),
            Text('(', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Container(
              width: 12, height: 12,
              decoration: const BoxDecoration(color: Color(0xFFF0B90B), shape: BoxShape.circle),
              child: const Center(child: Text('◆', style: TextStyle(fontSize: 6, color: Colors.white))),
            ),
            const Text(' 0)', style: TextStyle(fontSize: 12, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildAmountButton('10%', _kRed, onTap: () => _showTradeConfirm(false, 10)),
            const SizedBox(width: 8),
            _buildAmountButton('25%', _kRed, onTap: () => _showTradeConfirm(false, 25)),
            const SizedBox(width: 8),
            _buildAmountButton('50%', _kRed, onTap: () => _showTradeConfirm(false, 50)),
            const SizedBox(width: 8),
            _buildAmountButton('100%', _kRed, onTap: () => _showTradeConfirm(false, 100)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('⚡ Auto', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(width: 8),
            Text('⛽ 0.12', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(width: 8),
            Text('🛡 On', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountButton(String text, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: _isTrading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withAlpha(38),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withAlpha(77)),
          ),
          child: Center(
            child: _isTrading
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
              : Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ),
        ),
      ),
    );
  }

  // ============ 持有者内容 ============

  Widget _buildHoldersContent() {
    return Column(
      children: [
        // 过滤器标签
        _buildHolderFilters(),
        // 统计信息
        _buildHolderStats(),
        // 表头
        _buildHolderHeader(),
        // 持有者列表
        ..._holders.map((holder) => _buildHolderItem(holder)),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildHolderFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_holderFilters.length, (index) {
            final isSelected = _selectedHolderFilter == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedHolderFilter = index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Text(
                  _holderFilters[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              ),
            );
          }),
          // 设置图标
        ),
      ),
    );
  }

  Widget _buildHolderStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 第一行统计
          Row(
            children: [
              _buildStatItem('Top10 ⇋', '79.45%', null, showBubble: true),
              const SizedBox(width: 24),
              _buildStatItem('Avg Holdings', '\$399.18', null, showChart: true),
              const SizedBox(width: 24),
              _buildStatItem('Phishing', '94.97%', null),
            ],
          ),
          const SizedBox(height: 16),
          // 第二行统计
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOP100 Avg Buy', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('\$0.083503', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _kRed)),
                        Text('(-17.78%)', style: TextStyle(fontSize: 11, color: _kRed)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TOP100 Avg Sell', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('\$0.15707', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _kRed)),
                        Text('(-56.29%)', style: TextStyle(fontSize: 11, color: _kRed)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color? valueColor, {bool showBubble = false, bool showChart = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            if (showBubble) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bubble_chart, size: 12, color: Colors.white),
                    const SizedBox(width: 2),
                    Text('Bubble', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                  ],
                ),
              ),
            ],
            if (showChart) ...[
              const SizedBox(width: 4),
              Icon(Icons.show_chart, size: 14, color: Colors.grey[500]),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor ?? Colors.white)),
      ],
    );
  }

  Widget _buildHolderHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF333333), width: 0.5)),
      ),
      child: Row(
        children: [
          // 排名+头像占位
          const SizedBox(width: 60),
          // 持有人
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('Holder ▼', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(width: 6),
                Text('USD ₿', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          // 持仓占比
          Expanded(
            flex: 1,
            child: Text('Holdings ▼', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ),
          // 总利润
          SizedBox(
            width: 80,
            child: Text('Profit ▼ USD', style: TextStyle(fontSize: 11, color: Colors.grey[500]), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildHolderItem(Holder holder) {
    final isProfit = holder.isProfitable;
    final profitColor = isProfit ? _kPrimaryGreen : _kRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF222222), width: 0.5)),
      ),
      child: Row(
        children: [
          // 排名标签
          Container(
            width: 26,
            height: 16,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: holder.rank <= 3 ? _getRankColor(holder.rank) : const Color(0xFF333333),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                holder.rankLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: holder.rank <= 3 ? Colors.white : Colors.grey[400],
                ),
              ),
            ),
          ),
          // 头像
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: holder.avatarColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                holder.address.substring(2, 4).toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          // 地址信息
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      holder.shortAddress,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.edit, size: 10, color: Colors.grey[600]),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildHolderTags(holder.tags),
                ),
                Text(
                  holder.holdingChange,
                  style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // 持仓占比
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${holder.holdingPercent.toStringAsFixed(2)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                Text(
                  holder.formattedHoldingValue,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // 总利润
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  holder.formattedProfit,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: profitColor),
                ),
                Text(
                  '${holder.profitPercent >= 0 ? '+' : ''}${holder.profitPercent.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 10, color: profitColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700); // 金色
      case 2: return const Color(0xFFC0C0C0); // 银色
      case 3: return const Color(0xFFCD7F32); // 铜色
      default: return const Color(0xFF333333);
    }
  }

  List<Widget> _buildHolderTags(List<HolderTag> tags) {
    return tags.take(3).map((tag) {
      IconData icon;
      Color color;
      switch (tag) {
        case HolderTag.whale:
          icon = Icons.water;
          color = const Color(0xFF00BCD4);
          break;
        case HolderTag.smartMoney:
          icon = Icons.psychology;
          color = const Color(0xFF4CAF50);
          break;
        case HolderTag.kol:
          icon = Icons.person;
          color = const Color(0xFFFF9800);
          break;
        case HolderTag.developer:
          icon = Icons.code;
          color = const Color(0xFF9C27B0);
          break;
        case HolderTag.newWallet:
          icon = Icons.new_releases;
          color = const Color(0xFF2196F3);
          break;
        case HolderTag.diamond:
          icon = Icons.diamond;
          color = const Color(0xFF00BCD4);
          break;
      }
      return Padding(
        padding: const EdgeInsets.only(right: 3),
        child: Icon(icon, size: 10, color: color),
      );
    }).toList();
  }
}

// K线图绘制器 - 优化版本，缓存 Paint 对象
class KLineChartPainter extends CustomPainter {
  final List<KLineData> data;

  // 缓存 Paint 对象避免每帧重建
  static final Paint _gridPaint = Paint()
    ..color = const Color(0xFF262626)
    ..strokeWidth = 0.5;

  static final Paint _greenPaint = Paint()
    ..color = const Color(0xFF00D26A)
    ..style = PaintingStyle.fill;

  static final Paint _redPaint = Paint()
    ..color = const Color(0xFFEF4444)
    ..style = PaintingStyle.fill;

  static final Paint _greenWickPaint = Paint()
    ..color = const Color(0xFF00D26A)
    ..strokeWidth = 1.5;

  static final Paint _redWickPaint = Paint()
    ..color = const Color(0xFFEF4444)
    ..strokeWidth = 1.5;

  static final Paint _greenVolumePaint = Paint()
    ..color = const Color(0xFF00D26A).withAlpha(153)
    ..style = PaintingStyle.fill;

  static final Paint _redVolumePaint = Paint()
    ..color = const Color(0xFFEF4444).withAlpha(153)
    ..style = PaintingStyle.fill;

  static final Paint _pricePaint = Paint()
    ..color = const Color(0xFF00D26A)
    ..strokeWidth = 1;

  KLineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // K线区域占70%，成交量区域占30%
    final double klineHeight = size.height * 0.7;
    final double volumeHeight = size.height * 0.25;

    // 计算K线宽度
    final int candleCount = data.length;
    double totalWidth = (size.width / candleCount).clamp(6.0, 15.0);

    final int maxCandles = (size.width / totalWidth).floor();
    final displayData = data.length > maxCandles
        ? data.sublist(data.length - maxCandles)
        : data;

    final double actualTotalWidth = size.width / displayData.length;
    final double actualCandleWidth = actualTotalWidth * 0.7;

    // 计算价格范围
    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;
    double maxVolume = 0;

    for (final d in displayData) {
      if (d.low < minPrice) minPrice = d.low;
      if (d.high > maxPrice) maxPrice = d.high;
      if (d.volume > maxVolume) maxVolume = d.volume;
    }

    double priceRange = maxPrice - minPrice;
    if (priceRange == 0) priceRange = 1;
    final double pricePadding = priceRange * 0.05;
    minPrice -= pricePadding;
    maxPrice += pricePadding;
    priceRange = maxPrice - minPrice;
    if (maxVolume == 0) maxVolume = 1;

    // 绘制网格线
    for (int i = 0; i <= 4; i++) {
      double y = klineHeight * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }
    canvas.drawLine(Offset(0, klineHeight + 5), Offset(size.width, klineHeight + 5), _gridPaint);

    // 绘制K线
    for (int i = 0; i < displayData.length; i++) {
      final kline = displayData[i];
      final x = i * actualTotalWidth + actualTotalWidth / 2;

      final double openY = klineHeight - ((kline.open - minPrice) / priceRange * klineHeight);
      final double closeY = klineHeight - ((kline.close - minPrice) / priceRange * klineHeight);
      final double highY = klineHeight - ((kline.high - minPrice) / priceRange * klineHeight);
      final double lowY = klineHeight - ((kline.low - minPrice) / priceRange * klineHeight);

      final bool isUp = kline.isUp;

      // 绘制影线
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), isUp ? _greenWickPaint : _redWickPaint);

      // 绘制K线实体
      double top = openY < closeY ? openY : closeY;
      double bodyHeight = (openY - closeY).abs();
      if (bodyHeight < 2) bodyHeight = 2;

      canvas.drawRect(
        Rect.fromLTWH(x - actualCandleWidth / 2, top, actualCandleWidth, bodyHeight),
        isUp ? _greenPaint : _redPaint,
      );

      // 绘制成交量柱
      final volumeBarHeight = (kline.volume / maxVolume) * volumeHeight;
      canvas.drawRect(
        Rect.fromLTWH(x - actualCandleWidth / 2, size.height - volumeBarHeight, actualCandleWidth, volumeBarHeight),
        isUp ? _greenVolumePaint : _redVolumePaint,
      );
    }

    // 绘制当前价格虚线
    if (displayData.isNotEmpty) {
      final lastPrice = displayData.last.close;
      final lastY = klineHeight - ((lastPrice - minPrice) / priceRange * klineHeight);

      // 虚线
      const double dashWidth = 4;
      const double dashSpace = 3;
      double drawX = 0;
      while (drawX < size.width) {
        canvas.drawLine(Offset(drawX, lastY), Offset(drawX + dashWidth, lastY), _pricePaint);
        drawX += dashWidth + dashSpace;
      }

      // 价格标签
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 65, lastY - 10, 60, 20), const Radius.circular(3)),
        _greenPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant KLineChartPainter oldDelegate) {
    // 只有数据变化时才重绘
    return data.length != oldDelegate.data.length ||
        (data.isNotEmpty && oldDelegate.data.isNotEmpty && data.last.close != oldDelegate.data.last.close);
  }
}
