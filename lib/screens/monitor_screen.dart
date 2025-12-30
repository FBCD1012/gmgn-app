import 'package:flutter/material.dart';
import 'token_detail_screen.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedChain = 0;

  final List<String> _tabs = ['关注', '飙升', 'Dex付费', 'AI信号', 'KOL', '狙击'];
  final List<String> _chains = ['BNB', 'P1'];

  // Mock数据
  final List<Map<String, dynamic>> _tokens = [
    {
      'id': 'token_monitor_1',
      'name': '摇钱树',
      'symbol': '摇钱树',
      'address': '0x26...7777',
      'time': '2h',
      'avatarColor': const Color(0xFFFFD700),
      'athMc': '\$584.3K',
      'stats': [15, 0, 0, 16, 9],
      'mcap': '\$403K',
      'price': '\$376.4K',
      'priceChange': '-6.62%',
      'isNegative': true,
      'hasDs': true,
    },
    {
      'id': 'token_monitor_2',
      'name': '币安绿光',
      'symbol': '币安绿光',
      'address': '0x59...4444',
      'time': '54m',
      'avatarColor': const Color(0xFF4ADE80),
      'athMc': '\$615.9K',
      'stats': [41, 1, 0, 14, 0],
      'mcap': '\$393.6K',
      'price': '\$601.6K',
      'priceChange': '+52.85%',
      'isNegative': false,
      'hasDs': true,
    },
    {
      'id': 'token_monitor_3',
      'name': '始终如一',
      'symbol': '始终如一',
      'address': '0x24...4444',
      'time': '2h',
      'avatarColor': const Color(0xFF60A5FA),
      'athMc': '\$765.8K',
      'stats': [15, 0, 0, 8, 33],
      'mcap': '\$447K',
      'price': '\$334K',
      'priceChange': '-25.28%',
      'isNegative': true,
      'hasDs': true,
    },
    {
      'id': 'token_monitor_4',
      'name': 'ORANGEWHALE',
      'symbol': 'ORANGE WHALE',
      'address': '0xb2...4444',
      'time': '2h',
      'avatarColor': const Color(0xFFF97316),
      'athMc': '\$98.1K',
      'stats': [18, 0, 0, 0, 0],
      'mcap': '\$52K',
      'price': '\$67.2K',
      'priceChange': '+12.34%',
      'isNegative': false,
      'hasDs': false,
    },
  ];

  void _navigateToTokenDetail(Map<String, dynamic> token) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TokenDetailScreen(
          tokenId: token['id'] as String,
          tokenName: token['name'] as String,
          tokenSymbol: token['symbol'] as String,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            _buildTabBar(),
            // 过滤器
            _buildFilters(),
            // 代币列表
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _tokens.length,
                itemBuilder: (context, index) => _buildTokenCard(_tokens[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
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
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        indicatorColor: const Color(0xFF4ADE80),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // 过滤图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: const Icon(Icons.tune, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          // 暂停按钮
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: const Icon(Icons.pause, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          // 价格过滤
          _buildFilterChip('≥ \$299'),
          const Spacer(),
          // 买入按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '买入',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 链选择
          ...List.generate(_chains.length, (index) {
            final isSelected = _selectedChain == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedChain = index),
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFF333333)),
                ),
                child: Text(
                  _chains[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
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
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildTokenCard(Map<String, dynamic> token) {
    return GestureDetector(
      onTap: () => _navigateToTokenDetail(token),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF262626)),
        ),
        child: Column(
        children: [
          // 头部信息
          Row(
            children: [
              // 更新标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '≥ 更新',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$299',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const Spacer(),
              Text(
                token['time'] as String,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 代币信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: token['avatarColor'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    (token['name'] as String).substring(0, 1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 名称和统计
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          token['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          token['symbol'] as String,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.search, size: 14, color: Colors.grey[600]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.alternate_email,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Icon(Icons.chat_bubble_outline,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          token['address'] as String,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ATH MC ${token['athMc']}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 统计数据
                    Row(
                      children: [
                        _buildStatBadge('${token['stats'][0]}%', Colors.grey),
                        _buildStatBadge('${token['stats'][1]}%', Colors.grey),
                        _buildStatBadge('${token['stats'][2]}%', Colors.grey),
                        _buildStatBadge('${token['stats'][3]}%', Colors.grey),
                        _buildStatBadge('${token['stats'][4]}%', Colors.grey),
                        if (token['hasDs'] == true)
                          _buildStatBadge('DS', const Color(0xFF4ADE80)),
                      ],
                    ),
                  ],
                ),
              ),
              // 价格信息
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MC ${token['mcap']}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 14,
                        color: token['isNegative'] == true
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF4ADE80),
                      ),
                      Text(
                        token['price'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: token['isNegative'] == true
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF4ADE80),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    token['priceChange'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: token['isNegative'] == true
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF4ADE80),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 买入按钮
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ADE80),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '买入',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
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

  Widget _buildStatBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color),
      ),
    );
  }
}
