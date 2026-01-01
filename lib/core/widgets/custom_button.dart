import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // nullable عشان disabled
  final bool isLoading;
  final bool isOutlined;
  final Color? color; // لو عايز لون مخصص
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.width,
    this.height = 64,
    this.borderRadius = 32,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color primaryColor = color ?? theme.colorScheme.primary;
    final Color accentColor = theme.colorScheme.secondary;

    final bool isEnabled = onPressed != null && !isLoading;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
            gradient: isOutlined
                ? null
                : LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: isOutlined
              ? OutlinedButton(
                  onPressed: isEnabled ? onPressed : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor, width: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  child: _buildChild(context, primaryColor),
                )
              : ElevatedButton(
                  onPressed: isEnabled ? onPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    elevation: 0,
                  ),
                  child: _buildChild(context, Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context, Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(textColor.withOpacity(0.8)),
          backgroundColor: textColor.withOpacity(0.2),
        ),
      );
    }

    return Text(
      text,
      style:
          Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: 1.5,
            fontSize: 20,
          ) ??
          TextStyle(
            fontWeight: FontWeight.w900,
            color: textColor,
            fontSize: 20,
            letterSpacing: 1.5,
          ),
    );
  }
}
