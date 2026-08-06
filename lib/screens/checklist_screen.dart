import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/course_class.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/class_editor_sheet.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  void _edit(BuildContext context, [CourseClass? course]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppState>(),
        child: ClassEditorSheet(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tasks = state.dailyTasks();
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/map'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Achievements'),
        actions: [
          IconButton(
            tooltip: 'Add class',
            onPressed: () => _edit(context),
            icon: const Icon(Icons.add_circle, color: AppColors.petInk),
          ),
          IconButton(
            onPressed: () => context.push('/account'),
            icon: const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/shark_face.png'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: state.refreshClasses,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _intro(context),
            const SizedBox(height: 24),
            _sectionTitle('Class achievements', '${state.classes.length} classes'),
            const SizedBox(height: 12),
            if (state.classesBusy && state.classes.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (state.classes.isEmpty)
              _emptyClasses(context)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .9,
                ),
                itemCount: state.classes.length,
                itemBuilder: (_, index) => _achievementCard(
                  context,
                  state.classes[index],
                  state.completionCountFor(state.classes[index].id),
                ),
              ),
            const SizedBox(height: 28),
            _sectionTitle(
              'Daily tasks',
              '${tasks.where((task) => task.done).length}/${tasks.length} done',
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              const Text('Add a class to create personalized daily tasks.')
            else
              _taskList(context, state, tasks),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.petInk,
        icon: const Icon(Icons.add),
        label: const Text('Add class'),
      ),
      bottomNavigationBar: const NaviBottomNav(active: NaviTab.menu),
    );
  }

  Widget _intro(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.petInk,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: AppColors.yellow,
          backgroundImage: AssetImage('assets/images/shark_side.png'),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your class journey', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
              SizedBox(height: 4),
              Text('Complete class-aware tasks to grow your achievements.', style: TextStyle(color: Color(0xFFD9E6F4), fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title, String detail) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.petInk)),
      Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ],
  );

  Widget _emptyClasses(BuildContext context) => InkWell(
    onTap: () => _edit(context),
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
      child: const Column(children: [
        Icon(Icons.school_outlined, size: 38, color: AppColors.petInk),
        SizedBox(height: 8),
        Text('Add your first class', style: TextStyle(fontWeight: FontWeight.w700)),
        Text('Your tasks, achievements, and nearby places will adapt automatically.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12)),
      ]),
    ),
  );

  Widget _achievementCard(BuildContext context, CourseClass course, int count) {
    final progress = count.clamp(0, 5);
    return InkWell(
      onTap: () => _edit(context, course),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: const Border(left: BorderSide(color: AppColors.yellow, width: 4)), boxShadow: AppShadows.soft),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.workspace_premium_outlined, size: 30, color: AppColors.petInk),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.courseCode, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(course.courseName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 10),
              Row(children: List.generate(5, (index) => Expanded(child: Container(height: 7, margin: EdgeInsets.only(right: index == 4 ? 0 : 3), decoration: BoxDecoration(color: index < progress ? AppColors.yellow : AppColors.cardBorder, borderRadius: BorderRadius.circular(8)))))),
              const SizedBox(height: 6),
              Text('$count tasks completed · Tap to edit', style: const TextStyle(fontSize: 10, color: AppColors.faint)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _taskList(BuildContext context, AppState state, List<DailyClassTask> tasks) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppShadows.soft),
    child: Column(children: [
      for (var index = 0; index < tasks.length; index++) ...[
        ListTile(
          onTap: () async {
            try {
              await state.toggleTask(tasks[index], DateTime.now());
            } catch (error) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update task: $error')));
            }
          },
          leading: Checkbox(value: tasks[index].done, activeColor: AppColors.petInk, onChanged: (_) => state.toggleTask(tasks[index], DateTime.now())),
          title: Text(tasks[index].label, style: TextStyle(decoration: tasks[index].done ? TextDecoration.lineThrough : null)),
          subtitle: Text('${tasks[index].course.startTime} · ${tasks[index].course.courseName}', maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: tasks[index].done ? const Icon(Icons.check_circle, color: AppColors.green) : Text('+${tasks[index].reward} 💎', style: const TextStyle(color: AppColors.gemInk, fontWeight: FontWeight.w700)),
        ),
        if (index < tasks.length - 1) const Divider(height: 1, indent: 64),
      ],
    ]),
  );
}
