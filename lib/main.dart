import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './fooderlich_theme.dart';
import './models/app_state_manager.dart';
import './models/grocery_manager.dart';
import './models/profile_manager.dart';
import './navigation/app_router.dart';

void main() {
  runApp(const FooderlichApp());
}

class FooderlichApp extends StatefulWidget {
  const FooderlichApp({Key? key}) : super(key: key);

  @override
  State<FooderlichApp> createState() => _FooderlichAppState();
}

class _FooderlichAppState extends State<FooderlichApp> {
  final _groceryManager = GroceryManager();
  final _profileManager = ProfileManager();
  final _appStateManager = AppStateMananger();
  late AppRouter _appRouter;

  @override
  void initState() {
    _appRouter = AppRouter(
      appStateMananger: _appStateManager,
      groceryManager: _groceryManager,
      profileManager: _profileManager,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => _groceryManager,
        ),
        ChangeNotifierProvider(
          create: (context) => _profileManager,
        ),
        ChangeNotifierProvider(
          create: (context) => _appStateManager,
        ),
      ],
      child: Consumer<ProfileManager>(
        builder: (context, profileManager, child) {
          ThemeData theme;
          if (profileManager.darkMode) {
            theme = FooderlichTheme.dark();
          } else {
            theme = FooderlichTheme.light();
          }

          return MaterialApp(
            theme: theme,
            title: 'Fooderlich',
            home: Router(
              routerDelegate: _appRouter,
              backButtonDispatcher: RootBackButtonDispatcher(),
            ),
          );
        },
      ),
    );
  }
}
