import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../nav.dart';
import 'models/deep_link_data.dart';

/// Handles navigation based on deep link data.
class DeepLinkRoutes {
  static void navigateWithContext(BuildContext context, DeepLinkData data) {
    switch (data.type) {
      case DeepLinkType.student:
        _goTo(context, AppRoutes.studentPanel, {'studentId': data.id});
        break;
      case DeepLinkType.teacher:
      case DeepLinkType.staff:
        context.go(AppRoutes.home);
        break;
      case DeepLinkType.payment:
      case DeepLinkType.invoice:
      case DeepLinkType.receipt:
        _navigateToPayment(context, data);
        break;
      case DeepLinkType.announcement:
      case DeepLinkType.event:
      case DeepLinkType.notification:
        context.go(AppRoutes.home);
        break;
      case DeepLinkType.attendance:
        _goTo(
          context,
          AppRoutes.attendance,
          {'classId': data.queryParams['classId'] ?? data.id, 'date': data.queryParams['date']},
        );
        break;
      case DeepLinkType.grade:
        _goTo(
          context,
          AppRoutes.grades,
          {
            'studentId': data.id,
            'examId': data.queryParams['examId'],
            'classId': data.queryParams['classId'],
          },
        );
        break;
      case DeepLinkType.course:
        _goTo(context, AppRoutes.courses, {'courseId': data.id});
        break;
      case DeepLinkType.classInfo:
        _goTo(context, AppRoutes.studentPanel, {'classId': data.id});
        break;
      case DeepLinkType.profile:
      case DeepLinkType.settings:
        _goTo(context, AppRoutes.settings, {'section': data.queryParams['section']});
        break;
      case DeepLinkType.unknown:
        context.go(AppRoutes.home);
        break;
    }
  }

  static void _navigateToPayment(BuildContext context, DeepLinkData data) {
    if (!data.hasValidId) {
      context.go(AppRoutes.payments);
      return;
    }

    final isInvoice =
        data.type == DeepLinkType.invoice || data.id!.toUpperCase().startsWith('INV-');
    final isReceipt =
        data.type == DeepLinkType.receipt || data.id!.toUpperCase().startsWith('REC-');

    _goTo(
      context,
      AppRoutes.payments,
      {
        if (isInvoice) 'invoiceId': data.id,
        if (isReceipt) 'receiptId': data.id,
        if (!isInvoice && !isReceipt) 'paymentId': data.id,
      },
    );
  }

  static void _goTo(
    BuildContext context,
    String path,
    Map<String, String?> queryParameters,
  ) {
    final sanitized = <String, String>{};
    for (final entry in queryParameters.entries) {
      final value = entry.value;
      if (value != null && value.isNotEmpty) {
        sanitized[entry.key] = value;
      }
    }

    final location = sanitized.isEmpty
        ? path
        : Uri(path: path, queryParameters: sanitized).toString();
    context.go(location);
  }
}
