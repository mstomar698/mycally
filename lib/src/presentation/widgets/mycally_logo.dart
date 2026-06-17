import 'package:flutter/material.dart';

class MycallyLogo extends StatelessWidget {
  const MycallyLogo({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mycally_logo.png',
      height: size,
      width: size,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.calendar_month,
          size: size * 0.7,
          color: Colors.deepPurple,
        );
      },
    );
  }
}
