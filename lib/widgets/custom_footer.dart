import 'package:flutter/material.dart';
import '../theme.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: const BoxDecoration(
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
          children: const [
            _FooterIcon(icon: Icons.home, label: 'Home'),
            _FooterIcon(icon: Icons.card_giftcard, label: 'Gifts'),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: goldenAccent, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: goldenAccent,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
