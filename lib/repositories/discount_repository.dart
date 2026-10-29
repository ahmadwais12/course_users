import 'package:course_users/models/discount.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscountRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Discount>> getAll() async {
    final data = await _supabase
        .from('discounts')
        .select()
        .order('created_at', ascending: false);
    return (data as List)
        .map((json) => Discount.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> create(Discount discount) async {
    await _supabase.from('discounts').insert(_toRow(discount));
  }

  Future<void> update(Discount discount) async {
    await _supabase.from('discounts').update(_toRow(discount)).eq('id', discount.id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('discounts').delete().eq('id', id);
  }

  Map<String, dynamic> _toRow(Discount d) => {
        'name': d.type.name,
        'type': d.type.name,
        'percentage': d.percentage,
        'value': d.percentage,
        if (d.conditions != null) 'description': d.conditions,
        if (d.validUntil != null) 'valid_until': d.validUntil!.toIso8601String(),
        'active': d.isActive,
      };
}
