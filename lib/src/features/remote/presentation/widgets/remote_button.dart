import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../../../../core/theme.dart';

class RemoteButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final bool showLabel;

  const RemoteButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 56,
    this.showLabel = true,
  });

  @override
  State<RemoteButton> createState() => _RemoteButtonState();
}

class _RemoteButtonState extends State<RemoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
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
    await HapticFeedback.mediumImpact();
    widget.onPressed?.call();
    await Future.delayed(const Duration(milliseconds: 120));
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppTheme.surface;
    final highlightColor = _isPressed
        ? (widget.color ?? AppTheme.primary).withOpacity(0.3)
        : buttonColor;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlightColor,
                border: Border.all(
                  color: _isPressed
                      ? AppTheme.primary.withOpacity(0.8)
                      : AppTheme.dividerColor,
                  width: 1.5,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: (widget.color ?? AppTheme.primary)
                              .withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Icon(
                widget.icon,
                color: _isPressed ? AppTheme.primary : AppTheme.onSurface,
                size: widget.size * 0.45,
              ),
            ),
            if (widget.showLabel) ...[
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: AppTheme.onSurface.withOpacity(0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
