import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/item_database.dart';
import '../text_style/my_title_text.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedCategory;
  bool isPopular = false;
  Uint8List? imageBytes;

  String? nameError;
  String? categoryError;
  String? quantityError;
  String? priceError;

  final List<String> categories = ['Electronics', 'Clothing', 'Food', 'Books'];

  final ImagePicker _picker = ImagePicker();

  bool validate() {
    setState(() {
      nameError = nameController.text.length < 2 ? "Enter at least 2 characters" : null;
      categoryError = selectedCategory == null ? "Please select a category" : null;
      quantityError = (quantityController.text.isEmpty || int.tryParse(quantityController.text) == null)
          ? "Enter a valid quantity"
          : null;
      priceError = (priceController.text.isEmpty || double.tryParse(priceController.text) == null)
          ? "Enter a valid price"
          : null;
    });
    return nameError == null && categoryError == null && quantityError == null && priceError == null;
  }

  Future<void> getImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyTitleText("Add Item"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCard(
              children: [
                _buildTextField("Name", nameController, hint: "Enter item name", icon: Icons.abc, errorText: nameError),
                _buildDropdownField(),
                _buildTextField("Quantity", quantityController, hint: "Enter quantity", icon: Icons.numbers, errorText: quantityError, isNumber: true),
                _buildTextField("Price", priceController, hint: "Enter price", icon: Icons.attach_money, errorText: priceError, isNumber: true),
                _buildTextField("Description", descriptionController, hint: "Optional description", icon: Icons.description, maxLines: 3),
                _buildCheckbox(),
              ],
            ),
            const SizedBox(height: 20),
            _buildImagePicker(), // 👇 Image section now at bottom
            const SizedBox(height: 20),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    IconData? icon,
    String? errorText,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          errorText: errorText,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
        onChanged: (val) => setState(() => selectedCategory = val),
        decoration: InputDecoration(
          labelText: "Category",
          prefixIcon: Icon(Icons.category),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          errorText: categoryError,
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: CheckboxListTile(
        title: Text("Mark as Popular"),
        value: isPopular,
        onChanged: (val) => setState(() => isPopular = val ?? false),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (imageBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.memory(imageBytes!, height: 150),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => getImage(ImageSource.gallery),
              icon: Icon(Icons.photo),
              label: Text("Pick Image"),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => getImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt),
              label: Text("Take Image"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () {
            if (validate()) {
              context.read<ItemDatabase>().addNewItem(
                    nameController.text,
                    selectedCategory!,
                    int.parse(quantityController.text),
                    double.parse(priceController.text),
                    DateTime.now(),
                    description: descriptionController.text,
                    isPopular: isPopular,
                    imageBytes: imageBytes?.toList(),
                  );
              Navigator.pop(context);
            }
          },
          child: const Text("Add Item"),
        ),
      ],
    );
  }
}
