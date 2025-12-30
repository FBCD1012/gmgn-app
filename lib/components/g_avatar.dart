import 'package:flutter/material.dart';
import 'theme.dart';

/// 头像组件
class GAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? text;
  final double size;
  final Color? bgColor;
  final bool showBorder;
  final Widget? badge;

  const GAvatar({
    super.key,
    this.imageUrl,
    this.text,
    this.size = 44,
    this.bgColor,
    this.showBorder = true,
    this.badge,
  });

  /// 小头像
  const GAvatar.sm({
    super.key,
    this.imageUrl,
    this.text,
    this.bgColor,
    this.showBorder = true,
    this.badge,
  }) : size = 32;

  /// 大头像
  const GAvatar.lg({
    super.key,
    this.imageUrl,
    this.text,
    this.bgColor,
    this.showBorder = true,
    this.badge,
  }) : size = 56;

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = bgColor ?? GColors.borderLight;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(size / 2),
            border: showBorder
                ? Border.all(color: GColors.borderActive, width: 2)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2 - 2),
            child: _buildContent(),
          ),
        ),
        if (badge != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: badge!,
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // 提高图片请求尺寸以获得更清晰的图片
      String highResUrl = imageUrl!;
      if (imageUrl!.contains('img-width=')) {
        highResUrl = imageUrl!.replaceAll(RegExp(r'img-width=\d+'), 'img-width=256');
      }
      return Image.network(
        highResUrl,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        cacheWidth: (size * 3).toInt(), // 3x分辨率
        cacheHeight: (size * 3).toInt(),
        errorBuilder: (_, __, ___) => _buildTextAvatar(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: GColors.textSecondary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }
    return _buildTextAvatar();
  }

  Widget _buildTextAvatar() {
    final displayText = text?.isNotEmpty == true ? text![0].toUpperCase() : '?';
    return Center(
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: GColors.textPrimary,
        ),
      ),
    );
  }
}

/// 验证徽章
class GVerifiedBadge extends StatelessWidget {
  final double size;

  const GVerifiedBadge({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: GColors.green,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: size * 0.6,
        color: Colors.black,
      ),
    );
  }
}

/// 链头像 (带链图标)
class GChainAvatar extends StatelessWidget {
  final String chain;
  final double size;

  const GChainAvatar({
    super.key,
    required this.chain,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String icon;

    switch (chain.toUpperCase()) {
      case 'SOL':
      case 'SOLANA':
        color = GColors.solana;
        icon = '◎';
        break;
      case 'BSC':
        color = GColors.bsc;
        icon = '◆';
        break;
      case 'BASE':
        color = GColors.base;
        icon = 'B';
        break;
      case 'ETH':
        color = GColors.blue;
        icon = 'Ξ';
        break;
      default:
        color = GColors.textSecondary;
        icon = '●';
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: size * 0.6,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
