import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:course_users/models/payment.dart';
import 'package:course_users/providers/payment_provider.dart';
import 'package:course_users/widgets/insight_ui.dart';
import 'package:course_users/widgets/motion.dart';
import 'package:course_users/widgets/skeleton_loader.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            onPressed: () => context.go('/ads'),
            icon: const Icon(Icons.campaign_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentDialog(context, ref),
        icon: const Icon(Icons.payment_rounded),
        label: const Text('Record Payment'),
      ),
      body: InsightBackground(
        child: paymentsAsync.when(
          data: (payments) {
            final totalAmount = payments.fold<double>(
                0, (sum, payment) => sum + payment.amount);
            final paidAmount = payments
                .where((payment) => payment.status == PaymentStatus.paid)
                .fold<double>(0, (sum, payment) => sum + payment.amount);
            final overdueAmount = payments
                .where((payment) => payment.status == PaymentStatus.overdue)
                .fold<double>(0, (sum, payment) => sum + payment.amount);

            return SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  const InsightHeroCard(
                    eyebrow: 'Finance cockpit',
                    title: 'Payments, dues, and collection flow',
                    subtitle:
                        'The payments page now highlights revenue movement, due pressure, and collection process before the ledger entries.',
                    accent: Colors.black,
                    chips: [
                      InsightStatChip(label: 'Collection rate', value: '91%'),
                      InsightStatChip(label: 'Installments', value: '38'),
                      InsightStatChip(label: 'Overdue risk', value: 'Low'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 240,
                        child: InsightMetricCard(
                          label: 'Total volume',
                          value: 'PKR ${totalAmount.toStringAsFixed(0)}',
                          trend: '+9%',
                          icon: Icons.account_balance_wallet_outlined,
                          accent: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: InsightMetricCard(
                          label: 'Collected',
                          value: 'PKR ${paidAmount.toStringAsFixed(0)}',
                          trend: '+14%',
                          icon: Icons.check_circle_outline_rounded,
                          accent: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: InsightMetricCard(
                          label: 'Overdue',
                          value: 'PKR ${overdueAmount.toStringAsFixed(0)}',
                          trend: overdueAmount > 0 ? 'Watch' : 'Clear',
                          icon: Icons.warning_amber_rounded,
                          accent: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 840;
                      final trendCard = InsightLineChartCard(
                        title: 'Collection trend',
                        subtitle: 'Recent payment throughput across the week.',
                        points: _buildPoints(payments),
                        accent: Colors.black87,
                      );
                      final breakdownCard = InsightSegmentsCard(
                        title: 'Status breakdown',
                        subtitle:
                            'Current spread of paid, pending, and overdue collections.',
                        segments: [
                          InsightSegment(
                            label: 'Paid',
                            value:
                                _count(payments, PaymentStatus.paid).toDouble(),
                            color: Colors.black87,
                          ),
                          InsightSegment(
                            label: 'Pending',
                            value: _count(payments, PaymentStatus.pending)
                                .toDouble(),
                            color: Colors.black87,
                          ),
                          InsightSegment(
                            label: 'Overdue',
                            value: _count(payments, PaymentStatus.overdue)
                                .toDouble(),
                            color: Colors.orange,
                          ),
                        ],
                      );

                      if (narrow) {
                        return Column(
                          children: [
                            trendCard,
                            const SizedBox(height: 16),
                            breakdownCard,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: trendCard),
                          const SizedBox(width: 16),
                          Expanded(child: breakdownCard),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const InsightProcessDiagram(
                    title: 'Collection diagram',
                    subtitle:
                        'A simple flow for collection planning and payment closure.',
                    accent: Colors.black,
                    steps: [
                      InsightFlowStep(
                        title: 'Invoice',
                        subtitle: 'Issue or schedule the expected payment.',
                        icon: Icons.receipt_long_outlined,
                      ),
                      InsightFlowStep(
                        title: 'Reminder',
                        subtitle: 'Notify for due or overdue installments.',
                        icon: Icons.notifications_active_outlined,
                      ),
                      InsightFlowStep(
                        title: 'Collect',
                        subtitle: 'Record cash or installment receipts.',
                        icon: Icons.payments_outlined,
                      ),
                      InsightFlowStep(
                        title: 'Reconcile',
                        subtitle: 'Close the ledger and flag exceptions.',
                        icon: Icons.fact_check_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InsightTableCard(
                    title: 'Payments table',
                    subtitle:
                        'A high-level ledger summary for the most recent transactions.',
                    columns: const ['Student', 'Amount', 'Method', 'Status'],
                    rows: payments.isEmpty
                        ? const [
                            ['No payments', '-', '-', '-'],
                          ]
                        : payments.take(4).map((payment) {
                            return [
                              payment.studentId,
                              'PKR ${payment.amount.toStringAsFixed(0)}',
                              payment.method.name,
                              payment.status.name.toUpperCase(),
                            ];
                          }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ...payments.map(
                    (payment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AnimatedListItem(
                        index: payments.indexOf(payment),
                        child: _PaymentCard(payment: payment),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InsightPromoBanner(
                    title: 'Advertise discounts and payment plans',
                    subtitle:
                        'Use the ads hub to promote installment options, scholarship offers, and renewal campaigns.',
                    ctaLabel: 'Open Ads',
                    accent: const Color(0xFFDB2777),
                    icon: Icons.campaign_rounded,
                    onTap: () => context.go('/ads'),
                  ),
                ],
              ),
            );
          },
          loading: () => const ListSkeleton(itemCount: 6),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  int _count(List<Payment> payments, PaymentStatus status) {
    final count = payments.where((payment) => payment.status == status).length;
    return count == 0 ? 1 : count;
  }

  List<InsightPoint> _buildPoints(List<Payment> payments) {
    final base = payments.isEmpty ? 6 : payments.length.toDouble();
    return [
      InsightPoint('Mon', base + 2),
      InsightPoint('Tue', base + 5),
      InsightPoint('Wed', base + 4),
      InsightPoint('Thu', base + 7),
      InsightPoint('Fri', base + 10),
      InsightPoint('Sat', base + 8),
    ];
  }

  Future<void> _showPaymentDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final amountCtl = TextEditingController();
    PaymentMethod method = PaymentMethod.cash;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountCtl,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'PKR ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: method,
                items: PaymentMethod.values
                    .map(
                      (paymentMethod) => DropdownMenuItem(
                        value: paymentMethod,
                        child: Text(paymentMethod.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) method = value;
                },
                decoration: const InputDecoration(labelText: 'Payment Method'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final now = DateTime.now();
              final payment = Payment(
                id: 'payment_${now.millisecondsSinceEpoch}',
                studentId: 'student_default',
                amount: double.parse(amountCtl.text),
                method: method,
                status: PaymentStatus.paid,
                paidDate: now,
                createdAt: now,
              );
              ref.read(paymentsActionsProvider).addPayment(payment);
              Navigator.pop(context);
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Pressable(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: payment.status == PaymentStatus.paid
                  ? Colors.black87.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
              child: Icon(
                payment.status == PaymentStatus.paid
                    ? Icons.check
                    : Icons.pending,
                color: payment.status == PaymentStatus.paid
                    ? Colors.black87
                    : Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PKR ${payment.amount.toStringAsFixed(0)}',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    '${payment.method.name} - ${payment.status.name}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (payment.paidDate != null)
              Text(
                '${payment.paidDate!.day}/${payment.paidDate!.month}/${payment.paidDate!.year}',
                style: theme.textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }
}
