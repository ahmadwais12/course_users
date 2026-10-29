import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../deep_link_service.dart';

/// Widget that handles pending deep links once the router is mounted.
class DeepLinkHandler extends ConsumerStatefulWidget {
  final Widget child;

  const DeepLinkHandler({required this.child, super.key});

  @override
  ConsumerState<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends ConsumerState<DeepLinkHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deepLinkServiceProvider).processPendingLink();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
