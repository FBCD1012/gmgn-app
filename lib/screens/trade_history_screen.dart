import 'package:flutter/material.dart';
import 'dart:math';

const Color _kPrimaryGreen = Color(0xFF00D26A);
const Color _kBackgroundColor = Color(0xFF000000); // Pure black
const Color _kCardColor = Color(0xFF1A1A1A);
const Color _kBorderColor = Color(0xFF333333);
const Color _kErrorRed = Color(0xFFFF4757);

class TradeHistoryScreen extends StatefulWidget {
  const TradeHistoryScreen({super.key});

  @override
  State<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends State<TradeHistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int _selectedTimeframe = 4; // 1日
  int _selectedTab = 0; // 0: 买入, 1: 卖出
  int _bottomTabIndex = 0; // 0: 我的交易, 1: 高级策略, 2: 挂单, 3: 持仓
  final TextEditingController _amountController = TextEditingController();

  final List<String> _timeframes = ['1s', '30s', '1m', '1h', '1d'];
  final List<double> _presetAmounts = [0.01, 0.02, 0.5, 1];

  // Mock K线数据
  final List<Map<String, double>> _klineData = List.generate(50, (index) {
    final random = Random(index);
    final base = 0.04 + random.nextDouble() * 0.02;
    return {
      'open': base,
      'high': base + random.nextDouble() * 0.005,
      'low': base - random.nextDouble() * 0.005,
      'close': base + (random.nextDouble() - 0.5) * 0.008,
    };
  });

  // Mock订单簿数据
  final List<Map<String, dynamic>> _orderBook = [
    {'price': 0.0439378, 'amount': 5.37, 'type': 'sell'},
    {'price': 0.0439402, 'amount': 21.17, 'type': 'sell'},
    {'price': 0.0439402, 'amount': 1.83, 'type': 'sell'},
    {'price': 0.0439274, 'amount': 378.69, 'type': 'sell'},
    {'price': 0.0439456, 'amount': 2.38, 'type': 'buy'},
    {'price': 0.0439453, 'amount': 253.8, 'type': 'buy'},
    {'price': 0.0439453, 'amount': 16.79, 'type': 'buy'},
    {'price': 0.0439454, 'amount': 105.09, 'type': 'buy'},
    {'price': 0.0439934, 'amount': 135.97, 'type': 'buy'},
    {'price': 0.0440144, 'amount': 0.656, 'type': 'buy'},
  ];

  final List<String> _bottomTabs = ['My Trades', 'Advanced', 'Orders', 'Holdings'];

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 顶部代币信息
              _buildTokenHeader(),
              // K线图区域
              _buildChartSection(),
              // 交易面板
              _buildTradePanel(),
              // 底部标签页
              _buildBottomTabBar(),
              // 底部内容区域 - 给一个固定高度让内容可见
              SizedBox(
                height: 400,
                child: _buildBottomTabContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: _kBorderColor, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(_bottomTabs.length, (index) {
          final isSelected = _bottomTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _bottomTabIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _bottomTabs[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomTabContent() {
    switch (_bottomTabIndex) {
      case 0:
        return _buildMyTradesContent();
      case 1:
        return _buildAdvancedStrategyContent();
      case 2:
        return _buildPendingOrdersContent();
      case 3:
        return _buildPositionsContent();
      default:
        return _buildMyTradesContent();
    }
  }

  Widget _buildMyTradesContent() {
    return Column(
      children: [
        // 筛选按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('Current token only', false),
              const Spacer(),
            ],
          ),
        ),
        // 交易列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              final isBuy = index % 2 == 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kCardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B90B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('F', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('FLOKI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isBuy ? _kPrimaryGreen.withAlpha(51) : _kErrorRed.withAlpha(51),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isBuy ? 'Buy' : 'Sell',
                                  style: TextStyle(fontSize: 10, color: isBuy ? _kPrimaryGreen : _kErrorRed),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(index + 1) * 1000} FLOKI · 0.0${index + 1} BNB',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isBuy ? '+${(index + 1) * 5}%' : '-${(index + 1) * 2}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isBuy ? _kPrimaryGreen : _kErrorRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '12/2${index} 14:3$index',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedStrategyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph, size: 48, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text('Advanced Strategy', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text('No strategies', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildPendingOrdersContent() {
    return Column(
      children: [
        // 筛选和操作按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('Current token only', false),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text('Close All Orders', style: TextStyle(fontSize: 12, color: _kErrorRed)),
              ),
            ],
          ),
        ),
        // 挂单列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kCardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B90B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('F', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('FLOKI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _kPrimaryGreen.withAlpha(51),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Limit Buy', style: TextStyle(fontSize: 10, color: _kPrimaryGreen)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: \$0.0430 · 0.0${index + 1} BNB',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: _kErrorRed),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Cancel', style: TextStyle(fontSize: 11, color: _kErrorRed)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPositionsContent() {
    return Column(
      children: [
        // 筛选按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('Current token only', false),
              const Spacer(),
            ],
          ),
        ),
        // 持仓列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) {
              final profit = (index % 2 == 0) ? (index + 1) * 15.5 : -(index + 1) * 8.2;
              final isProfit = profit > 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kCardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B90B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('F', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FLOKI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            'Hold ${(index + 1) * 5000} · Cost 0.0${index + 3} BNB',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isProfit ? '+' : ''}${profit.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isProfit ? _kPrimaryGreen : _kErrorRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${((index + 1) * 0.12).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _kBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_box : Icons.check_box_outline_blank,
            size: 14,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: isActive ? Colors.white : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 代币图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF0B90B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('F', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'FLOKI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '\$0.0439395',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Row(
                children: [
                  Text(
                    '-4.86%',
                    style: TextStyle(fontSize: 12, color: _kErrorRed),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.candlestick_chart, size: 16, color: _kErrorRed),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      children: [
        // 图表标题
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Chart', style: TextStyle(fontSize: 14, color: Colors.white)),
              const Spacer(),
              Icon(Icons.keyboard_arrow_up, color: Colors.grey[600], size: 20),
            ],
          ),
        ),
        // 时间周期选择
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_timeframes.length, (index) {
              final isSelected = _selectedTimeframe == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTimeframe = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _kCardColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _timeframes[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        // K线图
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomPaint(
            size: const Size(double.infinity, 180),
            painter: KLinePainter(_klineData),
          ),
        ),
        // 时间轴
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('08/12 08:00', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              Text('10/10 08:00', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              Text('12/08 08:00', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTradePanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：交易输入
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // 买入/卖出切换
                Row(
                  children: [
                    _buildTabButton('Buy', 0, _kPrimaryGreen),
                    const SizedBox(width: 8),
                    _buildTabButton('Sell', 1, Colors.grey),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kCardColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Text('P1', style: TextStyle(fontSize: 12, color: Colors.white)),
                          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[500]),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 市价单/限价单
                Row(
                  children: [
                    const Text('Market', style: TextStyle(fontSize: 13, color: Colors.white)),
                    const SizedBox(width: 16),
                    Text('Limit', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 12),
                // 输入框
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kCardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kBorderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const Text('BNB', style: TextStyle(fontSize: 14, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 预设金额
                Row(
                  children: _presetAmounts.map((amount) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _amountController.text = amount.toString(),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _kCardColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _kBorderColor),
                          ),
                          child: Center(
                            child: Text(
                              amount.toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // 设置项
                _buildSettingRow('TP/SL', 'Not Set'),
                _buildSettingRow('Dev Sell', 'Not Set'),
                _buildSettingRow('Auto Sell', 'Not Set'),
                const SizedBox(height: 12),
                // 可用余额
                Row(
                  children: [
                    const Text('Available', style: TextStyle(fontSize: 13, color: Colors.white)),
                    const Spacer(),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B90B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('0 BNB', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(width: 4),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _kPrimaryGreen,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.add, size: 14, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Spacer(),
                    Text('1 BNB ≈ 21.6M FLOKI', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 16),
                // 警告和充值按钮
                Text(
                  'Insufficient BNB for Gas',
                  style: TextStyle(fontSize: 12, color: _kPrimaryGreen),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _kPrimaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Low balance, click to deposit',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 右侧：订单簿
          Expanded(
            flex: 4,
            child: Column(
              children: [
                // 当前市值
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kCardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('Market Cap', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      const Text('\$ 393.95M', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 订单簿标题
                Row(
                  children: [
                    Text('Price', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    const Spacer(),
                    Text('Amount', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 4),
                // 订单簿列表
                ...List.generate(_orderBook.length, (index) {
                  final order = _orderBook[index];
                  final isSell = order['type'] == 'sell';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '\$${order['price']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSell ? _kPrimaryGreen : _kErrorRed,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${order['amount']}K',
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index, Color activeColor) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : _kCardColor,
          borderRadius: BorderRadius.circular(4),
          border: isSelected ? Border.all(color: activeColor) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? activeColor : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white)),
          const Spacer(),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// K线图绘制 - 优化版本，缓存 Paint 对象
class KLinePainter extends CustomPainter {
  final List<Map<String, double>> data;

  // 缓存 Paint 对象
  static final Paint _gridPaint = Paint()
    ..color = const Color(0xFF262626)
    ..strokeWidth = 0.5;

  static final Paint _greenPaint = Paint()
    ..color = const Color(0xFF00D26A)
    ..style = PaintingStyle.fill;

  static final Paint _redPaint = Paint()
    ..color = const Color(0xFFFF4757)
    ..style = PaintingStyle.fill;

  static final Paint _greenWickPaint = Paint()
    ..color = const Color(0xFF00D26A)
    ..strokeWidth = 1.5;

  static final Paint _redWickPaint = Paint()
    ..color = const Color(0xFFFF4757)
    ..strokeWidth = 1.5;

  static final Paint _greenVolumePaint = Paint()
    ..color = const Color(0xFF00D26A).withAlpha(153)
    ..style = PaintingStyle.fill;

  static final Paint _redVolumePaint = Paint()
    ..color = const Color(0xFFFF4757).withAlpha(153)
    ..style = PaintingStyle.fill;

  static final Paint _linePaint = Paint()
    ..color = const Color(0xFF00D26A)
    ..strokeWidth = 1;

  KLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double klineHeight = size.height * 0.7;
    final double volumeHeight = size.height * 0.25;

    double totalWidth = (size.width / data.length).clamp(6.0, 15.0);
    final int maxCandles = (size.width / totalWidth).floor();

    final displayData = data.length > maxCandles
        ? data.sublist(data.length - maxCandles)
        : data;

    final double actualTotalWidth = size.width / displayData.length;
    final double actualCandleWidth = actualTotalWidth * 0.7;

    // 绘制网格
    for (int i = 0; i <= 4; i++) {
      final y = klineHeight * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }
    canvas.drawLine(Offset(0, klineHeight + 5), Offset(size.width, klineHeight + 5), _gridPaint);

    // 计算价格范围
    double maxPrice = 0, minPrice = double.infinity, maxVolume = 0;
    for (final candle in displayData) {
      maxPrice = max(maxPrice, candle['high']!);
      minPrice = min(minPrice, candle['low']!);
      maxVolume = max(maxVolume, candle['volume'] ?? 1000.0);
    }

    final padding = (maxPrice - minPrice) * 0.05;
    maxPrice += padding;
    minPrice -= padding;
    final priceRange = maxPrice - minPrice;
    if (priceRange == 0) return;

    // 绘制K线
    for (int i = 0; i < displayData.length; i++) {
      final candle = displayData[i];
      final x = i * actualTotalWidth + actualTotalWidth / 2;
      final isGreen = candle['close']! >= candle['open']!;

      final highY = klineHeight - ((candle['high']! - minPrice) / priceRange * klineHeight);
      final lowY = klineHeight - ((candle['low']! - minPrice) / priceRange * klineHeight);
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), isGreen ? _greenWickPaint : _redWickPaint);

      final openY = klineHeight - ((candle['open']! - minPrice) / priceRange * klineHeight);
      final closeY = klineHeight - ((candle['close']! - minPrice) / priceRange * klineHeight);

      var bodyTop = min(openY, closeY);
      var bodyBottom = max(openY, closeY);
      if (bodyBottom - bodyTop < 2) bodyBottom = bodyTop + 2;

      canvas.drawRect(
        Rect.fromLTWH(x - actualCandleWidth / 2, bodyTop, actualCandleWidth, bodyBottom - bodyTop),
        isGreen ? _greenPaint : _redPaint,
      );

      // 成交量
      final volume = candle['volume'] ?? 1000.0;
      final volumeBarHeight = (volume / maxVolume) * volumeHeight;
      canvas.drawRect(
        Rect.fromLTWH(x - actualCandleWidth / 2, size.height - volumeBarHeight, actualCandleWidth, volumeBarHeight),
        isGreen ? _greenVolumePaint : _redVolumePaint,
      );
    }

    // 当前价格线
    if (displayData.isNotEmpty) {
      final currentPrice = displayData.last['close']!;
      final currentY = klineHeight - ((currentPrice - minPrice) / priceRange * klineHeight);

      double drawX = 0;
      while (drawX < size.width - 60) {
        canvas.drawLine(Offset(drawX, currentY), Offset(drawX + 4, currentY), _linePaint);
        drawX += 7;
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 60, currentY - 10, 55, 20), const Radius.circular(3)),
        _greenPaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '\$${currentPrice.toStringAsFixed(4)}',
          style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - 57, currentY - 6));
    }
  }

  @override
  bool shouldRepaint(covariant KLinePainter oldDelegate) {
    return data.length != oldDelegate.data.length ||
        (data.isNotEmpty && oldDelegate.data.isNotEmpty && data.last['close'] != oldDelegate.data.last['close']);
  }
}
