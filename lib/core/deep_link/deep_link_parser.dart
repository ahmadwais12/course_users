import 'models/deep_link_data.dart';

/// Parses deep link URLs into structured data.
class DeepLinkParser {
  static DeepLinkData parse(String url, DeepLinkSource source) {
    try {
      if (url.startsWith('emis://')) {
        url = url.replaceFirst('emis://', 'https://emis.example.com/');
      }

      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.isEmpty) {
        return _createUnknown(url, source);
      }

      final type = _parseType(pathSegments);
      final id = _extractId(pathSegments);

      return DeepLinkData(
        type: type,
        id: id,
        queryParams: Map<String, String>.from(uri.queryParameters),
        rawUrl: url,
        source: source,
      );
    } catch (_) {
      return _createUnknown(url, source);
    }
  }

  static DeepLinkType _parseType(List<String> segments) {
    if (segments.isEmpty) return DeepLinkType.unknown;

    switch (segments.first.toLowerCase()) {
      case 'student':
        return DeepLinkType.student;
      case 'teacher':
        return DeepLinkType.teacher;
      case 'staff':
        return DeepLinkType.staff;
      case 'payment':
        return DeepLinkType.payment;
      case 'invoice':
        return DeepLinkType.invoice;
      case 'receipt':
        return DeepLinkType.receipt;
      case 'announcement':
      case 'notice':
        return DeepLinkType.announcement;
      case 'event':
        return DeepLinkType.event;
      case 'attendance':
        return DeepLinkType.attendance;
      case 'grade':
      case 'grades':
        return DeepLinkType.grade;
      case 'course':
      case 'program':
        return DeepLinkType.course;
      case 'class':
        return DeepLinkType.classInfo;
      case 'notification':
        return DeepLinkType.notification;
      case 'profile':
        return DeepLinkType.profile;
      case 'settings':
        return DeepLinkType.settings;
      default:
        return DeepLinkType.unknown;
    }
  }

  static String? _extractId(List<String> segments) {
    if (segments.length >= 2) {
      return segments[1];
    }
    return null;
  }

  static DeepLinkData _createUnknown(String url, DeepLinkSource source) {
    return DeepLinkData(
      type: DeepLinkType.unknown,
      rawUrl: url,
      source: source,
    );
  }
}
