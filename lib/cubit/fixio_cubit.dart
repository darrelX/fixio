import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:fixio/repositories/fixio_repository.dart';

// part 'fixio_state.dart';
// enum status

class FixioCubit extends Cubit<double> {
  final FixioRepository fixioRepository = FixioRepository();
  FixioCubit() : super(0) {
    _initialize();
  }

  Future<void> _initialize() async {
    double a = (await fixioRepository.getBudget())!;
    emit(a);
  }

  Future<void> saveBudget(double budget) async {
    fixioRepository.setBudget(budget);
    emit(budget);
  }

  Future<List<double>> expense() async {
    return await fixioRepository.expenses();
  }

  Future<Map<int, double>> report() async {
    return await fixioRepository
        .classifyExpensesByDayOfWeek(await fixioRepository.getExpense());
  }
}
