import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomButton extends StatelessWidget{
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.padding,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext ctx) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading? null : onPressed, 
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(ctx).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding : padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
          shadowColor: Colors.black.withAlpha(51), // 0.2 opacity = 51 alpha
        ),
        child: isLoading 
        ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color : Colors.white,
            strokeWidth: 2,
          ),
        )
        : Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        )
        ),
    );
  }




}