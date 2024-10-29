import 'dart:developer';

import 'package:fixio/model/expense_model.dart';

class AccountModel {
  final int budget;
  final List<ExpenseModel> expenses;
  const AccountModel({this.budget = 0, required this.expenses});

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return AccountModel(
        budget: json["budget"],
        expenses: List<ExpenseModel>.from(
            ExpenseModel.fromJson(json) as List<ExpenseModel>));
  }

  toJson() {
    return {"budget": this.budget, "expenses": this.expenses};
  }
}
