import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/copy_trade.dart';

const Color _kPrimaryGreen = Color(0xFF00D26A);
const Color _kBackgroundColor = Color(0xFF0D0D0D);
const Color _kCardColor = Color(0xFF1A1A1A);
const Color _kBorderColor = Color(0xFF333333);
const Color _kErrorRed = Color(0xFFFF4757);
const Color _kWarningYellow = Color(0xFFF0B90B);

class TradeHistoryScreen extends StatelessWidget {
  const TradeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        backgroundColor: _kBackgroundColor,
        elevation: 0,
        title: const Text(
          '跟单记录',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final records = appState.copyTradeRecords;

          if (records.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              return _buildRecordCard(context, records[index], appState);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            '暂无跟单记录',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            '去钱包跟单页面设置跟单',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, CopyTradeRecord record, AppState appState) {
    Color statusColor;
    switch (record.status) {
      case CopyTradeStatus.active:
        statusColor = _kPrimaryGreen;
        break;
      case CopyTradeStatus.paused:
        statusColor = _kWarningYellow;
        break;
      case CopyTradeStatus.stopped:
        statusColor = _kErrorRed;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：地址 + 状态
          Row(
            children: [
              // 头像
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorderColor, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    'https://api.dicebear.com/7.x/pixel-art/png?seed=${record.targetAddress}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: _kBorderColor,
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
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
                    Text(
                      record.targetNickname.isNotEmpty ? record.targetNickname : record.shortAddress,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.shortAddress,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // 状态标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record.statusText,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 跟单参数
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildInfoRow('跟单钱包', record.walletName),
                _buildInfoRow('跟单金额', '${record.amount} BNB'),
                _buildInfoRow('加仓次数', '${record.positionCount} 次'),
                if (record.autoFollowSell) _buildInfoRow('自动跟卖', '已开启'),
                if (record.devSell) _buildInfoRow('Dev卖', '≥${record.devSellThreshold}% 自动卖${record.devAutoSellRatio}%'),
                if (record.migrationAutoSell) _buildInfoRow('迁移自动卖', '${record.migrationSellRatio}%'),
                if (record.antiMEV) _buildInfoRow('防夹模式', '已开启'),
                _buildInfoRow('创建时间', _formatTime(record.createdAt)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 操作按钮
          Row(
            children: [
              if (record.status == CopyTradeStatus.active) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => appState.pauseCopyTrade(record.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _kWarningYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('暂停', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _kWarningYellow)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (record.status != CopyTradeStatus.stopped)
                Expanded(
                  child: GestureDetector(
                    onTap: () => appState.stopCopyTrade(record.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _kErrorRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('停止', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _kErrorRed)),
                      ),
                    ),
                  ),
                ),
              if (record.status == CopyTradeStatus.stopped) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDeleteConfirm(context, appState, record.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _kErrorRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('删除', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _kErrorRed)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirm(BuildContext context, AppState appState, String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kCardColor,
        title: const Text('确认删除', style: TextStyle(color: Colors.white)),
        content: const Text('确定要删除这条跟单记录吗？', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              appState.removeCopyTradeRecord(recordId);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: _kErrorRed)),
          ),
        ],
      ),
    );
  }
}
