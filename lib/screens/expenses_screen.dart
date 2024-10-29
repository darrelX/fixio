import 'package:fixio/model/expense_model.dart';
import 'package:fixio/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ExpenseService _expenseService = ExpenseService();
  late Future<List<ExpenseModel>> _expenseFuture;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _expenseFuture = _expenseService.getExpense();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshInventory() {
    setState(() {
      _expenseFuture = _expenseService.getExpense();
    });
  }

  void _showAddExpenseDialog(BuildContext context) {
    _showexpenseDialog(context, null);
  }

  void _showEditExpenseDialog(BuildContext context, ExpenseModel expense) {
    _showexpenseDialog(context, expense);
  }

  void _showexpenseDialog(BuildContext context, ExpenseModel? expense) {
    final titleController = TextEditingController(text: expense?.title ?? '');
    final expenseController =
        TextEditingController(text: expense?.expense.toString() ?? '');
    DateTime _selectedDate = expense?.dateTime ?? DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return Form(
            key: _formkey,
            child: Center(
              child: AlertDialog(
                title: Text(expense == null
                    ? 'Ajouter un équipement'
                    : 'Modifier l\'équipement'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Nom de l'équipement",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Gap(20.h),
                      TextField(
                        controller: expenseController,
                        decoration: InputDecoration(
                            hintText: "Depense",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                      ),
                      Gap(20.h),
                      ListTile(
                        title: Text("Date d'acquisition"),
                        subtitle:
                            Text("${_selectedDate.toLocal()}".split(' ')[0]),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(DateTime.now().year + 1),
                          );
                          if (picked != null && picked != _selectedDate)
                            setState(() {
                              _selectedDate = picked;
                            });
                        },
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Annuler'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Ajouter'),
                    onPressed: () async {
                      final newExpense = ExpenseModel(
                        id: expense?.id,
                        title: titleController.text,
                        dateTime: _selectedDate,
                        expense: double.parse(expenseController.text),
                      );
                      if (expense == null) {
                        await _expenseService.addExpense(newExpense);
                      } else {
                        await _expenseService.updateExpense(newExpense);
                      }
                      Navigator.of(context).pop();
                      _refreshInventory();
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _deleteExpense(ExpenseModel expense) async {
    await _expenseService.deleteExpense(expense.id!);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("${expense.title}")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des dépenses'),
      ),
      body: FutureBuilder<List<ExpenseModel>>(
        future: _expenseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun équipement trouvé'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final expense = snapshot.data![index];
                return Dismissible(
                  key: Key(expense.id!),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deleteExpense(expense),
                  child: ListTile(
                    title: Text(expense.title!),
                    subtitle: Text(
                        '${DateFormat("EEE dd/hh").format(expense.dateTime!)}\n${expense.expense} FCFA'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditExpenseDialog(context, expense),
                    ),
                    onTap: () {
                      // Afficher les détails de l'équipement
                    },
                  ),
                );
              },
            );
          }
        },

        // children: <Widget>[
        //   ListTile(
        //     title: const Text('Réparation pompe'),
        //     subtitle: const Text('02/05/2024 - 500€'),
        //     trailing: const Icon(Icons.arrow_forward_ios),
        //     onTap: () {
        //       // Afficher les détails de la dépense
        //     },
        //   ),
        //   ListTile(
        //     title: const Text('Entretien chaudière'),
        //     subtitle: const Text('15/04/2024 - 300€'),
        //     trailing: const Icon(Icons.arrow_forward_ios),
        //     onTap: () {
        //       // Afficher les détails de la dépense
        //     },
        //   ),
        //   // Ajouter d'autres dépenses ici
        // ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ouvrir l'écran d'ajout de dépense
          _showAddExpenseDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
