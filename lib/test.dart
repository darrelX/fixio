//  Bien sûr, je vais ajouter la possibilité de modifier et de supprimer chaque élément de l'inventaire. Nous allons modifier le fichier `inventory_screen.dart` pour inclure ces fonctionnalités. 



// ```dart
// import 'package:flutter/material.dart';
// import 'equipment_model.dart';
// import 'inventory_service.dart';

// class InventoryScreen extends StatefulWidget {
//   @override
//   _InventoryScreenState createState() => _InventoryScreenState();
// }

// class _InventoryScreenState extends State<InventoryScreen> {
//   final InventoryService _inventoryService = InventoryService();
//   late Future<List<Equipment>> _inventoryFuture;

//   @override
//   void initState() {
//     super.initState();
//     _refreshInventory();
//   }

//   void _refreshInventory() {
//     setState(() {
//       _inventoryFuture = _inventoryService.getInventory();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Inventaire des équipements'),
//       ),
//       body: FutureBuilder<List<Equipment>>(
//         future: _inventoryFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Erreur: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('Aucun équipement trouvé'));
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 final equipment = snapshot.data![index];
//                 return Dismissible(
//                   key: Key(equipment.id),
//                   background: Container(
//                     color: Colors.red,
//                     alignment: Alignment.centerRight,
//                     padding: EdgeInsets.only(right: 20.0),
//                     child: Icon(Icons.delete, color: Colors.white),
//                   ),
//                   direction: DismissDirection.endToStart,
//                   onDismissed: (direction) {
//                     _deleteEquipment(equipment);
//                   },
//                   child: ListTile(
//                     title: Text(equipment.name),
//                     subtitle: Text('${equipment.brand} - ${equipment.model}'),
//                     trailing: IconButton(
//                       icon: Icon(Icons.edit),
//                       onPressed: () => _showEditEquipmentDialog(context, equipment),
//                     ),
//                     onTap: () {
//                       // Afficher les détails de l'équipement
//                     },
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddEquipmentDialog(context),
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   void _showAddEquipmentDialog(BuildContext context) {
//     _showEquipmentDialog(context, null);
//   }

//   void _showEditEquipmentDialog(BuildContext context, Equipment equipment) {
//     _showEquipmentDialog(context, equipment);
//   }

//   void _showEquipmentDialog(BuildContext context, Equipment? equipment) {
//     final nameController = TextEditingController(text: equipment?.name ?? '');
//     final brandController = TextEditingController(text: equipment?.brand ?? '');
//     final modelController = TextEditingController(text: equipment?.model ?? '');
//     DateTime selectedDate = equipment?.acquisitionDate ?? DateTime.now();
//     int expectedLifespan = equipment?.expectedLifespan ?? 1;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text(equipment == null ? 'Ajouter un équipement' : 'Modifier l\'équipement'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(hintText: "Nom de l'équipement"),
//                     ),
//                     TextField(
//                       controller: brandController,
//                       decoration: InputDecoration(hintText: "Marque"),
//                     ),
//                     TextField(
//                       controller: modelController,
//                       decoration: InputDecoration(hintText: "Modèle"),
//                     ),
//                     ListTile(
//                       title: Text("Date d'acquisition"),
//                       subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
//                       trailing: Icon(Icons.calendar_today),
//                       onTap: () async {
//                         final DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: selectedDate,
//                           firstDate: DateTime(2000),
//                           lastDate: DateTime.now(),
//                         );
//                         if (picked != null && picked != selectedDate)
//                           setState(() {
//                             selectedDate = picked;
//                           });
//                       },
//                     ),
//                     ListTile(
//                       title: Text("Durée de vie prévue (années)"),
//                       trailing: DropdownButton<int>(
//                         value: expectedLifespan,
//                         items: List.generate(20, (index) => index + 1)
//                             .map((int value) {
//                           return DropdownMenuItem<int>(
//                             value: value,
//                             child: Text(value.toString()),
//                           );
//                         }).toList(),
//                         onChanged: (int? newValue) {
//                           if (newValue != null) {
//                             setState(() {
//                               expectedLifespan = newValue;
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   child: Text('Annuler'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 TextButton(
//                   child: Text(equipment == null ? 'Ajouter' : 'Modifier'),
//                   onPressed: () async {
//                     final newEquipment = Equipment(
//                       id: equipment?.id,
//                       name: nameController.text,
//                       brand: brandController.text,
//                       model: modelController.text,
//                       acquisitionDate: selectedDate,
//                       expectedLifespan: expectedLifespan,
//                     );
//                     if (equipment == null) {
//                       await _inventoryService.addEquipment(newEquipment);
//                     } else {
//                       await _inventoryService.updateEquipment(newEquipment);
//                     }
//                     Navigator.of(context).pop();
//                     _refreshInventory();
//                   },
//                 ),
//               ],
//             );
//           }
//         );
//       },
//     );
//   }

//   void _deleteEquipment(Equipment equipment) async {
//     await _inventoryService.deleteEquipment(equipment.id);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("${equipment.name} a été supprimé")),
//     );
//     _refreshInventory();
//   }
// }

// ```


// Voici les principales modifications apportées :

// 1. Modification :
//    - Nous avons ajouté un bouton d'édition (icône de crayon) à chaque élément de la liste.
//    - Lorsqu'on appuie sur ce bouton, cela ouvre une boîte de dialogue similaire à celle d'ajout, mais pré-remplie avec les informations de l'équipement existant.
//    - La fonction `_showEquipmentDialog` a été modifiée pour gérer à la fois l'ajout et la modification, en fonction de si un équipement existant est passé en paramètre.

// 2. Suppression :
//    - Nous avons utilisé un widget `Dismissible` pour permettre la suppression par glissement.
//    - Lorsqu'un élément est glissé vers la gauche, il est supprimé de l'inventaire.
//    - Une SnackBar apparaît pour confirmer la suppression et offrir potentiellement une option d'annulation (non implémentée ici).

// 3. Réutilisation du code :
//    - La fonction `_showEquipmentDialog` est maintenant utilisée à la fois pour l'ajout et la modification, ce qui réduit la duplication de code.

// 4. Rafraîchissement de l'interface :
//    - La fonction `_refreshInventory` est appelée après chaque opération (ajout, modification, suppression) pour mettre à jour la liste affichée.

// Ces modifications permettent une gestion complète de l'inventaire directement depuis l'écran principal, offrant une expérience utilisateur fluide pour ajouter, modifier et supprimer des équipements.

// Pour améliorer davantage cette fonctionnalité, vous pourriez envisager :

// 1. Ajouter une confirmation avant la suppression.
// 2. Implémenter une fonction de recherche ou de filtrage.
// 3. Ajouter un écran de détails pour chaque équipement.
// 4. Améliorer la validation des entrées dans le formulaire.

// Souhaitez-vous que je développe l'une de ces améliorations ou que j'explique plus en détail une partie spécifique de l'implémentation actuelle ?