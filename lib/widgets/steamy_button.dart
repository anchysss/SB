import 'package:flutter/material.dart';

class SteamyButton extends StatefulWidget {
  final bool isSteamy;
  final bool loading;
  final VoidCallback onPressed;

  const SteamyButton({
    Key? key,
    required this.isSteamy,
    required this.loading,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<SteamyButton> createState() => _SteamyButtonState();
}

class _SteamyButtonState extends State<SteamyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isSteamy || widget.loading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 24),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isSteamy ? Colors.pink.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: widget.isSteamy
                  ? [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(_glowAnimation.value * 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 💨 Para efekat (neobavezno - koristi PNG overlay ako imaš)
                    if (widget.isSteamy)
                      Positioned(
                        top: -8,
                        child: Opacity(
                          opacity: _glowAnimation.value * 0.3,
                          child: Image.asset(
                            'assets/icons/steam_overlay.png',
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ),
                    // 💋 Statična slika usana sa animiranim sjajem
                    Opacity(
                      opacity: _glowAnimation.value,
                      child: Image.asset(
                        'assets/icons/steamy_lips.png',
                        width: 34,
                        height: 34,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Text(
                  widget.isSteamy ? 'Steamy! 💋' : 'Mark as Steamy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isSteamy ? Colors.redAccent : Colors.brown,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
