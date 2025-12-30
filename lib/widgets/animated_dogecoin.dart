import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

class AnimatedDogecoin extends StatefulWidget {
  final double size;
  final double opacity;

  const AnimatedDogecoin({
    super.key,
    this.size = 140,
    this.opacity = 0.2,
  });

  @override
  State<AnimatedDogecoin> createState() => _AnimatedDogecoinState();
}

class _AnimatedDogecoinState extends State<AnimatedDogecoin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5500),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: -8 * math.pi / 180,
      end: 8 * math.pi / 180,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.15, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 FadeTransition + SlideTransition 等替代 Opacity，避免 saveLayer 开销
    return FadeTransition(
      opacity: _opacityAnimation,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          );
        },
        child: _buildCoin(),
      ),
    );
  }

  Widget _buildCoin() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glow effect
          Positioned(
            left: -20,
            right: -20,
            top: -20,
            bottom: -20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEAB308).withAlpha(102),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Coin body
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFF0C000),
                  Color(0xFFDAA520),
                  Color(0xFFB8860B),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFC9A227),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFFEAB308).withAlpha(77),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Inner ring decoration
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(51),
                      width: 2,
                    ),
                  ),
                ),
                // Dogecoin logo
                Center(
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: 'https://cryptologos.cc/logos/dogecoin-doge-logo.png',
                      width: widget.size * 0.55,
                      height: widget.size * 0.55,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) {
                        return Icon(
                          Icons.currency_bitcoin,
                          size: widget.size * 0.5,
                          color: Colors.white.withAlpha(204),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
