import 'package:flutter/cupertino.dart';
import 'package:fooderlich/models/fooderlich_pages.dart';
import 'package:fooderlich/screens/profile_screen.dart';
import 'package:fooderlich/screens/screens.dart';

import '../models/app_state_manager.dart';
import '../models/grocery_manager.dart';
import '../models/profile_manager.dart';
import '../screens/grocery_item_screen.dart';
import '../screens/home.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppStateMananger appStateMananger;
  final GroceryManager groceryManager;
  final ProfileManager profileManager;

  AppRouter({
    required this.appStateMananger,
    required this.groceryManager,
    required this.profileManager,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    appStateMananger.addListener(notifyListeners);
    groceryManager.addListener(notifyListeners);
    profileManager.addListener(notifyListeners);
  }

  @override
  void dispose() {
    appStateMananger.removeListener(notifyListeners);
    groceryManager.removeListener(notifyListeners);
    profileManager.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _handlePopPage,
      pages: [
        if (!appStateMananger.isInitialized) SplashScreen.page(),
        if (appStateMananger.isInitialized && !appStateMananger.isLoggedIn)
          LoginScreen.page(),
        if (appStateMananger.isLoggedIn &&
            !appStateMananger.isOnboardingComplete)
          OnboardingScreen.page(),
        if (appStateMananger.isOnboardingComplete)
          Home.page(appStateMananger.getSelectedTab),
        if (groceryManager.isCreatingNewItem)
          GroceryItemScreen.page(
            onCreate: (item) {
              groceryManager.addItem(item);
            },
            onUpdate: (item, index) {},
          ),
        if (groceryManager.selectedIndex != -1)
          GroceryItemScreen.page(
            item: groceryManager.selectedGroceryItem,
            index: groceryManager.selectedIndex,
            onUpdate: (item, index) {
              groceryManager.updateItem(item, index);
            },
            onCreate: (_) {},
          ),
        if (profileManager.didSelectUser)
          ProfileScreen.page(profileManager.getUser),
        if (profileManager.didTapOnRaywnderlich) WebViewScreen.page(),
      ],
    );
  }

  bool _handlePopPage(Route<dynamic> route, result) {
    if (!route.didPop(result)) {
      return false;
    }
    if (route.settings.name == FooderlichPages.onboardingPath) {
      appStateMananger.logout();
    }
    if (route.settings.name == FooderlichPages.groceryItemDetails) {
      groceryManager.groceryItemTapped(-1);
    }
    if (route.settings.name == FooderlichPages.profilePath) {
      profileManager.tapOnProfile(false);
    }
    if (route.settings.name == FooderlichPages.raywenderlich) {
      profileManager.tapOnRaywenderlich(false);
    }
    return true;
  }

  @override
  Future<void> setNewRoutePath(configuration) async => null;
}
