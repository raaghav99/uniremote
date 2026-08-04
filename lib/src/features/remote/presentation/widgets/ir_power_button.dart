import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../../../../core/theme.dart';

class IrPowerButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const IrPowerButton({super.key, this.onPressed});

  @override
  State<IrPowerButton> createState() => _IrPowerButtonState();
}

class _IrPowerButtonState extends State<IrPowerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    setState(() => _isPressed = true);
    _controller.forward();
    await HapticFeedback.heavyImpact();
    widget.onPressed?.call();
    await Future.delayed(const Duration(milliseconds: 150));
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.6),
                          blurRadius: 28,
                          spreadRadius: 8,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.25),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
              ),
            ),
            // Button body with gradient
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: _isPressed
                      ? [
                          AppTheme.primary,
                          AppTheme.primary.withOpacity(0.7),
                        ]
                      : [
                          AppTheme.primary.withOpacity(0.85),
                          const Color(0xFFB01030),
                        ],
                  center: const Alignment(-0.3, -0.3),
                  radius: 1.0,
                ),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.power_settings_new_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
