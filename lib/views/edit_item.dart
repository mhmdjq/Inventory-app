import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/item_database.dart';
import '../text_style/my_title_text.dart';

class EditItem extends StatefulWidget {
  const EditItem(this.item, {super.key});
  final Item item;

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  String? nameErrorMsg;
  String? categoryErrorMsg;
  String? quantityErrorMsg;
  String? priceErrorMsg;

  final List<String> categories = ['Electronics', 'Clothing', 'Food', 'Books'];
  String? selectedCategory;
  bool isPopular = false;

  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item.name;
    selectedCategory = widget.item.category;
    quantityController.text = widget.item.quantity.toString();
    priceController.text = widget.item.price.toString();
    descriptionController.text = widget.item.description ?? '';
    isPopular = widget.item.isPopular ?? false;
    imageBytes = widget.item.imageBytes != null
    ? Uint8List.fromList(widget.item.imageBytes!)
    : null;
  }

  bool validateInputs() {
    setState(() {
      nameErrorMsg = nameController.text.length < 2 ? 'Enter at least 2 characters' : null;
      categoryErrorMsg = selectedCategory == null ? 'Select a category' : null;
      quantityErrorMsg = int.tryParse(quantityController.text) == null ? 'Invalid quantity' : null;
      priceErrorMsg = double.tryParse(priceController.text) == null ? 'Invalid price' : null;
    });

    return nameErrorMsg == null && categoryErrorMsg == null && quantityErrorMsg == null && priceErrorMsg == null;
  }

  Future<void> pickImage() async {
  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (picked != null) {
    final bytes = await picked.readAsBytes();
    setState(() {
      imageBytes = bytes;
    });
  }
}

Future<void> takeImage() async {
  final picked = await ImagePicker().pickImage(source: ImageSource.camera);
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
        title: MyTitleText("Edit Item"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(nameController, 'Name', Icons.abc, nameErrorMsg),
            _buildDropdown(),
            _buildTextField(quantityController, 'Quantity', Icons.numbers, quantityErrorMsg, isNumber: true),
            _buildTextField(priceController, 'Price', Icons.attach_money, priceErrorMsg, isNumber: true),
            _buildTextField(descriptionController, 'Description', Icons.description, null, maxLines: 3),
            CheckboxListTile(
              value: isPopular,
              onChanged: (value) => setState(() => isPopular = value ?? false),
              title: const Text('Mark as Popular'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Image"),
                  onPressed: pickImage,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Image"),
                  onPressed: takeImage,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(imageBytes!, height: 160),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (validateInputs()) {
                      context.read<ItemDatabase>().updateItem(
                        widget.item.id,
                        nameController.text,
                        selectedCategory!,
                        int.parse(quantityController.text),
                        double.parse(priceController.text),
                        DateTime.now(),
                        description: descriptionController.text,
                        isPopular: isPopular,
                        imageBytes: imageBytes,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String? errorText,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          errorText: errorText,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: InputDecoration(
          labelText: 'Category',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          errorText: categoryErrorMsg,
        ),
        items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
        onChanged: (value) => setState(() => selectedCategory = value),
      ),
    );
  }
}
