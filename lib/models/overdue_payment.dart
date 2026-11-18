class OverduePayment {
  const OverduePayment({
    required this.studentId,
    required this.studentName,
    required this.amount,
  });

  final String studentId;
  final String studentName;

  /// Amount owed in RM.
  final double amount;
}
