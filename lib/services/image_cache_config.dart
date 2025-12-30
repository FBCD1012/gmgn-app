import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 图片缓存配置 - 优化内存和磁盘使用
class ImageCacheConfig {
  static const int maxMemoryCacheSize = 100; // 内存中最多缓存100张图片
  static const int maxDiskCacheSize = 500;   // 磁盘最多缓存500张图片
  static const Duration stalePeriod = Duration(days: 7); // 7天过期

  /// 自定义缓存管理器
  static final CacheManager customCacheManager = CacheManager(
    Config(
      'gmgn_image_cache',
      stalePeriod: stalePeriod,
      maxNrOfCacheObjects: maxDiskCacheSize,
    ),
  );

  /// 初始化图片缓存配置
  static void init() {
    // 设置 Flutter 图片缓存大小
    PaintingBinding.instance.imageCache.maximumSize = maxMemoryCacheSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB
  }

  /// 清理图片缓存
  static Future<void> clearCache() async {
    // 清理内存缓存
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    // 清理磁盘缓存
    await customCacheManager.emptyCache();
  }

  /// 获取缓存的网络图片 Widget
  static Widget cachedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: customCacheManager,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      placeholder: placeholder != null
          ? (context, url) => placeholder
          : null,
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget
          : null,
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }

    return image;
  }
}
