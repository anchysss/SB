import 'package:flutter/material.dart';

class SteamyLevelIndicator extends StatelessWidget {
  final int steamyPercent;

  const SteamyLevelIndicator({
    Key? key,
    required this.steamyPercent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double opacity = 0.3 + (steamyPercent / 100) * 0.6;
    double size = 28 + (steamyPercent / 3.5);

    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (steamyPercent > 0)
              Opacity(
                opacity: opacity,
                child: Image.asset(
                  'assets/icons/steam_overlay.png',
                  width: size,
                  height: size,
                ),
              ),
            Image.asset(
              'assets/icons/steamy_lips.png',
              width: 24,
              height: 24,
            ),
          ],
        ),
        const SizedBox(width: 6),
        Text(
          '$steamyPercent% steamy',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ],
    );
  }
}
