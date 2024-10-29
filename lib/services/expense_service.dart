import 'package:fixio/model/expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExpenseService {
  static const String _key = 'expense';

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

  Future<void> addExpense(ExpenseModel expense) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ExpenseModel> currentInventory = await getExpense();
    currentInventory.add(expense);
    final String encodedInventory =
        json.encode(currentInventory.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encodedInventory);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ExpenseModel> currentInventory = await getExpense();
    final int index = currentInventory.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      currentInventory[index] = expense;
      final String encodedInventory =
          json.encode(currentInventory.map((e) => e.toJson()).toList());
      await prefs.setString(_key, encodedInventory);
    }
  }

  Future<void> deleteExpense(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ExpenseModel> currentInventory = await getExpense();
    currentInventory.removeWhere((e) => e.id == id);
    final String encodedInventory =
        json.encode(currentInventory.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encodedInventory);
  }
}
