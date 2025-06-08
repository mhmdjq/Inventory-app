import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project_flutter/models/item_database.dart';
import 'package:final_project_flutter/text_style/my_title_text.dart';
import 'package:final_project_flutter/views/search/search_by_date.dart';
import 'package:final_project_flutter/views/search/search_by_id.dart';
import 'package:final_project_flutter/views/search/search_by_name.dart';
import 'package:final_project_flutter/views/search/search_by_price.dart';
import 'package:final_project_flutter/views/search/search_by_quantity.dart';
import 'package:final_project_flutter/views/search/search_by_category.dart';

class SearchMain extends StatefulWidget {
  const SearchMain({super.key});

  @override
  State<SearchMain> createState() => _SearchMainState();
}

class _SearchMainState extends State<SearchMain> {
  @override
  void initState() {
    super.initState();
    context.read<ItemDatabase>().fetchItems();
  }

  final List<Map<String, dynamic>> searchOptions = [
    {'label': 'By ID', 'icon': Icons.perm_identity, 'page': const SearchById()},
    {'label': 'By Name', 'icon': Icons.text_fields, 'page': const SearchByName()},
    {'label': 'By Category', 'icon': Icons.category, 'page': const SearchByCategory()},
    {'label': 'By Quantity', 'icon': Icons.confirmation_num, 'page': const SearchByQuantity()},
    {'label': 'By Price', 'icon': Icons.attach_money, 'page': const SearchByPrice()},
    {'label': 'By Date', 'icon': Icons.calendar_today, 'page': const SearchByDate()},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: MyTitleText('Search Items'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.grey[900]!.withOpacity(0.9), Colors.grey[800]!.withOpacity(0.8)]
                  : [Colors.white.withOpacity(0.9), Colors.grey[100]!.withOpacity(0.8)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey[900]!, Colors.grey[850]!]
                : [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: searchOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final item = searchOptions[index];
                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item['page']),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [Colors.grey[800]!, Colors.grey[700]!]
                              : [Colors.white, Colors.grey[50]!],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'], size: 36, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 12),
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
