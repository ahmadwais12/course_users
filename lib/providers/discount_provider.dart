import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_users/models/discount.dart';
import 'package:course_users/repositories/discount_repository.dart';

final discountRepositoryProvider = Provider((ref) => DiscountRepository());

final discountsNotifierProvider = StateNotifierProvider<DiscountsNotifier, AsyncValue<List<Discount>>>((ref) {
  return DiscountsNotifier(ref.watch(discountRepositoryProvider));
});

class DiscountsNotifier extends StateNotifier<AsyncValue<List<Discount>>> {
  final DiscountRepository _repository;
  
  DiscountsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDiscounts();
  }
  
  Future<void> loadDiscounts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAll());
  }
  
  Future<void> addDiscount(Discount discount) async {
    await _repository.create(discount);
    await loadDiscounts();
  }
}
