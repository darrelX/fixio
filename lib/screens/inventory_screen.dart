import 'package:fixio/model/equipment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
// import 'equipment_model.dart';
import '../services/inventory_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  late Future<List<Equipment>> _inventoryFuture;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _inventoryFuture = _inventoryService.getInventory();
  }

  void _refreshInventory() {
    setState(() {
      _inventoryFuture = _inventoryService.getInventory();
    });
  }

  void _showAddEquipmentDialog(BuildContext context) {
    _showEquipmentDialog(context, null);
  }

  void _showEditEquipmentDialog(BuildContext context, Equipment equipment) {
    _showEquipmentDialog(context, equipment);
  }

  void _showEquipmentDialog(BuildContext context, Equipment? equipment) {
    final nameController = TextEditingController(text: equipment?.name ?? '');
    final brandController = TextEditingController(text: equipment?.brand ?? '');
    final modelController = TextEditingController(text: equipment?.model ?? '');
    DateTime _selectedDate = equipment?.acquisitionDate ?? DateTime.now();
    int _expectedLifespan = equipment?.expectedLifespan ?? 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return Form(
            key: _formkey,
            child: Center(
              child: AlertDialog(
                title: Text(equipment == null
                    ? 'Ajouter un équipement'
                    : 'Modifier l\'équipement'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Nom de l'équipement",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Gap(20.h),
                      TextField(
                        controller: brandController,
                        decoration: InputDecoration(
                            hintText: "Marque",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                      ),
                      Gap(20.h),
                      TextField(
                        controller: modelController,
                        decoration: InputDecoration(
                            hintText: "Modèle",
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
                      ListTile(
                        title: Text("Durée de vie prévue (années)"),
                        trailing: DropdownButton<int>(
                          value: _expectedLifespan,
                          items: List.generate(21, (index) => index + 1)
                              .map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                print(newValue);

                                _expectedLifespan = newValue;
                              });
                            }
                          },
                        ),
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
                      final newEquipment = Equipment(
                        id: equipment?.id,
                        name: nameController.text,
                        brand: brandController.text,
                        model: modelController.text,
                        acquisitionDate: _selectedDate,
                        expectedLifespan: _expectedLifespan,
                      );
                      if (equipment == null) {
                        await _inventoryService.addEquipment(newEquipment);
                      } else {
                        await _inventoryService.updateEquipment(newEquipment);
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

  void _deleteEquipement(Equipment equipment) async {
    await _inventoryService.deleteEquipment(equipment.id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("${equipment.name}")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventaire des équipements'),
      ),
      body: FutureBuilder<List<Equipment>>(
        future: _inventoryFuture,
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
                final equipment = snapshot.data![index];
                return Dismissible(
                  key: Key(equipment.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _deleteEquipement(equipment),
                  child: ListTile(
                    title: Text(equipment.name),
                    subtitle: Text('${equipment.brand} - ${equipment.model}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () =>
                          _showEditEquipmentDialog(context, equipment),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEquipmentDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
