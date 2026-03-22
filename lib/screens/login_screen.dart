import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────
//  Colours used only in auth screens
// ─────────────────────────────────────────────────────────────────
const _kBg        = Color(0xFF1A0E07);
const _kCard      = Color(0xFF2D1F12);
const _kInput     = Color(0xFF3D2A18);
const _kGold      = Color(0xFFFFD700);
const _kRose      = Color(0xFFF4C2C2);
const _kHint      = Color(0xFFAA9080);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey           = GlobalKey<FormState>();
  final _emailCtrl         = TextEditingController();
  final _passwordCtrl      = TextEditingController();
  final _auth              = AuthService();

  bool _passwordVisible = false;
  bool _loading         = false;

  bool get _showApple =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
       defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    await action();
    if (mounted) setState(() => _loading = false);
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Reset password',
            style: TextStyle(color: _kGold, fontWeight: FontWeight.bold)),
        content: _AuthField(
          controller: ctrl,
          hint: 'Your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _kHint)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _auth.resetPassword(email: ctrl.text, context: context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send link', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 52),

              // ── Branding ────────────────────────────────────────
              Image.asset('assets/logo.png', height: 86),
              const SizedBox(height: 14),
              const Text('Steamy Book',
                  style: TextStyle(
                    color: _kGold,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lora',
                    letterSpacing: 1.4,
                  )),
              const SizedBox(height: 6),
              const Text('Your next chapter awaits',
                  style: TextStyle(color: _kRose, fontSize: 13, letterSpacing: 0.4)),

              const SizedBox(height: 44),

              // ── Social buttons ───────────────────────────────────
              _SocialButton(
                label: 'Continue with Google',
                iconWidget: _GoogleG(),
                bgColor: Colors.white,
                textColor: const Color(0xFF1A1A1A),
                onTap: _loading ? null : () => _run(() => _auth.signInWithGoogle(context)),
              ),

              if (_showApple) ...[
                const SizedBox(height: 12),
                _SocialButton(
                  label: 'Continue with Apple',
                  iconWidget: const Icon(Icons.apple, color: Colors.white, size: 22),
                  bgColor: Colors.black,
                  textColor: Colors.white,
                  border: Border.all(color: Colors.white24),
                  onTap: _loading ? null : () => _run(() => _auth.signInWithApple(context)),
                ),
              ],

              const SizedBox(height: 28),
              const _OrDivider(),
              const SizedBox(height: 28),

              // ── Email / password form ────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _AuthField(
                      controller: _emailCtrl,
                      hint: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter your email' : null,
                    ),
                    const SizedBox(height: 14),
                    _AuthField(
                      controller: _passwordCtrl,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: !_passwordVisible,
                      suffix: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _kHint,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _passwordVisible = !_passwordVisible),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter your password' : null,
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPassword,
                  child: const Text('Forgot password?',
                      style: TextStyle(color: _kRose, fontSize: 13)),
                ),
              ),

              // ── Sign-in button ───────────────────────────────────
              _PrimaryButton(
                label: 'Sign In',
                loading: _loading,
                onTap: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await _run(() => _auth.signInWithEmail(
                        email: _emailCtrl.text,
                        password: _passwordCtrl.text,
                        context: context,
                      ));
                },
              ),

              const SizedBox(height: 28),

              // ── Go to register ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?  ",
                      style: TextStyle(color: _kHint, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Sign Up',
                        style: TextStyle(
                            color: _kGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                ],
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Shared widgets (private to this file)
// ─────────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final Color bgColor;
  final Color textColor;
  final Border? border;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.label,
    required this.iconWidget,
    required this.bgColor,
    required this.textColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.12), thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text('or', style: TextStyle(color: _kHint, fontSize: 13)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.12), thickness: 1)),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kHint, fontSize: 14),
        prefixIcon: Icon(icon, color: _kHint, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: _kInput,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kGold, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade700),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade700),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGold,
          disabledBackgroundColor: const Color(0xFF7A6520),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2.5),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
      ),
    );
  }
}

/// Google "G" logo replica
class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Stack(
        children: [
          // Coloured quadrants
          ClipOval(
            child: CustomPaint(
              size: const Size(24, 24),
              painter: _GoogleGPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Blue top-right
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -1.57, 1.57,
        true, Paint()..color = const Color(0xFF4285F4));
    // Red top-left
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -3.14, 1.57,
        true, Paint()..color = const Color(0xFFEA4335));
    // Yellow bottom-left
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 3.14, 1.57,
        true, Paint()..color = const Color(0xFFFBBC05));
    // Green bottom-right
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 0, 1.57,
        true, Paint()..color = const Color(0xFF34A853));

    // White inner circle + G bar
    canvas.drawCircle(c, r * 0.55, Paint()..color = Colors.white);
    canvas.drawRect(
      Rect.fromLTWH(c.dx - 0.5, c.dy - 2, r * 0.45, 4),
      Paint()..color = const Color(0xFF4285F4),
    );
    canvas.drawRect(
      Rect.fromLTWH(c.dx - 0.5, c.dy - 2, 2, r * 0.55),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
