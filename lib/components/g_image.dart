import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'theme.dart';

/// Optimized network image with caching, placeholder, and error handling
class GNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const GNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? GColors.bgElevated;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback(bgColor);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: width != null ? (width! * 3).toInt() : null,
        memCacheHeight: height != null ? (height! * 3).toInt() : null,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(bgColor),
        errorWidget: (context, url, error) => errorWidget ?? _buildFallback(bgColor),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  Widget _buildPlaceholder(Color bgColor) {
    return Container(
      width: width,
      height: height,
      color: bgColor,
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: GColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(Color bgColor) {
    return Container(
      width: width,
      height: height,
      color: bgColor,
      child: Icon(
        Icons.image_outlined,
        size: (width ?? 40) * 0.4,
        color: GColors.textTertiary,
      ),
    );
  }
}

/// Avatar with initials fallback
class GAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const GAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.borderRadius = 8,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
  });

  /// Circular avatar
  const GAvatar.circle({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
  }) : borderRadius = 999;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _generateColor(name ?? '');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.clamp(0, size / 2)),
        border: borderWidth > 0 && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          (borderRadius - borderWidth).clamp(0, size / 2),
        ),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                memCacheWidth: (size * 3).toInt(),
                memCacheHeight: (size * 3).toInt(),
                placeholder: (_, __) => _buildInitials(bgColor),
                errorWidget: (_, __, ___) => _buildInitials(bgColor),
                fadeInDuration: const Duration(milliseconds: 150),
              )
            : _buildInitials(bgColor),
      ),
    );
  }

  Widget _buildInitials(Color bgColor) {
    final initials = _getInitials(name ?? '');
    return Container(
      width: size,
      height: size,
      color: bgColor,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _generateColor(String seed) {
    if (seed.isEmpty) return GColors.bgElevated;
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF43F5E),
      const Color(0xFFF97316),
      const Color(0xFFEAB308),
      const Color(0xFF22C55E),
      const Color(0xFF14B8A6),
      const Color(0xFF06B6D4),
      const Color(0xFF3B82F6),
    ];
    return colors[seed.hashCode.abs() % colors.length];
  }
}

/// Token logo with chain badge
class GTokenLogo extends StatelessWidget {
  final String? imageUrl;
  final String symbol;
  final double size;
  final String? chain;

  const GTokenLogo({
    super.key,
    this.imageUrl,
    required this.symbol,
    this.size = 40,
    this.chain,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          GAvatar(
            imageUrl: imageUrl,
            name: symbol,
            size: size,
            borderRadius: size * 0.25,
          ),
          if (chain != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  color: _getChainColor(chain!),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: GColors.bg,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getChainIcon(chain!),
                    style: TextStyle(
                      fontSize: size * 0.15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getChainColor(String chain) {
    switch (chain.toUpperCase()) {
      case 'BSC':
      case 'BNB':
        return GColors.bsc;
      case 'ETH':
        return GColors.eth;
      case 'SOL':
        return GColors.solana;
      case 'BASE':
        return GColors.base;
      default:
        return GColors.textSecondary;
    }
  }

  String _getChainIcon(String chain) {
    switch (chain.toUpperCase()) {
      case 'BSC':
      case 'BNB':
        return '◆';
      case 'SOL':
        return '◎';
      default:
        return '●';
    }
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
        color = GColors.eth;
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
