import '../models/overdue_payment.dart';

abstract class PaymentRepository {
  Future<List<OverduePayment>> fetchOverdue();
}

class MockPaymentRepository implements PaymentRepository {
  MockPaymentRepository({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;

  @override
  Future<List<OverduePayment>> fetchOverdue() async {
    await Future<void>.delayed(delay);
    return const [
      OverduePayment(studentId: 's1', studentName: 'Daniel Lim', amount: 240),
      OverduePayment(studentId: 's2', studentName: 'Kevin Wong', amount: 180),
    ];
  }
}
