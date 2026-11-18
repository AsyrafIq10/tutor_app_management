import 'package:flutter/foundation.dart';

import '../../../data/class_repository.dart';
import '../../../data/payment_repository.dart';
import '../../../models/class_session.dart';
import '../../../models/overdue_payment.dart';

/// Data for the Home tab: today's classes and overdue payments.
class TutorHomeProvider extends ChangeNotifier {
  TutorHomeProvider(this._classes, this._payments);

  final ClassRepository _classes;
  final PaymentRepository _payments;

  bool _loading = false;
  String? _error;
  List<ClassSession> _today = [];
  List<OverduePayment> _overdue = [];

  bool get loading => _loading;
  String? get error => _error;
  List<ClassSession> get todayClasses => _today;
  List<OverduePayment> get overdue => _overdue;
  double get overdueTotal => _overdue.fold(0, (sum, p) => sum + p.amount);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _classes.fetchForDay(DateTime.now()),
        _payments.fetchOverdue(),
      ]);
      _today = [...results[0] as List<ClassSession>]
        ..sort((a, b) => a.start.compareTo(b.start));
      _overdue = results[1] as List<OverduePayment>;
    } catch (_) {
      _error = 'Could not load today\'s overview. Pull down to try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
