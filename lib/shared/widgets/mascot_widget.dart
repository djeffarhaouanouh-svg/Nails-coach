import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum MascotMood { neutral, sad, happy }

class MascotWidget extends StatefulWidget {
  final MascotMood mood;
  final double size;

  const MascotWidget({
    super.key,
    this.mood = MascotMood.neutral,
    this.size = 120,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _assetPath {
    switch (widget.mood) {
      case MascotMood.sad:
        return 'assets/images/lapin-1.svg';
      case MascotMood.happy:
        return 'assets/images/lapin-2.svg';
      case MascotMood.neutral:
        return 'assets/images/lapin.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _bounceAnimation.value),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.mood == MascotMood.happy) ...[
                Positioned(
                  top: 0,
                  left: 8,
                  child: _Sparkle(size: 16),
                ),
                Positioned(
                  top: 4,
                  right: 10,
                  child: _Sparkle(size: 20),
                ),
                Positioned(
                  top: 12,
                  left: 28,
                  child: _Sparkle(size: 12),
                ),
              ],
              SvgPicture.asset(
                _assetPath,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double size;
  const _Sparkle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      '✦',
      style: TextStyle(fontSize: size, color: const Color(0xFFFF80AA)),
    );
  }
}
