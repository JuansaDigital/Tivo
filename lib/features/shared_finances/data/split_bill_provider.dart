import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/split_bill_model.dart';

final splitBillListProvider =
    StateNotifierProvider<SplitBillNotifier, List<SplitBillModel>>((ref) {
  return SplitBillNotifier();
});

class SplitBillNotifier extends StateNotifier<List<SplitBillModel>> {
  SplitBillNotifier() : super(_initialSplitBills);

  static final List<SplitBillModel> _initialSplitBills = [
    SplitBillModel(
      id: const Uuid().v4(),
      title: 'Cena & Cócteles Cumpleaños',
      totalAmount: 380000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      tag: '#CenaAmigos',
      participants: const [
        SplitParticipant(name: 'Andrés Morales', amountOwed: 95000, hasPaid: false),
        SplitParticipant(name: 'Sofía Castro', amountOwed: 95000, hasPaid: true),
        SplitParticipant(name: 'Camila Ríos', amountOwed: 95000, hasPaid: false),
      ],
    ),
    SplitBillModel(
      id: const Uuid().v4(),
      title: 'Airbnb Fin de Semana Villa de Leyva',
      totalAmount: 1200000,
      date: DateTime.now().subtract(const Duration(days: 7)),
      tag: '#ViajeVillaDeLeyva',
      participants: const [
        SplitParticipant(name: 'Mateo Gómez', amountOwed: 300000, hasPaid: false),
        SplitParticipant(name: 'Valentina López', amountOwed: 300000, hasPaid: true),
      ],
    ),
  ];

  void toggleParticipantPaid(String billId, String participantName) {
    state = state.map((bill) {
      if (bill.id == billId) {
        final updatedParticipants = bill.participants.map((p) {
          if (p.name == participantName) {
            return p.copyWith(hasPaid: !p.hasPaid);
          }
          return p;
        }).toList();
        return SplitBillModel(
          id: bill.id,
          title: bill.title,
          totalAmount: bill.totalAmount,
          date: bill.date,
          participants: updatedParticipants,
          tag: bill.tag,
        );
      }
      return bill;
    }).toList();
  }

  void addSplitBill(SplitBillModel bill) {
    state = [bill, ...state];
  }
}
