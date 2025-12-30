import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_state.dart';
import '../models/copy_trade.dart';

const Color _kPrimaryGreen = Color(0xFF00D26A);
const Color _kBackgroundColor = Color(0xFF000000); // Pure black
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
  final TextEditingController _slippageController = TextEditingController();
  final TextEditingController _gasController = TextEditingController(text: '2');
  final TextEditingController _maxGasController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _positionFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // 钱包列表
  final List<Map<String, dynamic>> _wallets = [
    {'name': 'Wallet1', 'balance': 0.0},
    {'name': 'Wallet2', 'balance': 0.5},
    {'name': 'Wallet3', 'balance': 1.2},
  ];

  // 买入模式
  final List<String> _buyModes = ['Fixed Buy', 'Ratio Buy', 'Smart Buy'];
  String _selectedBuyMode = 'Fixed Buy';

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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _positionCountController.dispose();
    _slippageController.dispose();
    _gasController.dispose();
    _maxGasController.dispose();
    _amountFocus.dispose();
    _positionFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 显示钱包选择器
  void _showWalletPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 16),
            ..._wallets.map((wallet) => ListTile(
              onTap: () {
                setState(() {
                  _selectedWallet = wallet['name'];
                  _walletBalance = wallet['balance'];
                });
                Navigator.pop(context);
              },
              leading: Icon(Icons.folder_outlined, color: _selectedWallet == wallet['name'] ? _kPrimaryGreen : Colors.grey[400]),
              title: Text(wallet['name'], style: TextStyle(color: _selectedWallet == wallet['name'] ? _kPrimaryGreen : Colors.white)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBNBIcon(),
                  const SizedBox(width: 6),
                  Text('${wallet['balance']}', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 显示买入模式选择器
  void _showBuyModePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buy Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 16),
            ..._buyModes.map((mode) => ListTile(
              onTap: () {
                setState(() => _selectedBuyMode = mode);
                Navigator.pop(context);
              },
              title: Text(mode, style: TextStyle(color: _selectedBuyMode == mode ? _kPrimaryGreen : Colors.white)),
              trailing: _selectedBuyMode == mode ? Icon(Icons.check, color: _kPrimaryGreen) : null,
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 显示说明弹窗
  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kCardColor,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: _kPrimaryGreen)),
          ),
        ],
      ),
    );
  }

  // 显示数值编辑弹窗
  void _showEditDialog(String title, String currentValue, String suffix, Function(double) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kCardColor,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(color: Colors.grey[500]),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kPrimaryGreen)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                onSave(value);
              }
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: _kPrimaryGreen)),
          ),
        ],
      ),
    );
  }

  // 重置过滤设置
  void _resetFilterSettings() {
    setState(() {
      _slippageAuto = true;
      _slippageController.clear();
      _gasAverage = true;
      _gasController.text = '2';
      _maxGasController.clear();
      _antiMEV = true;
      _autoApprove = true;
    });
  }

  void _unfocusAll() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Lock MediaQuery to prevent keyboard-related rebuilds
    final originalMediaQuery = MediaQuery.of(context);
    final fixedMediaQuery = originalMediaQuery.copyWith(
      viewInsets: EdgeInsets.zero, // Always zero, ignore keyboard
      viewPadding: originalMediaQuery.viewPadding,
    );

    return MediaQuery(
      data: fixedMediaQuery,
      child: GestureDetector(
        onTap: _unfocusAll,
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: _kBackgroundColor,
          resizeToAvoidBottomInset: false,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // Scrollable content - completely independent from keyboard
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Target wallet address
                      _buildSection1(),
                      // 2. Buy settings
                      _buildSection2(),
                      // 3. Sell settings
                      _buildSection3(),
                      // Filter settings
                      _buildFilterSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              // Bottom button - always visible, keyboard overlays on top
              _buildBottomButton(),
            ],
          ),
        ),
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
        'Copy Trade',
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
                Text('Tutorial', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
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
            '1. Target Wallet Address',
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
                    child: CachedNetworkImage(
                      imageUrl: 'https://api.dicebear.com/7.x/pixel-art/png?seed=${widget.trader['address']}',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
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
              const Text('2. Buy Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              GestureDetector(
                onTap: _showBuyModePicker,
                child: Row(
                  children: [
                    Text(_selectedBuyMode, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                    Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[400]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 钱包选择器
          GestureDetector(
            onTap: _showWalletPicker,
            child: Container(
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
                      Text(_walletBalance.toStringAsFixed(2), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                    ],
                  ),
                  if (_walletBalance < 0.05) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Warning: Balance below 0.05 BNB, copy trade may fail', style: TextStyle(fontSize: 12, color: _kErrorRed)),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: 跳转到充值页面
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Top Up feature coming soon')),
                            );
                          },
                          child: Row(
                            children: [
                              Text('Top Up', style: TextStyle(fontSize: 12, color: _kPrimaryGreen)),
                              Icon(Icons.chevron_right, size: 16, color: _kPrimaryGreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 数量输入
          _buildInputField(_amountController, 'Amount', 'BNB', focusNode: _amountFocus),
          const SizedBox(height: 6),
          Text('Please enter amount', style: TextStyle(fontSize: 12, color: _kErrorRed)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('≈\$0(BNB)', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Row(
                children: [
                  Text('Balance: ${_walletBalance.toInt()} BNB', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
          _buildInputField(_positionCountController, 'Position Count', 'times', focusNode: _positionFocus),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCheckboxRow("Don't Buy Holdings", _noBuyHolding, (v) => setState(() => _noBuyHolding = v)),
              GestureDetector(
                onTap: () => _showInfoDialog(
                  'Position Count',
                  'Position count limits how many times you will copy buy from this trader. For example, if set to 5, you will only copy the first 5 buy transactions.',
                ),
                child: Text('What is position count?', style: TextStyle(fontSize: 12, color: Colors.grey[500], decoration: TextDecoration.underline)),
              ),
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
          const Text('3. Sell Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),

          // 自动跟卖
          _buildCheckboxRow('Auto Follow Sell', _autoFollowSell, (v) => setState(() => _autoFollowSell = v), underline: true),
          const SizedBox(height: 12),

          // 分批止盈止损
          _buildCheckboxRow('Batch TP/SL', _batchTakeProfit, (v) => setState(() => _batchTakeProfit = v), underline: true),
          if (_batchTakeProfit) ..._buildTakeProfitRules(),
          const SizedBox(height: 12),

          // Dev卖
          _buildCheckboxRow('Dev Sell', _devSell, (v) => setState(() => _devSell = v), underline: true),
          if (_devSell) _buildDevSellSettings(),
          const SizedBox(height: 12),

          // 迁移自动卖
          _buildCheckboxRow('Migration Auto Sell', _migrationAutoSell, (v) => setState(() => _migrationAutoSell = v), underline: true),
          if (_migrationAutoSell) _buildMigrationSellSettings(),
          const SizedBox(height: 12),

          // 单次止盈止损
          _buildCheckboxRow('Single TP/SL', _singleTakeProfit, (v) => setState(() => _singleTakeProfit = v), underline: true),
        ],
      ),
    );
  }

  // 止盈止损规则
  List<Widget> _buildTakeProfitRules() {
    List<Widget> widgets = [];
    for (int i = 0; i < _takeProfitRules.length; i++) {
      final index = i;
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Row(
              children: [
                Text('#${i + 1}', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEditableRuleInput(
                    'Stop Loss',
                    '${_takeProfitRules[i]['stopLoss']}',
                    '%',
                    () => _showEditDialog('Stop Loss', '${_takeProfitRules[index]['stopLoss']}', '%', (v) {
                      setState(() => _takeProfitRules[index]['stopLoss'] = v.toInt());
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEditableRuleInput(
                    'Sell Ratio',
                    '${_takeProfitRules[i]['sellRatio']}',
                    '%',
                    () => _showEditDialog('Sell Ratio', '${_takeProfitRules[index]['sellRatio']}', '%', (v) {
                      setState(() => _takeProfitRules[index]['sellRatio'] = v.toInt());
                    }),
                  ),
                ),
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
              Text('Add Rule', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
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
          Expanded(
            child: _buildEditableRuleInput(
              'Dev Sell ≥',
              '${_devSellThreshold.toInt()}',
              '%',
              () => _showEditDialog('Dev Sell Threshold', '$_devSellThreshold', '%', (v) {
                setState(() => _devSellThreshold = v);
              }),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildEditableRuleInput(
              'Auto Sell',
              '${_devAutoSellRatio.toInt()}',
              '%',
              () => _showEditDialog('Auto Sell Ratio', '$_devAutoSellRatio', '%', (v) {
                setState(() => _devAutoSellRatio = v);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 迁移自动卖设置
  Widget _buildMigrationSellSettings() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _buildEditableRuleInput(
        'Migration Sell',
        '${_migrationSellRatio.toInt()}',
        '%',
        () => _showEditDialog('Migration Sell Ratio', '$_migrationSellRatio', '%', (v) {
          setState(() => _migrationSellRatio = v);
        }),
      ),
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
              const Text('Filter Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _resetFilterSettings,
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text('Reset', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _filterExpanded = !_filterExpanded),
                child: Row(
                  children: [
                    Text(_filterExpanded ? 'Collapse' : 'Expand', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
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
            _buildSwitchRow('Anti-MEV Mode', _antiMEV, (v) => setState(() => _antiMEV = v), icon: Icons.security),
            const SizedBox(height: 12),

            // 自动授权
            _buildSwitchRow('Auto Approve', _autoApprove, (v) => setState(() => _autoApprove = v)),
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
        Text('Auto', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        const SizedBox(width: 12),
        Icon(Icons.local_gas_station, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text('0.12', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        const SizedBox(width: 12),
        Icon(Icons.security, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text('On', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        const SizedBox(width: 12),
        Icon(Icons.person, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text('On', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        const Spacer(),
        Text('Collapse', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
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
            Text('Slippage Limit', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
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
                    child: Text('Auto', style: TextStyle(fontSize: 14, color: _slippageAuto ? Colors.white : Colors.grey[500])),
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
                        child: _slippageAuto
                            ? Text('Custom', style: TextStyle(fontSize: 14, color: Colors.grey[500]))
                            : TextField(
                                controller: _slippageController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textInputAction: TextInputAction.done,
                                onEditingComplete: _unfocusAll,
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Custom',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
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
        const Text('Fee Settings', style: TextStyle(fontSize: 14, color: Colors.white)),
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
                  Text('Gas Fee (Gwei)', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
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
                          child: Text('Avg 0.12', style: TextStyle(fontSize: 13, color: _gasAverage ? Colors.white : Colors.grey[500])),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _gasAverage = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: !_gasAverage ? _kBorderColor : _kInputColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _gasAverage
                                  ? Text(_gasController.text, style: const TextStyle(fontSize: 13, color: Colors.white))
                                  : TextField(
                                      controller: _gasController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textInputAction: TextInputAction.done,
                                      onEditingComplete: _unfocusAll,
                                      style: const TextStyle(fontSize: 13, color: Colors.white),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                            ),
                            Text('Gwei', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showInfoDialog('Max Auto Gas', 'Maximum gas fee for auto transactions. Leave empty for no limit.'),
                child: Text('Max Auto Gas', style: TextStyle(fontSize: 13, color: Colors.grey[500], decoration: TextDecoration.underline)),
              ),
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
                      child: TextField(
                        controller: _maxGasController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _unfocusAll,
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Custom',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
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
                'Start Copy Trade',
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

  Widget _buildInputField(TextEditingController controller, String hint, String suffix, {FocusNode? focusNode}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: _kInputColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onEditingComplete: _unfocusAll,
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

  Widget _buildEditableRuleInput(String label, String value, String suffix, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: _kInputColor, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
            const SizedBox(width: 4),
            Text(suffix, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 12, color: Colors.grey[600]),
          ],
        ),
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
        const SnackBar(content: Text('Please enter amount'), backgroundColor: _kErrorRed),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: _kErrorRed),
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
        content: Text('Copy trade setup successful!'),
        backgroundColor: _kPrimaryGreen,
        duration: Duration(seconds: 2),
      ),
    );

    // 返回上一页
    Navigator.pop(context);
    Navigator.pop(context); // 返回到列表页
  }
}
