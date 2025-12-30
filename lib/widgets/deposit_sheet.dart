import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/wallet_state.dart';
import '../providers/app_state.dart';
import 'native_input.dart';

class DepositSheet extends StatefulWidget {
  const DepositSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DepositSheet(),
    );
  }

  @override
  State<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<DepositSheet> {
  final String _walletAddress = '0x89234f60876a79d78fe458d47184fa22a2634398';
  final String _qrData = '0x89234f60876a79d78fe458d47184fa22a2634398\n\n🚀 May your crypto moon! WAGMI!\n💰 Bull run incoming, LFG!\n🌙 To The Moon! See you at the top!';
  bool _isDepositing = false;
  bool _showSuccess = false;
  String _successMessage = '';

  void _copyAddress() {
    Clipboard.setData(ClipboardData(text: _walletAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        backgroundColor: Color(0xFF4ADE80),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCrossChainDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Bridge/Swap', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select source chain and token to swap to BNB',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            _buildChainOption('Ethereum (ETH)', Icons.currency_bitcoin, const Color(0xFF627EEA)),
            const SizedBox(height: 8),
            _buildChainOption('Polygon (MATIC)', Icons.hexagon, const Color(0xFF8247E5)),
            const SizedBox(height: 8),
            _buildChainOption('Solana (SOL)', Icons.wb_sunny, const Color(0xFF00D18C)),
            const SizedBox(height: 8),
            _buildChainOption('Arbitrum (ARB)', Icons.layers, const Color(0xFF28A0F0)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
        ],
      ),
    );
  }

  Widget _buildChainOption(String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showSwapDialog(name);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(color: Colors.white)),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }

  void _showSwapDialog(String sourceChain) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Swap from $sourceChain', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: NativeInput(
                controller: amountController,
                hintText: 'Enter swap amount',
                keyboardType: TextInputType.number,
                backgroundColor: const Color(0xFF000000),
                textColor: Colors.white,
                hintColor: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Est. receive: ', style: TextStyle(color: Colors.grey[500])),
                const Text('0.00 BNB', style: TextStyle(color: Color(0xFFF0B90B))),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cross-chain swap coming soon'),
                  backgroundColor: Color(0xFFF0B90B),
                ),
              );
            },
            child: const Text('Swap', style: TextStyle(color: Color(0xFF4ADE80))),
          ),
        ],
      ),
    );
  }

  void _simulateDeposit() async {
    setState(() => _isDepositing = true);

    // 提前捕获 context 相关对象，避免异步后使用
    final walletState = context.read<WalletState>();
    final appState = context.read<AppState>();

    // 模拟充值延迟
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 调用真正的充值方法
    final success = await walletState.deposit(0.1);

    // 同步添加活动记录到 AppState
    if (success) {
      final now = DateTime.now();
      appState.addActivity({
        'id': 'deposit_${now.millisecondsSinceEpoch}',
        'type': 'deposit',
        'amount': 0.1,
        'currency': 'BNB',
        'status': 'completed',
        'txHash': '0x${now.millisecondsSinceEpoch.toRadixString(16)}...mock',
        'createdAt': now,
        'description': 'Deposit 0.1 BNB',
      });
    }

    if (!mounted) return;

    setState(() {
      _isDepositing = false;
      _showSuccess = success;
      _successMessage = success ? 'Deposit success! +0.1 BNB' : 'Deposit failed, please try again';
    });

    // 3秒后自动隐藏成功提示
    if (success) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showSuccess = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Selector 只监听余额变化
    return Selector<WalletState, double>(
      selector: (_, state) => state.totalBalance,
      builder: (context, balance, child) {

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
                      'Deposit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              // 成功提示
              if (_showSuccess)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _successMessage.contains('success')
                        ? const Color(0xFF4ADE80).withOpacity(0.15)
                        : const Color(0xFFFF4757).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _successMessage.contains('success')
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFFF4757),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _successMessage.contains('success')
                            ? Icons.check_circle
                            : Icons.error,
                        color: _successMessage.contains('success')
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFFF4757),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _successMessage,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _successMessage.contains('success')
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFFF4757),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showSuccess = false),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[500],
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_showSuccess) const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 跨链/闪兑
                      _buildOptionCard(
                        icon: Icons.swap_horiz,
                        title: 'Bridge/Swap',
                        subtitle: 'Swap assets from other chains to BNB',
                        onTap: _showCrossChainDialog,
                      ),
                      const SizedBox(height: 16),
                      // 存入 BNB
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000000),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0B90B),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'B',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Deposit BNB',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // 链说明
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  height: 1.5,
                                ),
                                children: const [
                                  TextSpan(text: 'This address only supports '),
                                  TextSpan(
                                    text: 'Binance Smart Chain (BEP20)',
                                    style: TextStyle(
                                      color: Color(0xFF4ADE80),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(text: ' network '),
                                  TextSpan(
                                    text: 'BNB',
                                    style: TextStyle(
                                      color: Color(0xFFF0B90B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(text: ' deposits. Do not use other networks to avoid loss.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 二维码区域
                            Center(
                              child: Container(
                                width: 160,
                                height: 160,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: QrImageView(
                                  data: _qrData,
                                  version: QrVersions.auto,
                                  size: 140,
                                  backgroundColor: Colors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Colors.black,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 钱包地址
                            Row(
                              children: [
                                Text(
                                  'Receiving Address',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Balance ${balance.toStringAsFixed(3)} BNB',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFF0B90B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _walletAddress,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontFamily: 'monospace',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _copyAddress,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4ADE80),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Copy',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // 模拟充值按钮 (固定在底部)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: GestureDetector(
                    onTap: _isDepositing ? null : _simulateDeposit,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0B90B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _isDepositing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.black, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'Simulate Deposit 0.1 BNB (Test)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF333333),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
