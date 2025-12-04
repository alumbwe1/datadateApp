import 'dart:ui';
import 'package:datadate/core/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';

enum DialogType { info, success, warning, error, destructive }

class PremiumDialog extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final DialogType type;
  final bool isDismissible;

  const PremiumDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.cancelText = 'Cancel',
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirm,
    this.type = DialogType.info,
    this.isDismissible = true,
  });

  static Future<bool?> show({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    String cancelText = 'Cancel',
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
    DialogType type = DialogType.info,
    bool isDismissible = true,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8 * animation.value,
            sigmaY: 8 * animation.value,
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return PremiumDialog(
          icon: icon,
          iconColor: iconColor,
          title: title,
          message: message,
          cancelText: cancelText,
          confirmText: confirmText,
          confirmColor: confirmColor,
          onConfirm: onConfirm,
          type: type,
          isDismissible: isDismissible,
        );
      },
    );
  }

  @override
  State<PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<PremiumDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _iconController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _iconRotation;
  late Animation<double> _iconScale;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();

    // Main dialog scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Icon entrance animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _iconRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Continuous pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _iconController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _shimmerController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _iconController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Color get _glowColor {
    switch (widget.type) {
      case DialogType.success:
        return Colors.green;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.error:
      case DialogType.destructive:
        return Colors.red;
      default:
        return widget.iconColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.isDismissible
              ? () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop(false);
                }
              : null,
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {}, // Prevent tap from propagating
              child: _buildDialogContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: [
          BoxShadow(
            color: _glowColor.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.90),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                width: 1.5,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconHeader(),
                    const SizedBox(height: 24),
                    _buildTitle(),
                    const SizedBox(height: 12),
                    _buildMessage(),
                    const SizedBox(height: 32),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_iconController, _pulseController]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _iconRotation.value,
          child: Transform.scale(
            scale: _iconScale.value,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  // Icon container with shimmer
                  AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          child!,
                          // Shimmer overlay
                          Positioned.fill(
                            child: ClipOval(
                              child: Transform.translate(
                                offset: Offset(_shimmerAnimation.value * 30, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.0),
                                        Colors.white.withValues(alpha: 0.4),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            widget.iconColor.withValues(alpha: 0.2),
                            widget.iconColor.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.iconColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Text(
        widget.title,
        style: appStyle(
          22,
          Colors.black,
          FontWeight.w800,
        ).copyWith(letterSpacing: -0.3, height: 1.2),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessage() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Text(
        widget.message,
        style: appStyle(
          15,
          Colors.grey[700]!,
          FontWeight.w400,
        ).copyWith(height: 1.6, letterSpacing: -0.2),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Row(
        children: [
          Expanded(child: _buildCancelButton()),
          const SizedBox(width: 12),
          Expanded(child: _buildConfirmButton()),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return _PremiumButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(false);
      },
      isSecondary: true,
      child: Text(
        widget.cancelText,
        style: appStyle(16, Colors.grey[700]!, FontWeight.w600),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return _PremiumButton(
      onPressed: _isConfirming
          ? null
          : () async {
              HapticFeedback.mediumImpact();
              setState(() => _isConfirming = true);

              // Small delay for visual feedback
              await Future.delayed(const Duration(milliseconds: 200));

              if (mounted) {
                Navigator.of(context).pop(true);
                widget.onConfirm();
              }
            },
      color: widget.confirmColor,
      isLoading: _isConfirming,
      child: _isConfirming
          ? SizedBox(width: 20, height: 20, child: LottieLoadingIndicator())
          : Text(
              widget.confirmText,
              style: appStyle(16, Colors.white, FontWeight.w700),
            ),
    );
  }
}

class _PremiumButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final bool isSecondary;
  final bool isLoading;

  const _PremiumButton({
    required this.onPressed,
    required this.child,
    this.color,
    this.isSecondary = false,
    this.isLoading = false,
  });

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            gradient: widget.isSecondary
                ? null
                : LinearGradient(
                    colors: isDisabled
                        ? [Colors.grey[300]!, Colors.grey[300]!]
                        : [
                            widget.color ?? Colors.black,
                            (widget.color ?? Colors.black).withValues(
                              alpha: 0.85,
                            ),
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            color: widget.isSecondary ? Colors.grey[100] : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: !widget.isSecondary && !isDisabled
                ? [
                    BoxShadow(
                      color: (widget.color ?? Colors.black).withValues(
                        alpha: _isPressed ? 0.2 : 0.3,
                      ),
                      blurRadius: _isPressed ? 8 : 12,
                      offset: Offset(0, _isPressed ? 2 : 4),
                    ),
                  ]
                : null,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
