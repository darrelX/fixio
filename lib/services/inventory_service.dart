import 'package:fixio/model/equipment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InventoryService {
  static const String _key = 'inventory';

  Future<List<Equipment>> getInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? inventoryJson = prefs.getString(_key);
    if (inventoryJson == null) {
      return [];
    }
    final List<dynamic> decodedJson = json.decode(inventoryJson);
    return decodedJson.map((item) => Equipment.fromMap(item)).toList();
  }

  Future<void> addEquipment(Equipment equipment) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Equipment> currentInventory = await getInventory();
    currentInventory.add(equipment);
    final String encodedInventory = json.encode(currentInventory.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encodedInventory);
  }

  Future<void> updateEquipment(Equipment equipment) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Equipment> currentInventory = await getInventory();
    final int index = currentInventory.indexWhere((e) => e.id == equipment.id);
    if (index != -1) {
      currentInventory[index] = equipment;
      final String encodedInventory = json.encode(currentInventory.map((e) => e.toMap()).toList());
      await prefs.setString(_key, encodedInventory);
    }
  }

  Future<void> deleteEquipment(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Equipment> currentInventory = await getInventory();
    currentInventory.removeWhere((e) => e.id == id);
    final String encodedInventory = json.encode(currentInventory.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encodedInventory);
  }
}