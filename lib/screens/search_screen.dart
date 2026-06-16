import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// Search Pop-up screen, cloned from the Figma "Search Pop up" frame
/// (node 38:2). Reached from the Map search bar; the back arrow returns to the
/// Map. The location cards are presentational (not wired in the prototype).
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _welcome(),
                  const SizedBox(height: AppSpacing.xxl),
                  _recentSearches(),
                  const SizedBox(height: AppSpacing.xxl),
                  _popularLocations(),
                  const SizedBox(height: AppSpacing.xxl),
                  _nearYourClasses(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      color: const Color(0xE6FFFFFF),
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.pop(),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.arrow_back, size: 18, color: AppColors.petInk),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEEEF),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.amber, width: 2),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, size: 18, color: Color(0xFF6B7280)),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text('Where to, explorer?',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF6B7280))),
                      ),
                      Icon(Icons.mic_none, size: 18, color: Color(0xFF6B7280)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcome() {
    return Row(
      children: [
        Image.asset('assets/images/shark_side.png', width: 66, height: 66),
        const SizedBox(width: AppSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Find your way,',
                style: TextStyle(fontSize: 16, color: Color(0xFF001736))),
            Text('Your companion is ready to lead!',
                style: TextStyle(fontSize: 16, color: AppColors.fieldIcon)),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 16, color: AppColors.navy));
  }

  Widget _recentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Recent Searches'),
            const Text('Clear All',
                style: TextStyle(fontSize: 16, color: AppColors.amber)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: Color(0xFFEDEEEF), shape: BoxShape.circle),
                child: const Icon(Icons.history,
                    size: 18, color: AppColors.petInk),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('Vivian Engineering Center',
                  style: TextStyle(fontSize: 14, color: Color(0xFF191C1D))),
              const Text('Visited 2h ago',
                  style: TextStyle(fontSize: 12, color: AppColors.fieldIcon)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _popularLocations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Popular Locations'),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x1A101828), blurRadius: 15, offset: Offset(0, 10)),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -64,
                top: -64,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: const BoxDecoration(
                      color: Color(0x1AFFFFFF), shape: BoxShape.circle),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                        color: AppColors.amber, shape: BoxShape.circle),
                    child: const Icon(Icons.school,
                        size: 22, color: AppColors.navy),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Student Union',
                      style: TextStyle(fontSize: 16, color: AppColors.surface)),
                  const Text('Events, Food & Lounge',
                      style: TextStyle(
                          fontSize: 16, color: Color(0xCCFFFFFF))),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: const [
                      Icon(Icons.location_on,
                          size: 14, color: AppColors.surface),
                      SizedBox(width: AppSpacing.sm),
                      Text('0.4 miles away',
                          style:
                              TextStyle(fontSize: 16, color: AppColors.surface)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nearYourClasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Near Your Classes'),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 116,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _classCard(
                icon: Icons.park_outlined,
                title: 'North Garden',
                subtitle: 'Quiet study spot',
                badge: 'Highly Rated',
                badgeBg: const Color(0x33FEB700),
                badgeInk: const Color(0xFF191C1D),
              ),
              const SizedBox(width: AppSpacing.md),
              _classCard(
                icon: Icons.local_cafe_outlined,
                title: 'Brew & Byte',
                subtitle: 'In Computer Science',
                badge: 'Open Now',
                badgeBg: const Color(0xFFEDEEEF),
                badgeInk: AppColors.fieldIcon,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _classCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeBg,
    required Color badgeInk,
  }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: const Color(0xFFE7E8E9),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 24, color: AppColors.petInk),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF191C1D))),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.fieldIcon)),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(badge,
                      style: TextStyle(fontSize: 10, color: badgeInk)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
