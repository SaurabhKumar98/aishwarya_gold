// lib/res/widgets/custom_error_widget.dart
import 'package:flutter/material.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';

class CustomErrorWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final ErrorType type;
  final bool showCloseButton;
  final bool animate;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.fontSize,
    this.padding,
    this.margin,
    this.type = ErrorType.error,
    this.showCloseButton = false,
    this.animate = true,
  }) : super(key: key);

  @override
  State<CustomErrorWidget> createState() => _CustomErrorWidgetState();
}

class _CustomErrorWidgetState extends State<CustomErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isVisible = false);
        widget.onDismiss?.call();
      }
    });
  }

  ErrorTypeConfig _getTypeConfig() {
    switch (widget.type) {
      case ErrorType.error:
        return ErrorTypeConfig(
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade300,
          iconColor: Colors.red.shade600,
          textColor: Colors.red.shade800,
          icon: Icons.error_outline_rounded,
        );
      case ErrorType.warning:
        return ErrorTypeConfig(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade300,
          iconColor: Colors.orange.shade600,
          textColor: Colors.orange.shade900,
          icon: Icons.warning_amber_rounded,
        );
      case ErrorType.info:
        return ErrorTypeConfig(
          backgroundColor: AppColors.accentRed,
          borderColor: AppColors.accentRed,
          iconColor: AppColors.accentRed,
          textColor: AppColors.accentRed,
          icon: Icons.info_outline_rounded,
        );
      case ErrorType.success:
        return ErrorTypeConfig(
          backgroundColor: AppColors.coinBrown,
          borderColor: AppColors.coinBrown,
          iconColor: AppColors.coinBrown,
          textColor: AppColors.coinBrown,
          icon: Icons.check_circle_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final config = _getTypeConfig();
    final effectiveBackgroundColor = widget.backgroundColor ?? config.backgroundColor;
    final effectiveBorderColor = widget.borderColor ?? config.borderColor;
    final effectiveIconColor = widget.iconColor ?? config.iconColor;
    final effectiveTextColor = widget.textColor ?? config.textColor;
    final effectiveIcon = widget.icon ?? config.icon;

    Widget content = Container(
      width: double.infinity,
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: effectiveBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: effectiveBorderColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Icon with pulse effect
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    effectiveIcon,
                    color: effectiveIconColor,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // Message
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.message,
                style: TextStyle(
                  color: effectiveTextColor,
                  fontSize: widget.fontSize ?? 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onRetry != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onRetry,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: effectiveIconColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: effectiveIconColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Retry",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (widget.showCloseButton || widget.onDismiss != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        color: effectiveIconColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (widget.animate) {
      return SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: content,
        ),
      );
    }

    return content;
  }
}

enum ErrorType {
  error,
  warning,
  info,
  success,
}

class ErrorTypeConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  ErrorTypeConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}

// Example usage
class ErrorWidgetExamples extends StatelessWidget {
  const ErrorWidgetExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Error message
          CustomErrorWidget(
            message: 'Failed to load data. Please check your connection.',
            type: ErrorType.error,
            onRetry: () {
              // Retry logic
            },
            showCloseButton: true,
          ),

          // Warning message
          CustomErrorWidget(
            message: 'Your session will expire in 5 minutes.',
            type: ErrorType.warning,
            showCloseButton: true,
          ),

          // Info message
          CustomErrorWidget(
            message: 'New features are available. Update to access them.',
            type: ErrorType.info,
            onDismiss: () {
              // Dismiss logic
            },
          ),

          // Success message
          CustomErrorWidget(
            message: 'Your order has been placed successfully!',
            type: ErrorType.success,
            showCloseButton: true,
          ),
        ],
      ),
    );
  }
}