import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';

/// Sign-in screen, ported from the RN `screens/SignInScreen.tsx`.
///
/// There is no real auth: signing in (or creating an account, or continuing as
/// guest) just selects a user from the fixture list and routes to the map.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController(text: 'alex@csulb.edu');
  final _passwordController = TextEditingController(text: 'navipet');
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _enterApp({bool guest = false}) {
    final email = guest ? 'guest@navipet.app' : _emailController.text;
    context.read<AppState>().signIn(email);
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.signInBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 408),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _brand(),
                  const SizedBox(height: 32),
                  _form(),
                  const SizedBox(height: 32),
                  _footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      children: [
        SizedBox(
          width: 192,
          height: 192,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/mascot.png',
                width: 192,
                height: 192,
                fit: BoxFit.contain,
              ),
              Positioned(
                bottom: -8,
                left: 24,
                right: 24,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0x0D000000),
                    borderRadius: BorderRadius.circular(78),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'NaviPet',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your friendly journey companion',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.labelInk),
        ),
      ],
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(
          label: 'EMAIL ADDRESS',
          controller: _emailController,
          icon: Icons.mail_outline,
          hint: 'hello@navipet.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _field(
          label: 'PASSWORD',
          controller: _passwordController,
          icon: Icons.lock_outline,
          hint: '••••••••',
          obscure: !_showPassword,
          trailing: GestureDetector(
            onTap: () => setState(() => _showPassword = !_showPassword),
            child: Icon(
              _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: AppColors.fieldIcon,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.navy,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _primaryButton(),
        const SizedBox(height: 16),
        _amberButton(),
        const SizedBox(height: 16),
        _guestLink(),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.labelInk,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.fieldIcon),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(fontSize: 14, color: AppColors.ink),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(color: AppColors.fieldIcon, fontSize: 14),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing,
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _primaryButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 10),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _enterApp(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _amberButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 10),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _enterApp(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.amberInk,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
        icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
        label: const Text(
          'Create Account',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _guestLink() {
    return Center(
      child: GestureDetector(
        onTap: () => _enterApp(guest: true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Continue as Guest',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.labelInk,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 14, color: AppColors.labelInk),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.inputBorder,
        ),
        children: [
          TextSpan(text: 'By signing in, you agree to our '),
          TextSpan(
            text: 'Terms',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ],
      ),
    );
  }
}
