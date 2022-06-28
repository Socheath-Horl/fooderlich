import 'package:flutter/cupertino.dart';

import '../models/app_state_manager.dart';
import '../models/grocery_manager.dart';
import '../models/profile_manager.dart';
import '../models/fooderlich_pages.dart';
import '../screens/grocery_item_screen.dart';
import '../screens/home.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/webview_screen.dart';
import './app_link.dart';

class AppRouter extends RouterDelegate<AppLink>
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
        if (!appStateMananger.isInitialized) ...[
          SplashScreen.page(),
        ] else if (!appStateMananger.isLoggedIn) ...[
          LoginScreen.page(),
        ] else if (!appStateMananger.isOnboardingComplete) ...[
          OnboardingScreen.page(),
        ] else ...[
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

  AppLink getCurrentPath() {
    if (!appStateMananger.isLoggedIn) {
      return AppLink(location: AppLink.kLoginPath);
    } else if (!appStateMananger.isOnboardingComplete) {
      return AppLink(location: AppLink.kOnboardingPath);
    } else if (profileManager.didSelectUser) {
      return AppLink(location: AppLink.kProfilePath);
    } else if (groceryManager.isCreatingNewItem) {
      return AppLink(location: AppLink.kItemPath);
    } else if (groceryManager.selectedGroceryItem != null) {
      final id = groceryManager.selectedGroceryItem?.id;
      return AppLink(location: AppLink.kItemPath, itemId: id);
    } else {
      return AppLink(
        location: AppLink.kHomePath,
        currentTab: appStateMananger.getSelectedTab,
      );
    }
  }

  @override
  AppLink get currentConfiguration => getCurrentPath();

  @override
  Future<void> setNewRoutePath(AppLink newLink) async {
    switch (newLink.location) {
      case AppLink.kProfilePath:
        profileManager.tapOnProfile(true);
        break;
      case AppLink.kItemPath:
        final itemId = newLink.itemId;
        if (itemId != null) {
          groceryManager.setSelectedGroceryItem(itemId);
        } else {
          groceryManager.createNewItem();
        }
        profileManager.tapOnProfile(false);
        break;
      case AppLink.kHomePath:
        appStateMananger.goToTab(newLink.currentTab ?? 0);
        profileManager.tapOnProfile(false);
        groceryManager.groceryItemTapped(-1);
        break;
      default:
        break;
    }
  }
}
