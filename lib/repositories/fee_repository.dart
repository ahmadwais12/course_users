import 'package:flutter/foundation.dart';
import 'package:course_users/models/fee_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Everything shown for one student in the fees portal.
class StudentFeeStatement {
  final StudentIdentity student;
  final List<StudentFeeAssignment> assignments;
  final Map<String, List<FeeInstallment>> installmentsByAssignment;
  final List<FeePayment> payments;
  final List<FeeInvoice> invoices;

  const StudentFeeStatement({
    required this.student,
    required this.assignments,
    required this.installmentsByAssignment,
    required this.payments,
    required this.invoices,
  });

  double get totalAssigned =>
      assignments.fold<double>(0, (s, a) => s + a.amount);
  double get totalPaid => assignments.fold<double>(0, (s, a) => s + a.paidAmount);
  double get totalOutstanding =>
      assignments.fold<double>(0, (s, a) => s + a.outstandingAmount);
  double get invoiceTotalOutstanding => invoices.fold<double>(
      0, (s, i) => s + i.outstandingAmount);
}

/// Read-only data access for the student & parent fee portal.
///
/// Resolution rules (mirror the rest of the app):
///  - a student logs in with their profile, which links to `students.profile_id`;
///  - a parent links to children through `parent_students.parent_id` = the
///    parent's auth/profile id.
class FeeRepository {
  final SupabaseClient _client;
  FeeRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // --------------------------------------------------------------------------
  // Who is the current user?
  // --------------------------------------------------------------------------

  Future<String?> _role() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      return _client.auth.currentUser?.userMetadata?['role']?.toString();
    }
    try {
      final rows = await _client
          .from('users')
          .select('role')
          .eq('id', uid)
          .limit(1);
      if (rows.isNotEmpty && rows.first['role'] != null) {
        return rows.first['role'] as String;
      }
    } catch (e) {
      debugPrint('FeeRepository: profile role lookup failed: $e');
    }
    return _client.auth.currentUser?.userMetadata?['role']?.toString();
  }

  /// Students visible to the current user (own record for a student,
  /// linked children for a parent/guardian). Empty when none are linked.
  Future<List<StudentIdentity>> myStudents() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final role = (await _role())?.toLowerCase() ?? '';

    if (role == 'parent' || role == 'guardian') {
      // parent_students.parent_id is the parent auth/profile id in this app;
      // fall back to the parents row if it instead stores the parents.id.
      final rows = await _client
          .from('parent_students')
          .select('student_id')
          .eq('parent_id', uid);
      var studentIds = rows
          .map((r) => (r['student_id'] as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (studentIds.isEmpty) {
        try {
          final parentRows = await _client
              .from('parents')
              .select('id')
              .eq('profile_id', uid)
              .limit(10);
          final parentIds =
              parentRows.map((r) => (r['id'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
          if (parentIds.isNotEmpty) {
            final fallback = await _client
                .from('parent_students')
                .select('student_id')
                .inFilter('parent_id', parentIds);
            studentIds = fallback
                .map((r) => (r['student_id'] as String?) ?? '')
                .where((s) => s.isNotEmpty)
                .toList();
          }
        } catch (e) {
          debugPrint('FeeRepository: parent lookup fallback failed: $e');
        }
      }
      if (studentIds.isEmpty) return [];
      final studentRows = await _client
          .from('students')
          .select('id, full_name, student_code, class_id')
          .inFilter('id', studentIds);
      final classNames = await _nameMap('classes');
      return studentRows
          .map((r) {
            final json = Map<String, dynamic>.from(r);
            json['class_name'] = classNames[json['class_id']];
            return StudentIdentity.fromJson(json);
          })
          .toList();
    }

    // Student role (default): own students record(s).
    final rows = await _client
        .from('students')
        .select('id, full_name, student_code, class_id')
        .eq('profile_id', uid)
        .limit(10);
    final classNames = await _nameMap('classes');
    return rows
        .map((r) {
          final json = Map<String, dynamic>.from(r);
          json['class_name'] = classNames[json['class_id']];
          return StudentIdentity.fromJson(json);
        })
        .toList();
  }

  // --------------------------------------------------------------------------
  // Statement data for one student
  // --------------------------------------------------------------------------

  Future<StudentFeeStatement> loadStatement(String studentId) async {
    final identity = await _studentIdentity(studentId);

    // Assignments enriched with fee type / structure display names.
    final assignmentRows = await _client
        .from('student_fee_assignments')
        .select()
        .eq('student_id', studentId)
        .order('due_date', ascending: false);
    final feeTypeNames = await _nameMap('fee_types');
    final structureNames = await _nameMap('fee_structures');
    final assignments = assignmentRows.map((r) {
      final json = Map<String, dynamic>.from(r);
      json['fee_type_name'] = feeTypeNames[json['fee_type_id']];
      json['structure_name'] = structureNames[json['fee_structure_id']];
      json['student_name'] = identity.fullName;
      return StudentFeeAssignment.fromJson(json);
    }).toList();

    // Installments grouped by assignment.
    final installmentRows = await _client
        .from('fee_installments')
        .select()
        .eq('student_id', studentId)
        .order('installment_number');
    final installmentsByAssignment = <String, List<FeeInstallment>>{};
    for (final r in installmentRows) {
      final inst = FeeInstallment.fromJson(Map<String, dynamic>.from(r));
      final key = inst.feeAssignmentId ?? '';
      installmentsByAssignment.putIfAbsent(key, () => []).add(inst);
    }

    // Payments + receipt numbers.
    final payments = await _paymentsForStudent(studentId);

    // Invoices.
    final invoiceRows = await _client
        .from('invoices')
        .select()
        .eq('student_id', studentId)
        .order('issue_date', ascending: false);
    final invoices = invoiceRows
        .map((r) => FeeInvoice.fromJson(Map<String, dynamic>.from(r)))
        .toList();

    return StudentFeeStatement(
      student: identity,
      assignments: assignments,
      installmentsByAssignment: installmentsByAssignment,
      payments: payments,
      invoices: invoices,
    );
  }

  Future<List<FeePayment>> _paymentsForStudent(String studentId) async {
    final rows = await _client
        .from('payments')
        .select()
        .eq('student_id', studentId)
        .order('payment_date', ascending: false);
    if (rows.isEmpty) return [];

    // Receipt numbers per payment (flat lookup, avoids FK-embed issues).
    final paymentIds = rows.map((r) => r['id'] as String).toList();
    final receiptRows = await _client
        .from('receipts')
        .select('payment_id, receipt_no')
        .inFilter('payment_id', paymentIds);
    final receiptByPayment = {
      for (final r in receiptRows)
        (r['payment_id'] as String?) ?? '': (r['receipt_no'] as String?) ?? '',
    };

    return rows.map((r) {
      final json = Map<String, dynamic>.from(r);
      final pid = (r['id'] as String?) ?? '';
      json['receipt_no'] = receiptByPayment[pid];
      return FeePayment.fromJson(json);
    }).toList();
  }

  Future<StudentIdentity> _studentIdentity(String studentId) async {
    final rows = await _client
        .from('students')
        .select('id, full_name, student_code, class_id')
        .eq('id', studentId)
        .limit(1);
    if (rows.isEmpty) {
      return StudentIdentity(id: studentId, fullName: 'Student');
    }
    final classNames = await _nameMap('classes');
    final json = Map<String, dynamic>.from(rows.first);
    json['class_name'] = classNames[json['class_id']];
    return StudentIdentity.fromJson(json);
  }

  Future<Map<String, String>> _nameMap(String table) async {
    try {
      final rows = await _client.from(table).select('id, name').limit(500);
      return {
        for (final r in rows)
          (r['id'] as String): (r['name'] as String?) ?? '',
      };
    } catch (e) {
      debugPrint('FeeRepository: $table name lookup failed: $e');
      return {};
    }
  }
}
