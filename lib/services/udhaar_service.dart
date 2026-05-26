import '../models/udhaar_model.dart';
import 'database_service.dart';

class UdhaarService {
  // Get all udhaar entries
  Future<List<UdhaarModel>> getAllUdhaar() async {
    final udhaar = await DatabaseService.getAll(DatabaseService.keyUdhaar);
    final customers = await DatabaseService.getAll(
      DatabaseService.keyCustomers,
    );

    return udhaar.map((u) {
      final customer = customers.firstWhere(
        (c) => c['id'] == u['customer_id'],
        orElse: () => {},
      );
      return UdhaarModel.fromMap({
        ...u,
        'customer_name': customer['name'],
        'customer_phone': customer['phone'],
      });
    }).toList();
  }

  // Get udhaar by ID
  Future<UdhaarModel?> getUdhaarById(int id) async {
    final udhaar = await DatabaseService.getById(DatabaseService.keyUdhaar, id);
    if (udhaar == null) return null;

    final customers = await DatabaseService.getAll(
      DatabaseService.keyCustomers,
    );
    final customer = customers.firstWhere(
      (c) => c['id'] == udhaar['customer_id'],
      orElse: () => {},
    );

    return UdhaarModel.fromMap({
      ...udhaar,
      'customer_name': customer['name'],
      'customer_phone': customer['phone'],
    });
  }

  // Get udhaar payments
  Future<List<UdhaarPayment>> getUdhaarPayments(int udhaarId) async {
    final payments = await DatabaseService.getAll(
      DatabaseService.keyUdhaarPayments,
    );
    return payments
        .where((p) => p['udhaar_id'] == udhaarId)
        .map((p) => UdhaarPayment.fromMap(p))
        .toList();
  }

  // Add udhaar
  Future<int> addUdhaar(UdhaarModel udhaar) async {
    final now = DateTime.now().toIso8601String();
    final udhaarMap = {
      'customer_id': udhaar.customerId,
      'total_amount': udhaar.totalAmount,
      'paid_amount': udhaar.paidAmount,
      'due_date': udhaar.dueDate?.toIso8601String(),
      'status': udhaar.status,
      'notes': udhaar.notes,
      'created_at': now,
      'updated_at': now,
    };
    return await DatabaseService.insert(DatabaseService.keyUdhaar, udhaarMap);
  }

  // Update udhaar
  Future<bool> updateUdhaar(UdhaarModel udhaar) async {
    final updatedMap = {
      'customer_id': udhaar.customerId,
      'total_amount': udhaar.totalAmount,
      'paid_amount': udhaar.paidAmount,
      'due_date': udhaar.dueDate?.toIso8601String(),
      'status': udhaar.status,
      'notes': udhaar.notes,
      'updated_at': DateTime.now().toIso8601String(),
    };
    final result = await DatabaseService.update(
      DatabaseService.keyUdhaar,
      udhaar.id!,
      updatedMap,
    );
    return result > 0;
  }

  // Delete udhaar
  Future<bool> deleteUdhaar(int id) async {
    // Delete associated payments first
    final payments = await DatabaseService.getAll(
      DatabaseService.keyUdhaarPayments,
    );
    for (var payment in payments) {
      if (payment['udhaar_id'] == id) {
        await DatabaseService.delete(
          DatabaseService.keyUdhaarPayments,
          payment['id'],
        );
      }
    }
    final result = await DatabaseService.delete(DatabaseService.keyUdhaar, id);
    return result > 0;
  }

  // Add payment
  Future<int> addPayment(UdhaarPayment payment) async {
    final paymentMap = {
      'udhaar_id': payment.udhaarId,
      'amount': payment.amount,
      'payment_date': payment.paymentDate.toIso8601String(),
      'payment_method': payment.paymentMethod,
      'notes': payment.notes,
      'created_at': DateTime.now().toIso8601String(),
    };
    final paymentId = await DatabaseService.insert(
      DatabaseService.keyUdhaarPayments,
      paymentMap,
    );

    if (paymentId > 0) {
      // Update udhaar paid amount and status
      final udhaar = await getUdhaarById(payment.udhaarId);
      if (udhaar != null) {
        final newPaidAmount = udhaar.paidAmount + payment.amount;
        String newStatus = 'pending';
        if (newPaidAmount >= udhaar.totalAmount) {
          newStatus = 'paid';
        } else if (newPaidAmount > 0) {
          newStatus = 'partial';
        }
        await updateUdhaar(
          udhaar.copyWith(paidAmount: newPaidAmount, status: newStatus),
        );
      }
    }

    return paymentId;
  }

  // Delete payment
  Future<bool> deletePayment(int paymentId) async {
    final payments = await DatabaseService.getAll(
      DatabaseService.keyUdhaarPayments,
    );
    final payment = payments.firstWhere(
      (p) => p['id'] == paymentId,
      orElse: () => {},
    );
    if (payment.isEmpty) return false;

    final result = await DatabaseService.delete(
      DatabaseService.keyUdhaarPayments,
      paymentId,
    );

    if (result > 0) {
      // Update udhaar paid amount
      final udhaar = await getUdhaarById(payment['udhaar_id']);
      if (udhaar != null) {
        final newPaidAmount =
            udhaar.paidAmount - (payment['amount'] as num).toDouble();
        String newStatus = 'pending';
        if (newPaidAmount <= 0) {
          newStatus = 'pending';
        } else if (newPaidAmount >= udhaar.totalAmount) {
          newStatus = 'paid';
        } else {
          newStatus = 'partial';
        }
        await updateUdhaar(
          udhaar.copyWith(
            paidAmount: newPaidAmount > 0 ? newPaidAmount : 0,
            status: newStatus,
          ),
        );
      }
    }

    return result > 0;
  }

  // Get customer udhaar
  Future<List<UdhaarModel>> getCustomerUdhaar(int customerId) async {
    final udhaar = await getAllUdhaar();
    return udhaar.where((u) => u.customerId == customerId).toList();
  }

  // Get pending udhaar
  Future<List<UdhaarModel>> getPendingUdhaar() async {
    final udhaar = await getAllUdhaar();
    return udhaar.where((u) => u.status != 'paid').toList();
  }

  // Get overdue udhaar
  Future<List<UdhaarModel>> getOverdueUdhaar() async {
    final udhaar = await getAllUdhaar();
    final now = DateTime.now();
    return udhaar.where((u) {
      return u.status != 'paid' &&
          u.dueDate != null &&
          u.dueDate!.isBefore(now);
    }).toList();
  }

  // Get total pending amount - FIXED: replaced fold with for loop
  Future<double> getTotalPendingAmount() async {
    final udhaar = await getAllUdhaar();
    double total = 0.0;
    for (var u in udhaar) {
      total += u.remainingAmount;
    }
    return total;
  }
}
