import 'package:flutter/material.dart';
import '../theme.dart';

class CustomFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: darkFooterBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _FooterIcon(icon: Icons.home, label: 'Home'),
            _FooterIcon(icon: Icons.card_giftcard, label: 'Gifts'), // ili Wards
            _FooterIcon(icon: Icons.bookmark, label: 'My Library'),
          ],
        ),
      ),
    );
  }
}

class _FooterIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // sprečava overflow
      children: [
        Icon(icon, color: goldenAccent, size: 26),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: goldenAccent,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
