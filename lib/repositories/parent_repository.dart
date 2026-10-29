import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parent_model.dart';

class ParentRepository {
  final _client = Supabase.instance.client;

  Future<List<Parent>> getParents() async {
    // Guardians live in profiles; their linked children come from
    // parent_students.
    final profiles = await _client
        .from('users')
        .select('id, full_name, email, phone, address')
        .eq('role', 'guardian');
    final links = await _client.from('parent_students').select('parent_id, student_id');

    final byParent = <String, List<String>>{};
    for (final link in links) {
      final pid = link['parent_id']?.toString();
      final sid = link['student_id']?.toString();
      if (pid != null && sid != null) {
        byParent.putIfAbsent(pid, () => []).add(sid);
      }
    }

    return (profiles as List)
        .map((e) => Parent(
              id: e['id']?.toString() ?? '',
              fullName: e['full_name']?.toString() ?? '',
              email: e['email']?.toString() ?? '',
              phone: e['phone']?.toString() ?? '',
              childIds: byParent[e['id']?.toString()] ?? [],
              address: e['address']?.toString(),
            ))
        .toList();
  }

  Future<void> addParent(Parent parent) async {
    await _client.from('users').update({
      'full_name': parent.fullName,
      'email': parent.email,
      'phone': parent.phone,
      'address': parent.address,
      'role': 'guardian',
    }).eq('id', parent.id);
    for (final childId in parent.childIds) {
      await _client.from('parent_students').upsert({
        'parent_id': parent.id,
        'student_id': childId,
      });
    }
  }

  Future<void> updateParent(Parent parent) async {
    await _client.from('users').update({
      'full_name': parent.fullName,
      'email': parent.email,
      'phone': parent.phone,
      'address': parent.address,
    }).eq('id', parent.id);
  }
}
