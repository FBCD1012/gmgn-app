import 'package:flutter/material.dart';

/// GMGN 原版配色系统
class GColors {
  GColors._();

  // Primary colors - 原版配色
  static const primary = Color(0xFF5CE1D6);      // 青色 (底部导航选中)
  static const green = Color(0xFF00D26A);        // 绿色 (涨/买入)
  static const red = Color(0xFFFF6B6B);          // 红色 (跌/卖出)
  static const orange = Color(0xFFF97316);       // 橙色
  static const yellow = Color(0xFFF0B90B);       // BSC 黄色
  static const purple = Color(0xFF8B5CF6);       // 紫色
  static const blue = Color(0xFF3B82F6);         // 蓝色

  // Background colors - 统一深黑背景
  static const bg = Color(0xFF000000);           // 纯黑背景
  static const bgCard = Color(0xFF000000);       // 卡片背景 (统一纯黑)
  static const bgElevated = Color(0xFF1A1A1A);   // 输入框/按钮背景
  static const bgInput = Color(0xFF1A1A1A);      // 输入框背景 (统一)
  static const bgHover = Color(0xFF262626);      // 悬停状态

  // Border colors
  static const border = Color(0xFF1A1A1A);       // 默认边框
  static const borderLight = Color(0xFF2A2A2A);  // 浅边框
  static const borderActive = Color(0xFF333333); // 激活边框

  // Text colors
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF8E8E93);
  static const textTertiary = Color(0xFF636366);
  static const textDisabled = Color(0xFF48484A);

  // Chain colors - 链图标颜色
  static const solana = Color(0xFF9945FF);       // Solana 紫色
  static const bsc = Color(0xFFF0B90B);          // BSC 黄色
  static const base = Color(0xFF0052FF);         // Base 蓝色
  static const monad = Color(0xFF836EF9);        // Monad 紫色
  static const eth = Color(0xFF627EEA);          // ETH 蓝紫
}

/// 间距系统
class GSpacing {
  GSpacing._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 24;
}

/// 圆角系统
class GRadius {
  GRadius._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double full = 999;
}

/// 文字样式
class GTextStyle {
  GTextStyle._();

  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: GColors.textPrimary,
  );

  static const subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: GColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: GColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: GColors.textSecondary,
  );

  static const small = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: GColors.textTertiary,
  );

  static const tiny = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: GColors.textTertiary,
  );
}

/// Responsive breakpoints and utilities
class GResponsive {
  GResponsive._();

  // Breakpoints
  static const double mobileMax = 599;
  static const double tabletMin = 600;
  static const double tabletMax = 899;
  static const double desktopMin = 900;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileMax;

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletMin && width <= tabletMax;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMin;

  /// Get responsive value based on screen size
  static T value<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// Get responsive horizontal padding
  static double horizontalPadding(BuildContext context) =>
      value(context, mobile: 12.0, tablet: 24.0, desktop: 32.0);

  /// Get responsive grid columns
  static int gridColumns(BuildContext context) =>
      value(context, mobile: 1, tablet: 2, desktop: 3);
}

/// Screen size extension for quick access
extension ScreenSizeExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isMobile => GResponsive.isMobile(this);
  bool get isTablet => GResponsive.isTablet(this);
  bool get isDesktop => GResponsive.isDesktop(this);
}
