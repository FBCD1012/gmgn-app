import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _activeIndex = 0;

  final List<Map<String, dynamic>> _items = [
    {'icon': Icons.rocket_launch_outlined, 'label': '发现'},
    {'icon': Icons.inventory_2_outlined, 'label': '钱包跟单'},
    {'icon': Icons.cloud_outlined, 'label': '交易'},
    {'icon': Icons.location_on_outlined, 'label': '监控'},
    {'icon': Icons.person_outline, 'label': '资产'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        border: Border(
          top: BorderSide(
            color: Color(0xFF262626),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isActive = _activeIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _activeIndex = index),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 24,
                      color: isActive
                          ? const Color(0xFF4ADE80)
                          : Colors.grey[600],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? const Color(0xFF4ADE80)
                            : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
