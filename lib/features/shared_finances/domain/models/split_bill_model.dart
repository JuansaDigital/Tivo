class SplitParticipant {
  final String name;
  final double amountOwed;
  final bool hasPaid;

  const SplitParticipant({
    required this.name,
    required this.amountOwed,
    this.hasPaid = false,
  });

  SplitParticipant copyWith({
    String? name,
    double? amountOwed,
    bool? hasPaid,
  }) {
    return SplitParticipant(
      name: name ?? this.name,
      amountOwed: amountOwed ?? this.amountOwed,
      hasPaid: hasPaid ?? this.hasPaid,
    );
  }
}

class SplitBillModel {
  final String id;
  final String title;
  final double totalAmount;
  final DateTime date;
  final List<SplitParticipant> participants;
  final String tag;

  const SplitBillModel({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.date,
    required this.participants,
    this.tag = '#GastosCompartidos',
  });

  double get totalOwedToUser {
    return participants
        .where((p) => !p.hasPaid)
        .fold(0.0, (acc, p) => acc + p.amountOwed);
  }
}
