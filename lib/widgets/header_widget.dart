import 'package:flutter/material.dart';
import '../theme.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: pastelBlush,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 40,
              ),
              const SizedBox(width: 8),
              Text(
                'Steamy Book',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: pastelTextBrown,
                ),
              ),
            ],
          ),

          // Icons: Search and Menu
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: implement search
                },
                color: pastelTextBrown,
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  // TODO: implement menu
                },
                color: pastelTextBrown,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
