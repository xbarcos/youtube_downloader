import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  secondary,
  danger,
  warning,
  success
}

class PrimaryButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Icon icon;
  final String title;
  final double width;
  final ButtonType? type;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.title,
    this.width = 200,
    this.type,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool isLoading = false;

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return Colors.pinkAccent[400]!;
      case ButtonType.secondary:
        return Colors.blueAccent;
      case ButtonType.warning:
        return Colors.orangeAccent;
      case ButtonType.danger:
        return Colors.redAccent[400]!;
      case ButtonType.success:
        return Colors.greenAccent;
      default:
        return Colors.pinkAccent;
    }
  }

  void _handlePressed() async {
    if (widget.onPressed == null) return;

    setState(() => isLoading = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handlePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? _getBackgroundColor() : _getBackgroundColor().withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 6,
          shadowColor: _getBackgroundColor().withOpacity(0.4),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.icon,
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
