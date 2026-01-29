

// import 'package:aishwarya_gold/data/models/payment_method_models.dart';
// import 'package:aishwarya_gold/data/repo/paymentrepo/payment_repos.dart';
// import 'package:flutter/foundation.dart';

// class PaymentProvider with ChangeNotifier {
//   final PaymentRepository _repository;

//   PaymentProvider(this._repository);

//   List<PaymentMethod> _paymentMethods = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//   bool _isAddingMethod = false;

//   // Getters
//   List<PaymentMethod> get paymentMethods => _paymentMethods;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get isAddingMethod => _isAddingMethod;

//   List<PaymentMethod> get upiMethods =>
//       _paymentMethods.where((method) => method.type == 'upi').toList();

//   List<PaymentMethod> get bankMethods =>
//       _paymentMethods.where((method) => method.type == 'bank').toList();

//   PaymentMethod? get primaryPaymentMethod =>
//       _paymentMethods.where((method) => method.isPrimary).isNotEmpty
//           ? _paymentMethods.firstWhere((method) => method.isPrimary)
//           : null;

//   // Clear error message
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }

//   // Fetch payment methods
//   Future<void> fetchPaymentMethods() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final response = await _repository.getPaymentMethods();

//       if (response.success) {
//         _paymentMethods = response.data ?? [];
//         _errorMessage = null;
//       } else {
//         _errorMessage = response.error;
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to fetch payment methods: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Add payment method
//   Future<bool> addPaymentMethod(AddPaymentMethodRequest request) async {
//     _isAddingMethod = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final response = await _repository.addPaymentMethod(request);

//       if (response.success && response.data != null) {
//         _paymentMethods.add(response.data!);
//         _errorMessage = null;
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = response.error;
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to add payment method: $e';
//       return false;
//     } finally {
//       _isAddingMethod = false;
//       notifyListeners();
//     }
//   }

//   // Update payment method
//   Future<bool> updatePaymentMethod(String id, AddPaymentMethodRequest request) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final response = await _repository.updatePaymentMethod(id, request);

//       if (response.success && response.data != null) {
//         final index = _paymentMethods.indexWhere((method) => method.id == id);
//         if (index != -1) {
//           _paymentMethods[index] = response.data!;
//         }
//         _errorMessage = null;
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = response.error;
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to update payment method: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Delete payment method
//   Future<bool> deletePaymentMethod(String id) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final response = await _repository.deletePaymentMethod(id);

//       if (response.success) {
//         _paymentMethods.removeWhere((method) => method.id == id);
//         _errorMessage = null;
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = response.error;
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to delete payment method: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Set primary payment method
//   Future<bool> setPrimaryPaymentMethod(String id) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final response = await _repository.setPrimaryPaymentMethod(id);

//       if (response.success) {
//         // Update local state
//         for (int i = 0; i < _paymentMethods.length; i++) {
//           _paymentMethods[i] = _paymentMethods[i].copyWith(
//             isPrimary: _paymentMethods[i].id == id,
//           );
//         }
//         _errorMessage = null;
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = response.error;
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to set primary payment method: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Refresh payment methods
//   Future<void> refresh() async {
//     await fetchPaymentMethods();
//   }
// }