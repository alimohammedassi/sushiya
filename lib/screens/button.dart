import 'package:flutter/material.dart';

class SushiayaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  const SushiayaButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 56.0,
    this.borderRadius = 16.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isOutlined 
          ? null 
          : const LinearGradient(
              colors: [
                Color(0xFFE67E22), // Orange from your app
                Color(0xFFD35400), // Darker orange
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        border: isOutlined 
          ? Border.all(
              color: const Color(0xFFE67E22),
              width: 2.0,
            ) 
          : null,
        boxShadow: isOutlined 
          ? null 
          : [
              BoxShadow(
                color: const Color(0xFFE67E22).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOutlined 
                          ? const Color(0xFFE67E22)
                          : Colors.white,
                      ),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isOutlined 
                        ? const Color(0xFFE67E22)
                        : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: textStyle ?? TextStyle(
                        color: isOutlined 
                          ? const Color(0xFFE67E22)
                          : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Usage Examples:
class SushiayaButtonExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8E44AD), // Purple background from your app
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Primary Button
            SushiayaButton(
              text: "Order Now",
              onPressed: () {
                print("Order Now pressed");
              },
            ),
            
            const SizedBox(height: 16),
            
            // Button with Icon
            SushiayaButton(
              text: "Add to Cart",
              icon: Icons.shopping_cart,
              onPressed: () {
                print("Add to Cart pressed");
              },
            ),
            
            const SizedBox(height: 16),
            
            // Outlined Button
            SushiayaButton(
              text: "View Menu",
              isOutlined: true,
              onPressed: () {
                print("View Menu pressed");
              },
            ),
            
            const SizedBox(height: 16),
            
            // Loading Button
            SushiayaButton(
              text: "Processing...",
              isLoading: true,
              onPressed: null,
            ),
            
            const SizedBox(height: 16),
            
            // Full Width Button
            SushiayaButton(
              text: "Continue",
              width: double.infinity,
              onPressed: () {
                print("Continue pressed");
              },
            ),
            
            const SizedBox(height: 16),
            
            // Custom Height and Radius
            SushiayaButton(
              text: "Small Button",
              height: 40,
              borderRadius: 20,
              onPressed: () {
                print("Small button pressed");
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Color Constants for your app
class SushiayaColors {
  static const Color primary = Color(0xFFE67E22);
  static const Color primaryDark = Color(0xFFD35400);
  static const Color secondary = Color(0xFF8E44AD);
  static const Color secondaryDark = Color(0xFF7D3C98);
  static const Color background = Color(0xFF8E44AD);
  static const Color surface = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Color(0xFF2C3E50);
}