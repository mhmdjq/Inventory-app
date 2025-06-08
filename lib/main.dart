import 'package:final_project_flutter/models/item_database.dart';
import 'package:final_project_flutter/themes/app_themes.dart';
import 'package:final_project_flutter/themes/theme_provider.dart';
import 'package:final_project_flutter/views/all_Items.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await ItemDatabase.initialize();  

  runApp( MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider()
      ),
      ChangeNotifierProvider(
        create: (context) => ItemDatabase(),        
      ),      
    ],
    child: const Home(),
    
  )
  );
}
  
class Home extends StatelessWidget {
  const Home({super.key});  
  

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,      
      themeMode: themeProvider.themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: AllItems(),
    );
  }
}
