// Fee engine models: fee_types, fee_structures, student_fee_assignments,
// fee_installments, payments and invoices — mirror supabase_schema.sql.
// Hand-written fromJson/toJson (no build_runner). Display fields such as
// [feeTypeName] / [studentName] are populated from joins and not persisted.

class StudentFeeAssignment {
  final String id;
  final String? tenantId;
  final String? studentId;
  final String? studentName; // joined display field
  final String? feeStructureId;
  final String? feeTypeId;
  final String? feeTypeName; // joined display field
  final String? structureName; // joined display field
  final double amount;
  final double totalAmount;
  final double balanceAmount;
  final String? currency;
  final DateTime? dueDate;
  final String? frequency;
  final String status;
  final double paidAmount;
  final double lateFeeApplied;
  final double discountAmount;
  final String? discountReason;
  final String? notes;
  final DateTime? assignedAt;

  const StudentFeeAssignment({
    required this.id,
    this.tenantId,
    this.studentId,
    this.studentName,
    this.feeStructureId,
    this.feeTypeId,
    this.feeTypeName,
    this.structureName,
    required this.amount,
    this.totalAmount = 0,
    this.balanceAmount = 0,
    this.currency = 'AFN',
    this.dueDate,
    this.frequency,
    this.status = 'pending',
    this.paidAmount = 0,
    this.lateFeeApplied = 0,
    this.discountAmount = 0,
    this.discountReason,
    this.notes,
    this.assignedAt,
  });

  /// Schema-level generated column when present, otherwise computed.
  double get outstandingAmount {
    if (balanceAmount > 0) return balanceAmount;
    return (amount - paidAmount).clamp(0, double.infinity).toDouble();
  }

  factory StudentFeeAssignment.fromJson(Map<String, dynamic> json) =>
      StudentFeeAssignment(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String?,
        studentId: json['student_id'] as String?,
        studentName: json['student_name'] as String?,
        feeStructureId: json['fee_structure_id'] as String?,
        feeTypeId: json['fee_type_id'] as String?,
        feeTypeName: json['fee_type_name'] as String?,
        structureName: json['structure_name'] as String?,
        amount: _num(json['amount']),
        totalAmount: _num(json['total_amount']),
        balanceAmount: _num(json['balance_amount']),
        currency: (json['currency'] as String?) ?? 'AFN',
        dueDate: _toDate(json['due_date']),
        frequency: json['frequency'] as String?,
        status: (json['status'] as String?) ?? 'pending',
        paidAmount: _num(json['paid_amount']),
        lateFeeApplied: _num(json['late_fee_applied']),
        discountAmount: _num(json['discount_amount']),
        discountReason: json['discount_reason'] as String?,
        notes: json['notes'] as String?,
        assignedAt: _toDate(json['assigned_at']),
      );
}

class FeeInstallment {
  final String id;
  final String? studentId;
  final String? feeAssignmentId;
  final int installmentNumber;
  final int totalInstallments;
  final double amount;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final double paidAmount;
  final String status;
  final double lateFee;

  const FeeInstallment({
    required this.id,
    this.studentId,
    this.feeAssignmentId,
    required this.installmentNumber,
    required this.totalInstallments,
    required this.amount,
    this.dueDate,
    this.paidDate,
    this.paidAmount = 0,
    this.status = 'pending',
    this.lateFee = 0,
  });

  double get outstandingAmount => (amount - paidAmount).clamp(0, double.infinity).toDouble();

  factory FeeInstallment.fromJson(Map<String, dynamic> json) =>
      FeeInstallment(
        id: json['id'] as String,
        studentId: json['student_id'] as String?,
        feeAssignmentId: json['fee_assignment_id'] as String?,
        installmentNumber: (json['installment_number'] as num?)?.toInt() ?? 1,
        totalInstallments: (json['total_installments'] as num?)?.toInt() ?? 1,
        amount: _num(json['amount']),
        dueDate: _toDate(json['due_date']),
        paidDate: _toDate(json['paid_date']),
        paidAmount: _num(json['paid_amount']),
        status: (json['status'] as String?) ?? 'pending',
        lateFee: _num(json['late_fee']),
      );
}

/// Read-only payment row (with optional joined receipt number).
class FeePayment {
  final String id;
  final String? studentId;
  final String paymentNumber;
  final double amount;
  final double discountAmount;
  final double refundAmount;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? paymentType;
  final String status;
  final String? notes;
  final String? receiptNo;

  const FeePayment({
    required this.id,
    this.studentId,
    required this.paymentNumber,
    required this.amount,
    this.discountAmount = 0,
    this.refundAmount = 0,
    this.paymentMethod,
    this.paymentDate,
    this.paymentType,
    this.status = 'completed',
    this.notes,
    this.receiptNo,
  });

  factory FeePayment.fromJson(Map<String, dynamic> json) => FeePayment(
        id: json['id'] as String,
        studentId: json['student_id'] as String?,
        paymentNumber: (json['payment_number'] as String?) ?? json['id'] as String,
        amount: _num(json['amount']),
        discountAmount: _num(json['discount_amount']),
        refundAmount: _num(json['refund_amount']),
        paymentMethod: json['payment_method'] as String?,
        paymentDate: _toDate(json['payment_date']),
        paymentType: json['payment_type'] as String?,
        status: (json['status'] as String?) ?? 'completed',
        notes: json['notes'] as String?,
        receiptNo: json['receipt_no'] as String?,
      );
}

class FeeInvoice {
  final String id;
  final String invoiceNumber;
  final String? studentId;
  final String? description;
  final double amount;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final double outstandingAmount;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String status;
  final dynamic items;

  const FeeInvoice({
    required this.id,
    required this.invoiceNumber,
    this.studentId,
    this.description,
    required this.amount,
    this.discountAmount = 0,
    this.taxAmount = 0,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.outstandingAmount,
    this.issueDate,
    this.dueDate,
    this.paidDate,
    this.status = 'pending',
    this.items,
  });

  factory FeeInvoice.fromJson(Map<String, dynamic> json) => FeeInvoice(
        id: json['id'] as String,
        invoiceNumber: (json['invoice_number'] as String?) ?? json['id'] as String,
        studentId: json['student_id'] as String?,
        description: json['description'] as String?,
        amount: _num(json['amount']),
        discountAmount: _num(json['discount_amount']),
        taxAmount: _num(json['tax_amount']),
        totalAmount: _num(json['total_amount']),
        paidAmount: _num(json['paid_amount']),
        outstandingAmount: _num(json['outstanding_amount']),
        issueDate: _toDate(json['issue_date']),
        dueDate: _toDate(json['due_date']),
        paidDate: _toDate(json['paid_date']),
        status: (json['status'] as String?) ?? 'pending',
        items: json['items'],
      );
}

/// A lightweight identity for the current user's student records.
class StudentIdentity {
  final String id;
  final String fullName;
  final String? studentCode;
  final String? className;

  const StudentIdentity({
    required this.id,
    required this.fullName,
    this.studentCode,
    this.className,
  });

  factory StudentIdentity.fromJson(Map<String, dynamic> json) =>
      StudentIdentity(
        id: json['id'] as String,
        fullName: (json['full_name'] as String?) ?? 'Student',
        studentCode: json['student_code'] as String?,
        className: json['class_name'] as String?,
      );
}

double _num(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}
