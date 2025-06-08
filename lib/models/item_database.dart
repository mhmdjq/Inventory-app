import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
// import '../models/item.dart';
import 'package:final_project_flutter/models/item.dart';
// import 'package:provider/provider.dart';

class ItemDatabase extends ChangeNotifier{
  static late Isar isar;

  static Future<void> initialize() async{
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ItemSchema], directory: dir.path);
  }

  final List<Item> allItems = [];

  Future<void> addNewItem(String newName, String newCategory,  int newQuantity,
  double newPrice,DateTime newDateAdded, {String? description, List<int>? imageBytes, 
  bool? isPopular = false}) async{
    final newItem = Item()
    ..name = newName
    ..category = newCategory
    ..quantity = newQuantity
    ..price = newPrice
    ..dateAdded = newDateAdded
    ..description = description    
    ..isPopular = isPopular
    ..imageBytes = imageBytes;

    await isar.writeTxn(() => isar.items.put(newItem));

    fetchItems();
  }

  Future<void> fetchItems() async{
  List<Item> fetchItems = await isar.items.where().findAll();
  allItems.clear();
  allItems.addAll(fetchItems);
  notifyListeners();
  }  

  Future<void> updateItem(int id, String newName, String newCategory,  int newQuantity,
  double newPrice,DateTime newDateAdded, {String? description, List<int>? imageBytes, 
  bool? isPopular = false}) async{
    final existingItem = await isar.items.get(id);
    if (existingItem != null) {
      existingItem.name = newName;
      existingItem.category = newCategory;
      existingItem.quantity = newQuantity;
      existingItem.price = newPrice;
      existingItem.dateAdded = newDateAdded;
      existingItem.description = description;
      existingItem.imageBytes = imageBytes;
      existingItem.isPopular = isPopular;
      await isar.writeTxn(() => isar.items.put(existingItem));
      await fetchItems();
    }
  }

  Future<void> deleteItem(int id) async{
    await isar.writeTxn(() => isar.items.delete(id));
    await fetchItems();
  }

  // Search By ID
  Future<void> searchByID(String x) async{
    List<Item> currentItems = [];

    int value = -1;
    if(int.tryParse(x) != null){
      value = int.parse(x);
    }

    if (value != -1) {
      currentItems = 
      await isar.items.filter().idEqualTo(value).findAllSync();  
    }
    
    allItems.clear();
    allItems.addAll(currentItems);
    notifyListeners();
  }


  // search by name
  Future<void> searchByName(String x) async{
    List<Item> currentItems = [];

    if (x.isNotEmpty) {
      currentItems = 
      await isar.items.filter().
      nameContains(x, caseSensitive: false).sortByName().findAllSync();
    }
    
    allItems.clear();
    allItems.addAll(currentItems);
    notifyListeners();
  }

  // search by category
  Future<void> searchByCategory(String x) async{
    List<Item> currentItems = [];

    if (x.isNotEmpty) {
      currentItems = 
      await isar.items.filter().
      categoryContains(x, caseSensitive: false).sortByCategory().findAllSync();
    }
    
    allItems.clear();
    allItems.addAll(currentItems);
    notifyListeners();
  }

  //search by Age
  Future<void> searchByQuantity(String x, String y) async{
    List<Item> currentItems = [];

    int valueX = -1, valueY = -1;

    if(int.tryParse(x) != null && int.tryParse(y) != null){
      valueX = int.parse(x);
      valueY = int.parse(y);
    }

    if (valueX != -1 && valueY != -1) {
      currentItems = 
      await isar.items.filter().quantityBetween(valueX, valueY).
      sortByQuantity().findAllSync();  
    }
    
    allItems.clear();
    allItems.addAll(currentItems);
    notifyListeners();
  }

  //search by Price
  Future<void> searchByPrice(String from, String to) async{
    List<Item> currentItems = [];

    double valueFrom = -1, valueTo = -1;

    if(int.tryParse(from) != null && int.tryParse(to) != null){
      valueFrom = double.parse(from);
      valueTo = double.parse(to);
    }

    if (valueFrom != -1 && valueTo != -1) {
      currentItems = 
      await isar.items.filter().priceBetween(valueFrom, valueTo).
      sortByPrice().findAllSync();
    }
    
    allItems.clear();
    allItems.addAll(currentItems);
    notifyListeners();
  }

  Future<void> searchByDateRange(DateTime from, DateTime to) async {
  List<Item> currentItems = [];

  if (from.isBefore(to) || from.isAtSameMomentAs(to)) {
    currentItems = await isar.items
        .filter()
        .dateAddedBetween(from, to)
        .sortByDateAdded()
        .findAll();
  }

  allItems.clear();
  allItems.addAll(currentItems);
  notifyListeners();
 }
}

