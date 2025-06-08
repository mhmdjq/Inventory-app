import 'package:isar/isar.dart';

part 'item.g.dart';

@Collection()
class Item
{
  Id id = Isar.autoIncrement;  

  late String name;
  late String category;
  late int quantity;
  late double price;
  late DateTime dateAdded;

  String? description;  
  bool? isPopular;

  late List<int>? imageBytes;
}