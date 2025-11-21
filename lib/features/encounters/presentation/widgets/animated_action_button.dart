import 'package:flutter/material.dart';

class AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final double iconSize;
  final VoidCallback onPressed;

  const AnimatedActionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.size,
    required this.iconSize,
    required this.onPressed,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.12),
              blurRadius: 4,
              spreadRadius: -2,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: widget.iconColor.withOpacity(0.25),
            highlightColor: widget.iconColor.withOpacity(0.10),
            onTap: _handleTap,
            child: Center(
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
