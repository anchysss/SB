import 'package:flutter/material.dart';
import '../theme.dart';

class CustomHeader extends StatelessWidget {
  final bool showBackButton;

  const CustomHeader({Key? key, this.showBackButton = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showBackButton
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: goldColor),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              : Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 36,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Steamy Book',
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search_rounded, color: goldColor),
                onPressed: () {
                  // TODO: add search action
                },
              ),
              IconButton(
                icon: Icon(Icons.menu_rounded, color: goldColor),
                onPressed: () {
                  // TODO: add menu action
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
