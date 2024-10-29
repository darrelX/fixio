import 'package:uuid/uuid.dart';

class ExpenseModel {
  final double? expense;
  final String? id;
  final DateTime? dateTime;
  final String? title;

  ExpenseModel(
      {required this.expense,
      required String? id,
      required this.dateTime,
      required this.title})
      : this.id = id ?? Uuid().v4();

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
        id: json['id'],
        expense: json['expense'],
        dateTime: DateTime.parse(json['dateTime']),
        title: json['title']);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "expense": this.expense,
      "dateTime": this.dateTime!.toIso8601String(),
      "title": this.title
    };
  }
}
