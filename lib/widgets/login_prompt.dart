import 'dart:ui';
import 'package:flutter/material.dart';

// 主题色
const Color kPrimaryColor = Color(0xFF5CE1D6);

class LoginPrompt extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const LoginPrompt({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 绿色渐变背景
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(200),
            const Color(0xFF0A2A1A).withAlpha(230),
            Colors.black.withAlpha(250),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Faster Discovery, Instant Trading',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text('🚀', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                // 副标题
                Text(
                  'Fast on-chain operations, one-click trading; auto TP/SL.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // 按钮组
                Row(
                  children: [
                    // 注册按钮
                    Expanded(
                      child: GestureDetector(
                        onTap: onRegister,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF3A3A3C),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 登录按钮
                    Expanded(
                      child: GestureDetector(
                        onTap: onLogin,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
