import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

/// Class Checklist screen, cloned from the Figma "List" frame (node 17:201).
/// A "Class Attainment Checklist" card grid plus a "Daily Tasks" list with gem
/// rewards. The top-right avatar routes to Account Settings (prototype wiring).
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _Goal {
  const _Goal(this.icon, this.title, this.subtitle, this.filled, this.total);
  final IconData icon;
  final String title;
  final String subtitle;
  final int filled;
  final int total;
}

class _Task {
  _Task(this.label, this.reward, {this.done = false});
  final String label;
  final int reward; // 0 => no gem reward shown
  bool done;
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  static const _goals = [
    _Goal(Icons.school_outlined, 'Attend Lecture', 'CS 328', 3, 5),
    _Goal(Icons.local_library_outlined, 'Library Study', '2 Hours', 1, 3),
    _Goal(Icons.people_outline, 'Group Project', 'Meeting', 0, 2),
    _Goal(Icons.edit_outlined, 'Submit\nAssignment', 'Math 101', 2, 3),
  ];

  final _tasks = [
    _Task('Go to VEC 518', 5),
    _Task('Go to VEC 330', 0, done: true),
    _Task('Go to ECS 105', 10),
  ];

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
                  _checklistSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _dailyTasksSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NaviBottomNav(active: NaviTab.menu),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 1),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/map'),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.arrow_back,
                          size: 20, color: AppColors.petInk),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'NaviPet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000F28),
                      letterSpacing: -0.24,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/account'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/images/shark_face.png',
                      fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(
              child: Text(
                'Class Attainment\nChecklist',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Color(0xFF000F28)),
              ),
            ),
            Text(
              '4/12\nCompleted',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                  letterSpacing: 0.48,
                  color: AppColors.labelInk),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.9,
          children: [for (final g in _goals) _goalCard(g)],
        ),
      ],
    );
  }

  Widget _goalCard(_Goal g) {
    final active = g.filled > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
              color: active ? AppColors.yellow : AppColors.cardBorder,
              width: 4),
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F002A4E), offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Opacity(
        opacity: active ? 1 : 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(g.icon, size: 28, color: AppColors.petInk),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.28,
                        letterSpacing: 0.28,
                        color: Color(0xFF000F28))),
                const SizedBox(height: 4),
                Text(g.subtitle,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.labelInk)),
                const SizedBox(height: AppSpacing.sm),
                _pips(g.filled, g.total),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pips(int filled, int total) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: i < filled ? AppColors.yellow : AppColors.cardBorder,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          if (i != total - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }

  Widget _dailyTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Tasks',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000F28))),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0F002A4E), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < _tasks.length; i++) ...[
                _taskRow(_tasks[i]),
                if (i != _tasks.length - 1)
                  const Divider(height: 1, color: AppColors.cardBorder),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _taskRow(_Task task) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => task.done = !task.done),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: task.done ? AppColors.petInk : AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: task.done ? AppColors.petInk : AppColors.fieldIcon),
              ),
              child: task.done
                  ? const Icon(Icons.check, size: 16, color: AppColors.surface)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              task.label,
              style: TextStyle(
                fontSize: 16,
                color: task.done ? AppColors.fieldIcon : AppColors.taskInk,
                decoration:
                    task.done ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          _rewardPill(task),
        ],
      ),
    );
  }

  Widget _rewardPill(_Task task) {
    if (task.done) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
            color: AppColors.cardBorder, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 12, color: AppColors.fieldIcon),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x33FDCC00),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, size: 12, color: AppColors.blue),
          const SizedBox(width: 4),
          Text('+${task.reward}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.48,
                  color: AppColors.gemInk)),
        ],
      ),
    );
  }
}
