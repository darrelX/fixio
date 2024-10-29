import 'dart:convert';

import 'package:fixio/model/account_model.dart';
import 'package:fixio/model/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FixioRepository {
  static const String _key = 'expense';
  static const String _key2 = 'budget';

  Future<List<ExpenseModel>> getExpense() async {
    final prefs = await SharedPreferences.getInstance();
    final String? inventoryJson = prefs.getString(_key);
    if (inventoryJson == null) {
      return [];
    }
    final List<dynamic> decodedJson = json.decode(inventoryJson);
    print(decodedJson);
    return decodedJson.map((item) => ExpenseModel.fromJson(item)).toList();
  }

  Future<List<double>> expenses() async {
    final expense = await getExpense();
    List<double> list = [];
    for (var elt in expense) {
      list.add(elt.expense!);
    }
    return list;
  }

  Future<double?> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final double? budget = prefs.getDouble('budget');
    if (budget == null) {
      return 0;
    } else {
      return budget;
    }
  }

  Future<void> setBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('budget', budget);
    print(prefs.getInt('budget'));
  }

  Map<int, double> classifyExpensesByDayOfWeek(List<ExpenseModel> expenses) {
    // Créer une map pour stocker la somme des dépenses pour chaque jour de la semaine
    Map<int, double> expensesByDay = {};
    int day = 0;

    // Boucle sur chaque élément de la liste
    for (var item in expenses) {
      // Extraire le jour de la semaine
      String dayOfWeek = DateFormat('EEEE')
          .format(item.dateTime!); // Exemple : "Monday", "Tuesday", etc.

      switch (dayOfWeek) {
        case "Monday":
          day = 0;
          break;
        case "Tuesday":
          day = 1;
          break;
        case "Wednesday":
          day = 2;
          break;
        case "Thursday":
          day = 3;
          break;
        case "Friday":
          day = 4;
          break;
        case "Satuday":
          day = 5;
          break;
        case "Sunday":
          day = 6;
          break;
        default:
          day = 0;
      }

      // Ajouter la dépense à la somme existante pour ce jour
      if (expensesByDay.containsKey(day)) {
        expensesByDay[day] = expensesByDay[day]! + item.expense!;
      } else {
        expensesByDay[day] = item.expense!;
      }
    }

    return expensesByDay;
  }

  saveBudget() {}
}
