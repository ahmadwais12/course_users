import 'package:flutter/material.dart';
import 'package:course_users/widgets/adaptive/student_lifestyle_page.dart';

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentLifestylePage(
      title: 'Teachers',
      tableName: 'teachers',
      icon: Icons.school_rounded,
      fields: ['full_name', 'specialization', 'status', 'email'],
      accent: Color(0xFF2563EB),
    );
  }
}
