import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state.dart';
import '../widgets/native_input.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isEmailValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = _emailController.text;
    setState(() {
      _isEmailValid = email.contains('@') && email.contains('.');
    });
  }

  Future<void> _handleLogin() async {
    if (!_isEmailValid || _isLoading) return;

    setState(() => _isLoading = true);

    final authState = context.read<AuthState>();
    final success = await authState.login(_emailController.text, 'password123');

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);

    final authState = context.read<AuthState>();
    final success = await authState.socialLogin(provider);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 8),
              // 返回按钮 - 精确还原
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              // 标题 - 精确还原字体大小和粗细
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 32),
              // 邮箱输入框 - 精确还原样式
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: NativeInput(
                  controller: _emailController,
                  hintText: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                  backgroundColor: const Color(0xFF1C1C1E),
                  textColor: Colors.white,
                  hintColor: const Color(0xFF8E8E93),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              // 下一步按钮
              GestureDetector(
                onTap: _handleLogin,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isEmailValid
                        ? const Color(0xFF5CE1D6)
                        : const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _isEmailValid
                                  ? Colors.black
                                  : const Color(0xFF8E8E93),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 注册 & 忘记密码 - 精确还原布局
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'No account?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // OR 分隔线 - 精确还原
              Row(
                children: [
                  Expanded(
                    child: Container(height: 0.5, color: const Color(0xFF3A3A3C)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 0.5, color: const Color(0xFF3A3A3C)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Telegram 按钮
              _buildSocialButton(
                icon: Icons.send,
                label: 'Telegram',
                iconColor: Colors.white,
                onTap: () => _handleSocialLogin('Telegram'),
              ),
              const SizedBox(height: 12),
              // Phantom 按钮
              _buildSocialButton(
                icon: Icons.auto_awesome,
                label: 'Phantom',
                iconColor: const Color(0xFFAB9FF2),
                isPhantom: true,
                onTap: () => _handleSocialLogin('Phantom'),
              ),
              const SizedBox(height: 12),
              // Google 按钮
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                isGoogle: true,
                onTap: () => _handleSocialLogin('Google'),
              ),
              const SizedBox(height: 40),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    bool isGoogle = false,
    bool isPhantom = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
              )
            else if (isPhantom)
              // Phantom 幽灵图标
              SizedBox(
                width: 22,
                height: 22,
                child: CustomPaint(
                  painter: PhantomIconPainter(),
                ),
              )
            else
              Transform.rotate(
                angle: -0.4,
                child: Icon(icon, color: iconColor, size: 20),
              ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Phantom 幽灵图标
class PhantomIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFAB9FF2)
      ..style = PaintingStyle.fill;

    final path = Path();
    // 幽灵身体
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.1,
      size.width * 0.9, size.height * 0.5,
    );
    path.lineTo(size.width * 0.9, size.height * 0.9);
    path.lineTo(size.width * 0.75, size.height * 0.75);
    path.lineTo(size.width * 0.6, size.height * 0.9);
    path.lineTo(size.width * 0.5, size.height * 0.75);
    path.lineTo(size.width * 0.4, size.height * 0.9);
    path.lineTo(size.width * 0.25, size.height * 0.75);
    path.lineTo(size.width * 0.1, size.height * 0.9);
    path.lineTo(size.width * 0.1, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.1,
      size.width * 0.5, size.height * 0.1,
    );
    path.close();
    canvas.drawPath(path, paint);

    // 眼睛
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.4),
      size.width * 0.08,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.4),
      size.width * 0.08,
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
