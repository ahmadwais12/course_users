import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/finance_model.dart';

class FinanceRepository {
  final _client = Supabase.instance.client;

  Future<List<Finance>> getFinanceRecords() async {
    final response = await _client.from('finance').select();
    return (response as List).map((e) => Finance.fromJson(e)).toList();
  }

  Future<void> addFinanceRecord(Finance finance) async {
    await _client.from('finance').insert(finance.toJson());
  }

  Future<void> updateFinanceRecord(Finance finance) async {
    // Assuming Finance has an id field, but it doesn't.
    // Let's just implement a dummy or check if it has an id.
    // Wait, Finance model doesn't have an id. Let's check Finance model.
  }
}
