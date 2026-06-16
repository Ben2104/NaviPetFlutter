import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// Account Settings screen, cloned from the Figma "Account Settings" frame
/// (node 73:2). Reached from the Checklist avatar; the back arrow returns.
/// "Switch" and "Add Account" are presentational placeholders.
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accountBg,
      body: Column(
        children: [
          _appBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('CURRENT ACCOUNT'),
                  const SizedBox(height: AppSpacing.md),
                  _currentAccount(),
                  const SizedBox(height: AppSpacing.xl),
                  _label('SWITCH ACCOUNT'),
                  const SizedBox(height: AppSpacing.md),
                  _switchRow(
                    image: 'assets/images/shark_dive.png',
                    name: 'Luna',
                    email: 'luna.pup@navipet.com',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _switchRow(
                    name: 'Cooper',
                    email: 'coop_pet_dad@gmail.com',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _addAccountButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.canPop() ? context.pop() : context.go('/map'),
                child: const SizedBox(
                  width: 32,
                  height: 40,
                  child: Icon(Icons.arrow_back, size: 18, color: AppColors.accountTitle),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              const Text('Account Settings',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accountTitle)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
            color: AppColors.accountLabel));
  }

  Widget _currentAccount() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _avatar(image: 'assets/images/shark_face.png', size: 52),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Elbee',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF020027))),
                Text('elbee@banana.com',
                    style: TextStyle(fontSize: 14, color: AppColors.subtext)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.addBtn,
                borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: const Text('Active',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.yellowInk)),
          ),
        ],
      ),
    );
  }

  Widget _switchRow({String? image, required String name, required String email}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          if (image != null)
            _avatar(image: image, size: 44)
          else
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  color: Color(0xFFE2DFFF), shape: BoxShape.circle),
              child: const Icon(Icons.person_outline,
                  size: 18, color: AppColors.accountTitle),
            ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16, color: Color(0xFF020027))),
                Text(email,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.subtext)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: const Color(0xFF78767F))),
            child: const Text('Switch',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF020027))),
          ),
        ],
      ),
    );
  }

  Widget _addAccountButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.addBtn,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A101828), blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_circle_outline, size: 20, color: AppColors.yellowInk),
          SizedBox(width: AppSpacing.sm),
          Text('Add Account',
              style: TextStyle(fontSize: 16, color: AppColors.yellowInk)),
        ],
      ),
    );
  }

  Widget _avatar({required String image, required double size}) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Image.asset(image, fit: BoxFit.cover),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(color: Color(0x0F1A1A40), blurRadius: 6, offset: Offset(0, 4)),
      ],
    );
  }
}
