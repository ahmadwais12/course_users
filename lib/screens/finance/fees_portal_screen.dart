import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:course_users/models/fee_models.dart';
import 'package:course_users/repositories/fee_repository.dart';
import 'package:course_users/utils/money_format.dart';

/// Fees portal used by both the student and parent panels.
///
/// The current user's own fee record (student role) or linked children
/// (parent role) are resolved automatically; a chip row appears when more
/// than one child is linked. The three tabs mirror the fee engine:
///  - Statement: fee assignments + installments + running balance
///  - Invoices: invoices with paid / outstanding amounts
///  - Payments: payment history with official receipt numbers
class FeesPortalScreen extends ConsumerStatefulWidget {
  final String title;
  final int initialTabIndex;

  const FeesPortalScreen({
    super.key,
    this.title = 'Fees & Payments',
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<FeesPortalScreen> createState() => _FeesPortalScreenState();
}

class _FeesPortalScreenState extends ConsumerState<FeesPortalScreen>
    with SingleTickerProviderStateMixin {
  final _repo = FeeRepository();
  late final TabController _tabController;

  List<StudentIdentity> _students = [];
  String? _studentId;
  StudentFeeStatement? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTabIndex;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initial < 0 ? 0 : (initial > 2 ? 2 : initial),
    );
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final students = await _repo.myStudents();
      if (!mounted) return;
      if (students.isEmpty) {
        setState(() {
          _students = const [];
          _loading = false;
        });
        return;
      }
      setState(() => _students = students);
      await _selectStudent(students.first.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _selectStudent(String id) async {
    setState(() {
      _studentId = id;
      _data = null;
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.loadStatement(id);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not load fees.', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 16),
              FilledButton(onPressed: _init, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_students.isEmpty) {
      return const Center(child: Text('No fee records are linked to your account yet.'));
    }
    final data = _data;
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currency = data.assignments.isNotEmpty
        ? (data.assignments.first.currency ?? 'AFN')
        : 'AFN';

    return Column(
      children: [
        // Child picker (only meaningful for parents with several children).
        if (_students.length > 1)
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final s in _students)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.fullName,
                          style: const TextStyle(fontSize: 13)),
                      selected: s.id == _studentId,
                      onSelected: (_) => _selectStudent(s.id),
                    ),
                  ),
              ],
            ),
          ),
        // Header summary
        _SummaryHeader(data: data, currency: currency),
        const Divider(height: 1),
        TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Statement'),
            Tab(text: 'Invoices'),
            Tab(text: 'Payments'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _StatementTab(data: data, currency: currency),
              _InvoicesTab(data: data, currency: currency),
              _PaymentsTab(data: data, currency: currency),
            ],
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  final StudentFeeStatement data;
  final String currency;
  const _SummaryHeader({required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  data.student.fullName.isEmpty
                      ? '?'
                      : data.student.fullName[0].toUpperCase(),
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.student.fullName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      [
                        if (data.student.studentCode != null)
                          'ID: ${data.student.studentCode}',
                        if (data.student.className != null)
                          data.student.className!,
                      ].join('  •  '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _sum(theme, 'Assigned', data.totalAssigned, currency,
                  Colors.blue),
              const SizedBox(width: 8),
              _sum(theme, 'Paid', data.totalPaid, currency, Colors.green),
              const SizedBox(width: 8),
              _sum(theme, 'Outstanding', data.totalOutstanding, currency,
                  Colors.red),
            ],
          ),
          if (data.assignments.isNotEmpty) ...[
            const SizedBox(height: 14),
            _ProgressBar(
              fraction: data.totalAssigned > 0
                  ? (data.totalPaid / data.totalAssigned).clamp(0.0, 1.0)
                  : 0,
            ),
          ],
        ],
      ),
    );
  }

  Widget _sum(ThemeData theme, String label, double value, String currency, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(fmtAmount(value),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double fraction;
  const _ProgressBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 8,
        backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.4),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Statement tab
// ────────────────────────────────────────────────────────────────────────────

class _StatementTab extends StatelessWidget {
  final StudentFeeStatement data;
  final String currency;
  const _StatementTab({required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.assignments.isEmpty) {
      return _Empty(
        icon: Icons.receipt_long_outlined,
        message: 'No fee assignments yet.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Fee Breakdown',
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (final a in data.assignments)
          _AssignmentCard(
            assignment: a,
            installments: data.installmentsByAssignment[a.id] ?? const [],
            currency: currency,
          ),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final StudentFeeAssignment assignment;
  final List<FeeInstallment> installments;
  final String currency;
  const _AssignmentCard({
    required this.assignment,
    required this.installments,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = assignment;
    final color = _statusColor(a.status);
    final title = a.structureName ?? a.feeTypeName ?? 'Fee';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.receipt_long_rounded, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${a.dueDate != null ? 'Due ${_date(a.dueDate!)}' : ''}'
                '${a.frequency != null ? '  •  ${_frequency(a.frequency)}' : ''}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                'Paid ${fmtMoney(a.paidAmount, currency: currency)} of '
                '${fmtMoney(a.amount, currency: currency)}',
                style: theme.textTheme.bodySmall,
              ),
              if (a.discountAmount > 0)
                Text('Discount applied: ${fmtAmount(a.discountAmount)}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.green.shade700)),
            ],
          ),
        ),
        trailing: Chip(
          label: Text(a.status.toUpperCase()),
          labelStyle: const TextStyle(fontSize: 10, color: Colors.white),
          backgroundColor: color,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Outstanding',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  fmtMoney(a.outstandingAmount, currency: currency),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: a.outstandingAmount > 0 ? Colors.red : Colors.green),
                ),
              ],
            ),
          ),
          if (installments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Installments',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  for (final inst in installments)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        inst.status == 'paid'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: inst.status == 'paid'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      title: Text('#${inst.installmentNumber}'
                          '  ${fmtMoney(inst.amount, currency: currency)}'),
                      subtitle: Text(inst.dueDate != null
                          ? 'Due ${_date(inst.dueDate!)}'
                          : ''),
                      trailing: Text(
                        inst.status.toUpperCase(),
                        style: TextStyle(
                            fontSize: 11,
                            color: inst.status == 'paid'
                                ? Colors.green
                                : Colors.orange),
                      ),
                    ),
                ],
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'waived':
        return Colors.grey;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Invoices tab
// ────────────────────────────────────────────────────────────────────────────

class _InvoicesTab extends StatelessWidget {
  final StudentFeeStatement data;
  final String currency;
  const _InvoicesTab({required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.invoices.isEmpty) {
      return const _Empty(
          icon: Icons.request_quote_outlined, message: 'No invoices yet.');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Invoices',
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
            'Total outstanding on invoices: ${fmtMoney(data.invoiceTotalOutstanding, currency: currency)}',
            style: theme.textTheme.bodySmall),
        const SizedBox(height: 10),
        for (final inv in data.invoices)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt,
                          color: _statusColor(inv.status), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(inv.invoiceNumber,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Chip(
                        label: Text(inv.status.toUpperCase()),
                        labelStyle:
                            const TextStyle(fontSize: 10, color: Colors.white),
                        backgroundColor: _statusColor(inv.status),
                      ),
                    ],
                  ),
                  if (inv.description != null &&
                      (inv.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(inv.description!, maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _kv('Issued', inv.issueDate != null ? _date(inv.issueDate!) : '—'),
                      const SizedBox(width: 20),
                      _kv('Due', inv.dueDate != null ? _date(inv.dueDate!) : '—'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _moneyCol('Total', inv.totalAmount, currency,
                          Theme.of(context).colorScheme.onSurface),
                      _moneyCol('Paid', inv.paidAmount, currency,
                          Colors.green),
                      _moneyCol('Outstanding', inv.outstandingAmount, currency,
                          inv.outstandingAmount > 0 ? Colors.red : Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Widget _kv(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      );

  Widget _moneyCol(
          String label, double value, String currency, Color color) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(fmtAmount(value),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      );
}

// ────────────────────────────────────────────────────────────────────────────
// Payments tab
// ────────────────────────────────────────────────────────────────────────────

class _PaymentsTab extends StatelessWidget {
  final StudentFeeStatement data;
  final String currency;
  const _PaymentsTab({required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.payments.isEmpty) {
      return const _Empty(
          icon: Icons.payments_outlined, message: 'No payments recorded yet.');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Payment History',
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (final p in data.payments)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _methodColor(p.paymentMethod),
                child: Icon(_methodIcon(p.paymentMethod),
                    color: Colors.white, size: 20),
              ),
              title: Text(p.paymentNumber,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.paymentDate != null ? _dateTime(p.paymentDate!) : ''}'
                    '${p.paymentType != null ? '  •  ${_typeLabel(p.paymentType)}' : ''}',
                  ),
                  if (p.receiptNo != null && p.receiptNo!.isNotEmpty)
                    Text('Receipt: ${p.receiptNo}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.blue.shade700)),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmtMoney(p.amount, currency: currency),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    p.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _statusColor(p.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'refunded':
        return Colors.grey;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'voided':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _methodColor(String? method) {
    switch ((method ?? '').toLowerCase()) {
      case 'cash':
        return Colors.teal;
      case 'card':
        return Colors.indigo;
      case 'bank_transfer':
        return Colors.deepPurple;
      case 'online':
        return Colors.blue;
      case 'mobile_payment':
        return Colors.cyan;
      case 'check':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _methodIcon(String? method) {
    switch ((method ?? '').toLowerCase()) {
      case 'cash':
        return Icons.payments_outlined;
      case 'card':
        return Icons.credit_card;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'online':
        return Icons.language;
      case 'mobile_payment':
        return Icons.phone_android;
      case 'check':
        return Icons.check_circle_outline;
      default:
        return Icons.payment;
    }
  }

  String _typeLabel(String? type) {
    switch (type) {
      case 'fee':
        return 'Fee payment';
      case 'installment':
        return 'Installment';
      case 'late_fee':
        return 'Late fee';
      case 'refund':
        return 'Refund';
      case 'advance':
        return 'Advance';
      default:
        return type ?? 'Payment';
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _Empty extends StatelessWidget {
  final IconData icon;
  final String message;
  const _Empty({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

String _date(DateTime d) => DateFormat('MMM d, yyyy').format(d);
String _dateTime(DateTime d) => DateFormat('MMM d, yyyy • h:mm a').format(d);

String _frequency(String? f) {
  switch (f) {
    case 'monthly':
      return 'Monthly';
    case 'quarterly':
      return 'Quarterly';
    case 'yearly':
      return 'Yearly';
    default:
      return 'One Time';
  }
}
