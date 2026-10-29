import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 2);

final drawerExpandedProvider = StateProvider<bool>((ref) => true);
