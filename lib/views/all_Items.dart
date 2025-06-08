import 'dart:io';
import 'dart:typed_data';
import 'package:final_project_flutter/models/item.dart';
import 'package:final_project_flutter/models/item_database.dart';
import 'package:final_project_flutter/text_style/my_title_text.dart';
import 'package:final_project_flutter/themes/theme_provider.dart';
import 'package:final_project_flutter/views/about_us.dart';
import 'package:final_project_flutter/views/add_item.dart';
import 'package:final_project_flutter/views/edit_item.dart';
import 'package:final_project_flutter/views/search/search_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AllItems extends StatefulWidget {
  const AllItems({super.key});

  @override
  State<AllItems> createState() => _AllItemsState();
}

class _AllItemsState extends State<AllItems> with TickerProviderStateMixin {
  ScrollController myScroll = ScrollController();
  bool isVisible = true;
  bool isGridView = false;
  String sortBy = 'name';
  bool sortAscending = true;
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    context.read<ItemDatabase>().fetchItems();
    
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _listAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _listAnimationController, curve: Curves.easeOutBack));

    myScroll.addListener(() {
      if (myScroll.position.userScrollDirection == ScrollDirection.reverse && isVisible) {
        setState(() {
          isVisible = false;
        });
        _fabAnimationController.reverse();
      } else if (myScroll.position.userScrollDirection == ScrollDirection.forward && !isVisible) {
        setState(() {
          isVisible = true;
        });
        _fabAnimationController.forward();
      }
    });

    _fabAnimationController.forward();
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  List<Item> _getSortedItems(List<Item> items) {
    List<Item> sortedItems = List.from(items);
    
    switch (sortBy) {
      case 'name':
        sortedItems.sort((a, b) => sortAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case 'price':
        sortedItems.sort((a, b) => sortAscending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
        break;
      case 'quantity':
        sortedItems.sort((a, b) => sortAscending ? a.quantity.compareTo(b.quantity) : b.quantity.compareTo(a.quantity));
        break;
      case 'date':
        sortedItems.sort((a, b) => sortAscending ? a.dateAdded.compareTo(b.dateAdded) : b.dateAdded.compareTo(a.dateAdded));
        break;
    }
    
    return sortedItems;
  }

  @override
  Widget build(BuildContext context) {
    final List<Item> currentItems = context.watch<ItemDatabase>().allItems;
    final sortedItems = _getSortedItems(currentItems);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: MyTitleText('All Items'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface.withOpacity(0.9),
                colorScheme.surface.withOpacity(0.8)
              ],
            ),
          ),
        ),
        actions: [
          // Statistics button
          IconButton(
            icon: Icon(Icons.analytics_sharp, color: colorScheme.onSurface),
            onPressed: () => _showStatistics(context, currentItems),
          ),
          // Sort button
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: colorScheme.onSurface),
            onSelected: (value) {
              setState(() {
                if (sortBy == value) {
                  sortAscending = !sortAscending;
                } else {
                  sortBy = value;
                  sortAscending = true;
                }
              });
              HapticFeedback.lightImpact();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              PopupMenuItem(value: 'price', child: Text('Sort by Price')),
              PopupMenuItem(value: 'quantity', child: Text('Sort by Quantity')),
              PopupMenuItem(value: 'date', child: Text('Sort by Date')),
            ],
          ),
          // View toggle
          IconButton(
            icon: Icon(
              isGridView ? Icons.list : Icons.grid_view,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
      drawer: _buildEnhancedDrawer(context),      
      body: Container(        
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.background,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Enhanced header with stats
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.surfaceVariant.withOpacity(0.8),
                              colorScheme.surface.withOpacity(0.6)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Inventory Overview',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard('Total Items', currentItems.length.toString(), Icons.inventory, colorScheme.primary),
                                _buildStatCard('Popular', currentItems.where((i) => i.isPopular == true).length.toString(), Icons.star, Colors.amber),
                                _buildStatCard('Low Stock', currentItems.where((i) => i.quantity < 10).length.toString(), Icons.warning, colorScheme.error),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Items display
                      Expanded(
                        child: currentItems.isEmpty
                            ? _buildEmptyState()
                            : AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: isGridView
                                    ? _buildGridView(sortedItems)
                                    : _buildEnhancedListView(sortedItems),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItem()),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Add Item'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No items yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first item',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Item> items) {
    return GridView.builder(
      key: ValueKey('grid'),
      controller: myScroll,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildGridCard(items[index]);
      },
    );
  }

  Widget _buildGridCard(Item item) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceVariant.withOpacity(0.5)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: item.imageBytes != null
                        ? MemoryImage(Uint8List.fromList(item.imageBytes!))
                        : null,
                    backgroundColor: colorScheme.surfaceVariant,
                    child: item.imageBytes == null
                        ? Icon(Icons.image_not_supported, size: 16, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                  if (item.isPopular == true)
                    Icon(Icons.star, color: colorScheme.secondary, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Text(
                'Qty: ${item.quantity}',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                '${item.price} JD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: colorScheme.primary),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditItem(item)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20, color: colorScheme.error),
                    onPressed: () => _showEnhancedDeleteDialog(item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedListView(List<Item> items) {
    return ListView.builder(
      key: ValueKey('list'),
      controller: myScroll,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          child: _buildEnhancedItemCard(items[index]),
        );
      },
    );
  }

  Widget _buildEnhancedItemCard(Item item) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceVariant.withOpacity(0.5)
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Enhanced image/ID section
                    Hero(
                      tag: 'item_${item.id}',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withOpacity(0.8),
                              colorScheme.primary.withOpacity(0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: item.imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  Uint8List.fromList(item.imageBytes!),
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2,
                                    color: colorScheme.onPrimary,
                                    size: 24,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '#${item.id}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(width: 20),
                    
                    // Enhanced details section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (item.isPopular == true)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.amber, Colors.orange],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Popular',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 12),
                          
                          // Info chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildInfoChip(
                                'ID: ${item.id}',
                                Icons.tag,
                                colorScheme.secondary,
                              ),
                              _buildInfoChip(
                                'Qty: ${item.quantity}',
                                Icons.inventory,
                                item.quantity < 10 ? colorScheme.error : colorScheme.primary,
                              ),
                              _buildInfoChip(
                                '${item.price} JD',
                                Icons.monetization_on,
                                colorScheme.tertiary,
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 8),
                          Text(
                            'Added: ${item.dateAdded.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          
                          if (item.description?.isNotEmpty == true) ...[
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.description!,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Enhanced action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditItem(item)),
                          );
                        },
                        icon: Icon(Icons.edit, size: 18),
                        label: Text('Edit Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showEnhancedDeleteDialog(item);
                        },
                        icon: Icon(Icons.delete, size: 18),
                        label: Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDrawer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.background,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mhmd4's Store",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    "Inventory Management",
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 40,
                    color: colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
            
            SwitchListTile(
              title: Text('Dark Mode', style: TextStyle(color: colorScheme.onSurface)),
              subtitle: Text('Toggle app theme', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              secondary: Icon(Icons.dark_mode, color: colorScheme.onSurfaceVariant),
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              activeColor: colorScheme.primary,
              onChanged: (val) {
                HapticFeedback.lightImpact();
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme(val);
              },
            ),
            
            Divider(color: colorScheme.outline.withOpacity(0.3)),
            
            _buildDrawerItem(
              icon: Icons.home,
              title: "All Items",
              onTap: () => Navigator.pop(context),
            ),
            
            _buildDrawerItem(
              icon: Icons.add_circle,
              title: "Add Item",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddItem()));
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.search,
              title: "Search Items",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchMain())),
            ),
            
            _buildDrawerItem(
              icon: Icons.info_outline,
              title: "About the App",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUs()));
              },
            ),
            
            Spacer(),
            Divider(color: colorScheme.outline.withOpacity(0.3)),
            
            _buildDrawerItem(
              icon: Icons.exit_to_app,
              title: "Exit App",
              textColor: colorScheme.error,
              onTap: () => exit(0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveTextColor = textColor ?? colorScheme.onSurface;
    
    return ListTile(
      leading: Icon(icon, color: effectiveTextColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: effectiveTextColor,
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _showEnhancedDeleteDialog(Item item) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: colorScheme.error, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Confirm Delete",
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: 18,          // ← added explicit size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Are you sure you want to delete “${item.name}”?',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 14)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () {
              context.read<ItemDatabase>().deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

/* ─────────────────  STATISTICS DIALOG  ───────────────── */
  void _showStatistics(BuildContext ctx, List<Item> items) {
    final cs = Theme.of(ctx).colorScheme;
    final total = items.fold<double>(0, (s, e) => s + e.price * e.quantity);
    final avg = items.isEmpty
        ? 0
        : items.fold<double>(0, (s, e) => s + e.price) / items.length;

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.analytics, color: cs.primary, size: 26),
            const SizedBox(width: 8),
            Text('Inventory Statistics',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow('Total Items', '${items.length}', cs),
            _statRow('Total Value', '${total.toStringAsFixed(2)} JD', cs),
            _statRow('Avg. Price', '${avg.toStringAsFixed(2)} JD', cs),
            _statRow('Popular', '${items.where((e) => e.isPopular == true).length}',
                cs),
            _statRow('Low Stock (<10)',
                '${items.where((e) => e.quantity < 10).length}', cs),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, ColorScheme cs) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface)),
          ],
        ),
      );
} // ← closes _AllItemsState
