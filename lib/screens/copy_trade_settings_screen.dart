import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/copy_trade.dart';

const Color _kPrimaryGreen = Color(0xFF00D26A);
const Color _kBackgroundColor = Color(0xFF0D0D0D);
const Color _kCardColor = Color(0xFF1A1A1A);
const Color _kInputColor = Color(0xFF252525);
const Color _kBorderColor = Color(0xFF333333);
const Color _kErrorRed = Color(0xFFFF4757);

class CopyTradeSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> trader;

  const CopyTradeSettingsScreen({super.key, required this.trader});

  @override
  State<CopyTradeSettingsScreen> createState() => _CopyTradeSettingsScreenState();
}

class _CopyTradeSettingsScreenState extends State<CopyTradeSettingsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _positionCountController = TextEditingController();

  String _selectedWallet = 'Wallet1';
  double _walletBalance = 0;
  bool _noBuyHolding = false;
  bool _autoFollowSell = true;
  bool _batchTakeProfit = false;
  bool _devSell = true;
  bool _migrationAutoSell = true;
  bool _singleTakeProfit = false;
  bool _filterExpanded = true;

  // 止盈止损规则
  List<Map<String, dynamic>> _takeProfitRules = [
    {'stopLoss': -50, 'sellRatio': 100},
  ];

  // Dev卖设置
  double _devSellThreshold = 25;
  double _devAutoSellRatio = 100;

  // 迁移自动卖设置
  double _migrationSellRatio = 100;

  // 滑点设置
  bool _slippageAuto = true;
  String _slippageCustom = '';

  // Gas费用设置
  bool _gasAverage = true;
  String _gasCustom = '2';
  String _maxAutoGas = '';

  // 开关设置
  bool _antiMEV = true;
  bool _autoApprove = true;

  @override
  void dispose() {
    _amountController.dispose();
    _positionCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 跟单钱包地址
                  _buildSection1(),
                  // 2. 跟买设置
                  _buildSection2(),
                  // 3. 卖出设置
                  _buildSection3(),
                  // 过滤设置
                  _buildFilterSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // 底部按钮
          _buildBottomButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kBackgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: const Text(
        '钱包跟单',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: false,
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.school_outlined, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text('教程', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Section 1: 跟单钱包地址
  Widget _buildSection1() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1.跟单钱包地址',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kCardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
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
                      'https://api.dicebear.com/7.x/pixel-art/png?seed=${widget.trader['address']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: _kBorderColor,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trader['address'] ?? '0xbe...7bbd',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section 2: 跟买设置
  Widget _buildSection2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('2.跟买设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              Row(
                children: [
                  Text('固定买入', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                  Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 钱包选择器
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _kCardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.folder_outlined, size: 18, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text(_selectedWallet, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                    Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[400]),
                    const Spacer(),
                    _buildBNBIcon(),
                    const SizedBox(width: 6),
                    Text('${_walletBalance.toInt()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text('提示: 余额小于0.05 BNB, 跟单可能失败，请及时充值', style: TextStyle(fontSize: 12, color: _kErrorRed)),
                    ),
                    Text('去充值', style: TextStyle(fontSize: 12, color: _kPrimaryGreen)),
                    Icon(Icons.chevron_right, size: 16, color: _kPrimaryGreen),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 数量输入
          _buildInputField(_amountController, '数量', 'BNB'),
          const SizedBox(height: 6),
          Text('请输入数量', style: TextStyle(fontSize: 12, color: _kErrorRed)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('≈\$0(BNB)', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Row(
                children: [
                  Text('余额:${_walletBalance.toInt()} BNB', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(width: 4),
                  Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(color: _kPrimaryGreen, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.add, size: 14, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInputField(_positionCountController, '加仓次数', '次'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCheckboxRow('不买持仓', _noBuyHolding, (v) => setState(() => _noBuyHolding = v)),
              Text('什么是加仓次数?', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  // Section 3: 卖出设置
  Widget _buildSection3() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3.卖出设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),

          // 自动跟卖
          _buildCheckboxRow('自动跟卖', _autoFollowSell, (v) => setState(() => _autoFollowSell = v), underline: true),
          const SizedBox(height: 12),

          // 分批止盈止损
          _buildCheckboxRow('分批止盈止损', _batchTakeProfit, (v) => setState(() => _batchTakeProfit = v), underline: true),
          if (_batchTakeProfit) ..._buildTakeProfitRules(),
          const SizedBox(height: 12),

          // Dev卖
          _buildCheckboxRow('Dev卖', _devSell, (v) => setState(() => _devSell = v), underline: true),
          if (_devSell) _buildDevSellSettings(),
          const SizedBox(height: 12),

          // 迁移自动卖
          _buildCheckboxRow('迁移自动卖', _migrationAutoSell, (v) => setState(() => _migrationAutoSell = v), underline: true),
          if (_migrationAutoSell) _buildMigrationSellSettings(),
          const SizedBox(height: 12),

          // 单次止盈止损
          _buildCheckboxRow('单次止盈止损', _singleTakeProfit, (v) => setState(() => _singleTakeProfit = v), underline: true),
        ],
      ),
    );
  }

  // 止盈止损规则
  List<Widget> _buildTakeProfitRules() {
    List<Widget> widgets = [];
    for (int i = 0; i < _takeProfitRules.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Row(
              children: [
                Text('#${i + 1}', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const SizedBox(width: 12),
                Expanded(child: _buildRuleInput('止损比例', '${_takeProfitRules[i]['stopLoss']}', '%')),
                const SizedBox(width: 8),
                Expanded(child: _buildRuleInput('卖出比例', '${_takeProfitRules[i]['sellRatio']}', '%')),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _takeProfitRules.removeAt(i)),
                  child: Icon(Icons.delete_outline, size: 20, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ));
    }
    widgets.add(Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: () => setState(() => _takeProfitRules.add({'stopLoss': -50, 'sellRatio': 100})),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _kInputColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text('添加规则', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            ],
          ),
        ),
      ),
    ));
    return widgets;
  }

  // Dev卖设置
  Widget _buildDevSellSettings() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(child: _buildRuleInput('Dev卖≥', '$_devSellThreshold', '%')),
          const SizedBox(width: 8),
          Expanded(child: _buildRuleInput('自动卖', '$_devAutoSellRatio', '%')),
        ],
      ),
    );
  }

  // 迁移自动卖设置
  Widget _buildMigrationSellSettings() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _buildRuleInput('迁移自动卖', '$_migrationSellRatio', '%'),
    );
  }

  // 过滤设置
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分隔线
          Container(height: 1, color: _kBorderColor),
          const SizedBox(height: 16),

          // 过滤设置标题
          Row(
            children: [
              const Text('过滤设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(width: 12),
              Icon(Icons.refresh, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('重置', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _filterExpanded = !_filterExpanded),
                child: Row(
                  children: [
                    Text(_filterExpanded ? '收起' : '展开', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    Icon(_filterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: Colors.grey[500]),
                  ],
                ),
              ),
            ],
          ),

          if (_filterExpanded) ...[
            const SizedBox(height: 16),
            // 快捷状态行
            _buildQuickStatusRow(),
            const SizedBox(height: 20),

            // 滑点限制
            _buildSlippageSection(),
            const SizedBox(height: 20),

            // 费用设置
            _buildGasSection(),
            const SizedBox(height: 20),

            // 防夹模式
            _buildSwitchRow('防夹模式(Anti-MEV)', _antiMEV, (v) => setState(() => _antiMEV = v), icon: Icons.security),
            const SizedBox(height: 12),

            // 自动授权
            _buildSwitchRow('自动授权', _autoApprove, (v) => setState(() => _autoApprove = v)),
          ],
        ],
      ),
    );
  }

  // 快捷状态行
  Widget _buildQuickStatusRow() {
    return Row(
      children: [
        Icon(Icons.flash_on, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text('自动', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        const SizedBox(width: 12),
        Icon(Icons.local_gas_station, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text('0.12', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        const SizedBox(width: 12),
        Icon(Icons.security, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text('开', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        const SizedBox(width: 12),
        Icon(Icons.person, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text('开', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        const Spacer(),
        Text('收起', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        Icon(Icons.keyboard_arrow_up, size: 20, color: Colors.grey[500]),
      ],
    );
  }

  // 滑点限制
  Widget _buildSlippageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('滑点限制', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            const SizedBox(width: 4),
            Icon(Icons.flash_on, size: 14, color: Colors.grey[500]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _slippageAuto = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _slippageAuto ? _kBorderColor : _kInputColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('自动', style: TextStyle(fontSize: 14, color: _slippageAuto ? Colors.white : Colors.grey[500])),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _slippageAuto = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: !_slippageAuto ? _kBorderColor : _kInputColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('自定义', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                      ),
                      Text('%', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
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

  // Gas费用设置
  Widget _buildGasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('费用设置', style: TextStyle(fontSize: 14, color: Colors.white)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kCardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Gas费用(Gwei)', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  const SizedBox(width: 4),
                  Icon(Icons.local_gas_station, size: 14, color: Colors.grey[500]),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _gasAverage = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _gasAverage ? _kBorderColor : _kInputColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('平均 0.12', style: TextStyle(fontSize: 13, color: _gasAverage ? Colors.white : Colors.grey[500])),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _kInputColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(_gasCustom, style: const TextStyle(fontSize: 13, color: Colors.white)),
                          ),
                          Text('Gwei', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('最大自动gas', style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.underline)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _kInputColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('自定义', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    ),
                    Text('GWei', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 开关行
  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged, {IconData? icon}) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.white)),
        if (icon != null) ...[
          const SizedBox(width: 6),
          Icon(icon, size: 16, color: Colors.grey[500]),
        ],
        const Spacer(),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 48,
            height: 28,
            decoration: BoxDecoration(
              color: value ? _kPrimaryGreen : _kBorderColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 底部按钮
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: _kBackgroundColor,
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _handleStartCopyTrade,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: _kPrimaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '开始跟单',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 辅助组件
  Widget _buildBNBIcon() {
    return Container(
      width: 18, height: 18,
      decoration: const BoxDecoration(color: Color(0xFFF0B90B), shape: BoxShape.circle),
      child: const Center(child: Text('◆', style: TextStyle(fontSize: 10, color: Colors.white))),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, String suffix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: _kInputColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Text(suffix, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildRuleInput(String label, String value, String suffix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: _kInputColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(width: 4),
          Text(suffix, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String title, bool value, Function(bool) onChanged, {bool underline = false}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: value ? _kPrimaryGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: value ? _kPrimaryGreen : Colors.grey[600]!, width: 2),
            ),
            child: value ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              decoration: underline ? TextDecoration.underline : null,
              decorationColor: Colors.grey[600],
              decorationStyle: TextDecorationStyle.dashed,
            ),
          ),
        ],
      ),
    );
  }

  void _handleStartCopyTrade() {
    // 验证输入
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入跟单数量'), backgroundColor: _kErrorRed),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的数量'), backgroundColor: _kErrorRed),
      );
      return;
    }

    final positionCount = int.tryParse(_positionCountController.text.trim()) ?? 1;

    // 构建止盈止损规则
    List<TakeProfitRule> rules = [];
    if (_batchTakeProfit) {
      for (var rule in _takeProfitRules) {
        rules.add(TakeProfitRule(
          stopLoss: (rule['stopLoss'] as int).toDouble(),
          sellRatio: (rule['sellRatio'] as int).toDouble(),
        ));
      }
    }

    // 创建跟单记录
    final record = CopyTradeRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      targetAddress: widget.trader['address'] ?? '',
      targetNickname: widget.trader['nickname'] ?? '',
      walletName: _selectedWallet,
      amount: amount,
      positionCount: positionCount,
      noBuyHolding: _noBuyHolding,
      autoFollowSell: _autoFollowSell,
      batchTakeProfit: _batchTakeProfit,
      takeProfitRules: rules,
      devSell: _devSell,
      devSellThreshold: _devSellThreshold,
      devAutoSellRatio: _devAutoSellRatio,
      migrationAutoSell: _migrationAutoSell,
      migrationSellRatio: _migrationSellRatio,
      singleTakeProfit: _singleTakeProfit,
      slippageAuto: _slippageAuto,
      slippageCustom: _slippageAuto ? null : double.tryParse(_slippageCustom),
      gasAverage: _gasAverage,
      gasCustom: _gasAverage ? null : double.tryParse(_gasCustom),
      maxAutoGas: double.tryParse(_maxAutoGas),
      antiMEV: _antiMEV,
      autoApprove: _autoApprove,
      createdAt: DateTime.now(),
      status: CopyTradeStatus.active,
    );

    // 保存到 AppState
    context.read<AppState>().addCopyTradeRecord(record);

    // 同时创建 CopyTrade 用于列表展示，包含配置参数
    final copyTrade = CopyTrade(
      id: record.id,
      traderId: widget.trader['id'] ?? '',
      traderAddress: widget.trader['address'] ?? '',
      traderNickname: widget.trader['nickname'],
      traderAvatar: widget.trader['avatar'],
      walletName: _selectedWallet,
      buyCount: 0,
      sellCount: 0,
      totalBuyAmount: 0,
      totalSellAmount: 0,
      lastTradeTime: null,
      createdAt: DateTime.now(),
      status: CopyTradeStatus.active,
      avatarColor: const Color(0xFFFFB74D), // 默认橙色
      // 传递配置参数
      configuredAmount: amount,
      configuredPositionCount: positionCount,
      autoFollowSell: _autoFollowSell,
      devSell: _devSell,
      devSellThreshold: _devSellThreshold,
    );
    context.read<AppState>().addCopyTrade(copyTrade);

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('跟单设置成功！'),
        backgroundColor: _kPrimaryGreen,
        duration: Duration(seconds: 2),
      ),
    );

    // 返回上一页
    Navigator.pop(context);
    Navigator.pop(context); // 返回到列表页
  }
}
