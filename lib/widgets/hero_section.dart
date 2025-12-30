import 'package:flutter/material.dart';
import 'animated_dogecoin.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Dogecoin - 若影若现
          const Positioned(
            right: 0,
            top: 10,
            child: AnimatedDogecoin(
              size: 140,
              opacity: 0.2,
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance header
              Row(
                children: [
                  Text(
                    '总余额',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: Colors.grey[500],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Balance amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '0',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0B90B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.diamond_outlined,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'BNB',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
