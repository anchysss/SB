import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

const _kBg    = Color(0xFF1A0E07);
const _kCard  = Color(0xFF2D1F12);
const _kInput = Color(0xFF3D2A18);
const _kGold  = Color(0xFFFFD700);
const _kRose  = Color(0xFFF4C2C2);
const _kHint  = Color(0xFFAA9080);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _auth         = AuthService();

  bool _passVisible    = false;
  bool _confirmVisible = false;
  bool _loading        = false;

  bool get _showApple =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
       defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    await action();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Back button ──────────────────────────────────────
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: _kGold, size: 20),
                padding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),

              // ── Title ────────────────────────────────────────────
              const Text('Create account',
                  style: TextStyle(
                      color: _kGold,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lora')),
              const SizedBox(height: 6),
              const Text('Join the story — it\'s free',
                  style: TextStyle(color: _kRose, fontSize: 13)),

              const SizedBox(height: 32),

              // ── Social sign-up ───────────────────────────────────
              _SocialBtn(
                label: 'Sign up with Google',
                iconWidget: _GoogleG(),
                bgColor: Colors.white,
                textColor: const Color(0xFF1A1A1A),
                onTap: _loading ? null : () => _run(() => _auth.signInWithGoogle(context)),
              ),

              if (_showApple) ...[
                const SizedBox(height: 12),
                _SocialBtn(
                  label: 'Sign up with Apple',
                  iconWidget: const Icon(Icons.apple, color: Colors.white, size: 22),
                  bgColor: Colors.black,
                  textColor: Colors.white,
                  border: Border.all(color: Colors.white24),
                  onTap: _loading ? null : () => _run(() => _auth.signInWithApple(context)),
                ),
              ],

              const SizedBox(height: 28),
              _OrDivider(),
              const SizedBox(height: 28),

              // ── Email form ───────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name
                    _Field(
                      controller: _nameCtrl,
                      hint: 'Full name',
                      icon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 14),

                    // Email
                    _Field(
                      controller: _emailCtrl,
                      hint: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _Field(
                      controller: _passCtrl,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: !_passVisible,
                      suffix: _EyeToggle(
                        visible: _passVisible,
                        onToggle: () => setState(() => _passVisible = !_passVisible),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Confirm password
                    _Field(
                      controller: _confirmCtrl,
                      hint: 'Confirm password',
                      icon: Icons.lock_outline,
                      obscureText: !_confirmVisible,
                      suffix: _EyeToggle(
                        visible: _confirmVisible,
                        onToggle: () =>
                            setState(() => _confirmVisible = !_confirmVisible),
                      ),
                      validator: (v) =>
                          v != _passCtrl.text ? 'Passwords do not match' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Create account button ────────────────────────────
              _PrimaryBtn(
                label: 'Create Account',
                loading: _loading,
                onTap: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await _run(() => _auth.signUpWithEmail(
                        name: _nameCtrl.text,
                        email: _emailCtrl.text,
                        password: _passCtrl.text,
                        context: context,
                      ));
                },
              ),

              const SizedBox(height: 24),

              // ── Go to login ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?  ',
                      style: TextStyle(color: _kHint, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Sign In',
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
//  Private widgets
// ─────────────────────────────────────────────────────────────────

class _SocialBtn extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final Color bgColor;
  final Color textColor;
  final Border? border;
  final VoidCallback? onTap;

  const _SocialBtn({
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
        opacity: onTap == null ? 0.45 : 1.0,
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
                  offset: const Offset(0, 3))
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
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Text('or', style: TextStyle(color: _kHint, fontSize: 13)),
      ),
      Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
    ]);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
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
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kHint, fontSize: 14),
        prefixIcon: Icon(icon, color: _kHint, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: _kInput,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kGold, width: 1.4)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade700)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade700)),
      ),
    );
  }
}

class _EyeToggle extends StatelessWidget {
  final bool visible;
  final VoidCallback onToggle;

  const _EyeToggle({required this.visible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: _kHint,
        size: 20,
      ),
      onPressed: onToggle,
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryBtn({required this.label, required this.loading, this.onTap});

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2.5))
            : Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(24, 24), painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(rect, -1.57, 1.57, true, Paint()..color = const Color(0xFF4285F4));
    canvas.drawArc(rect, -3.14, 1.57, true, Paint()..color = const Color(0xFFEA4335));
    canvas.drawArc(rect, 3.14, 1.57,  true, Paint()..color = const Color(0xFFFBBC05));
    canvas.drawArc(rect, 0,    1.57,  true, Paint()..color = const Color(0xFF34A853));
    canvas.drawCircle(c, r * 0.55, Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(c.dx - 0.5, c.dy - 2, r * 0.45, 4),
        Paint()..color = const Color(0xFF4285F4));
    canvas.drawRect(Rect.fromLTWH(c.dx - 0.5, c.dy - 2, 2, r * 0.55),
        Paint()..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(_) => false;
}
