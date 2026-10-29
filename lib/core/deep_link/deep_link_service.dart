import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../nav.dart';
import 'deep_link_parser.dart';
import 'deep_link_routes.dart';
import 'models/deep_link_data.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService();
});

/// Service responsible for handling all deep links.
class DeepLinkService {
  DeepLinkService({GlobalKey<NavigatorState>? navigatorKey})
      : _navigatorKey = navigatorKey ?? rootNavigatorKey;

  final GlobalKey<NavigatorState> _navigatorKey;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  DeepLinkData? _pendingDeepLink;
  bool _isPendingNavigationScheduled = false;

  DeepLinkData? get pendingDeepLink => _pendingDeepLink;

  Future<void> init() async {
    _appLinks = AppLinks();
    _listenToAuthChanges();
    await _handleColdStart();
    _listenToDeepLinks();
  }

  Future<void> _handleColdStart() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri == null) {
        return;
      }

      final data = DeepLinkParser.parse(
        initialUri.toString(),
        DeepLinkSource.coldStart,
      );
      _processDeepLink(data);
    } catch (error) {
      debugPrint('Error handling cold start deep link: $error');
    }
  }

  void _listenToDeepLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        final data = DeepLinkParser.parse(
          uri.toString(),
          DeepLinkSource.foreground,
        );
        _processDeepLink(data);
      },
      onError: (error) {
        debugPrint('Deep link error: $error');
      },
    );
  }

  void _listenToAuthChanges() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((authState) {
      if (authState.session == null) {
        return;
      }

      _schedulePendingNavigation();
    });
  }

  void _processDeepLink(DeepLinkData data) {
    if (data.type == DeepLinkType.unknown) {
      debugPrint('Invalid deep link: ${data.rawUrl}');
      return;
    }

    if (!_isTrustedDomain(data.rawUrl)) {
      debugPrint('Untrusted domain: ${data.rawUrl}');
      return;
    }

    final isAuthenticated = Supabase.instance.client.auth.currentSession != null;
    _pendingDeepLink = data;

    if (!isAuthenticated) {
      return;
    }

    _schedulePendingNavigation();
  }

  bool _isTrustedDomain(String url) {
    const trustedDomains = [
      'emis.example.com',
      'emis-staging.example.com',
      'emis.app',
    ];

    try {
      final uri = Uri.parse(url);
      return trustedDomains
          .any((domain) => uri.host == domain || uri.host.endsWith('.$domain'));
    } catch (_) {
      return false;
    }
  }

  void _schedulePendingNavigation() {
    if (_pendingDeepLink == null || _isPendingNavigationScheduled) {
      return;
    }

    _isPendingNavigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPendingNavigationScheduled = false;
      processPendingLink();
    });
  }

  void processPendingLink() {
    final pendingDeepLink = _pendingDeepLink;
    final context = _navigatorKey.currentContext;

    if (pendingDeepLink == null) {
      return;
    }

    if (context == null) {
      _schedulePendingNavigation();
      return;
    }

    _pendingDeepLink = null;
    DeepLinkRoutes.navigateWithContext(context, pendingDeepLink);
  }

  void clearPendingLink() {
    _pendingDeepLink = null;
  }

  void dispose() {
    _linkSubscription?.cancel();
    _authSubscription?.cancel();
  }
}
