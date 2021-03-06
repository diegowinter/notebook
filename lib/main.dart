import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/auth_or_home.dart';
import './screens/settings_screen.dart';
import './screens/auth_screen.dart';
import './screens/dashboard_screen.dart';
import './screens/collection_screen.dart';
import './screens/page_composer_screen.dart';
import './screens/page_viewer_screen.dart';
import './providers/collections.dart';
import './providers/user.dart';
import './providers/pages.dart';
import './providers/preferences.dart';
import './utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => new User(),
        ),
        ChangeNotifierProxyProvider<User, Collections>(
          create: (_) => new Collections('', '', [], null),
          update: (ctx, user, previousCollections) => new Collections(
            user.token,
            user.id,
            previousCollections!.collections,
            user.expiryDate,
          ),
        ),
        ChangeNotifierProxyProvider<User, Pages>(
          create: (_) => new Pages('', '', [], null),
          update: (ctx, user, previousPages) => new Pages(
            user.id,
            user.token,
            previousPages!.pages,
            user.expiryDate,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => new Preferences(
            theme: sharedPreferences.getString('theme') ?? 'ThemeMode.dark',
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        final preferences = Provider.of<Preferences>(context);
        return MaterialApp(
          title: 'Notebook',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.cyan,
            accentColor: Colors.cyan,
            inputDecorationTheme: InputDecorationTheme(
              fillColor: Colors.grey[300],
              filled: true,
            ),
            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            iconTheme: IconThemeData(color: Colors.black),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            appBarTheme: AppBarTheme(
              backgroundColor: Color.fromRGBO(250, 250, 250, 1),
              titleSpacing: 0,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.cyan,
            accentColor: Colors.cyan,
            backgroundColor: Color.fromRGBO(48, 48, 48, 1),
            inputDecorationTheme: InputDecorationTheme(
              fillColor: Colors.grey[800],
              filled: true,
            ),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            appBarTheme: AppBarTheme(
              backgroundColor: Color.fromRGBO(48, 48, 48, 1),
              titleSpacing: 0,
              elevation: 0,
            ),
          ),
          themeMode: preferences.themeMode,
          debugShowCheckedModeBanner: false,
          routes: {
            AppRoutes.AUTH_OR_HOME: (ctx) => AuthOrHome(),
            AppRoutes.AUTH: (ctx) => AuthScreen(),
            AppRoutes.DASHBOARD: (ctx) => DashboardScreen(),
            AppRoutes.SETTINGS: (ctx) => SettingsScreen(),
            // AppRoutes.COLLECTION: (ctx) => CollectionScreen(),
            // AppRoutes.PAGE_COMPOSER: (ctx) => PageComposerScreen(),
            // AppRoutes.PAGE_VIEWER: (ctx) => PageViewerScreen()
          },
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.COLLECTION:
                final String argument = settings.arguments.toString();
                return MaterialPageRoute(
                  builder: (context) {
                    return CollectionScreen(collectionId: argument);
                  },
                );
              case AppRoutes.PAGE_COMPOSER:
                final argument = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) {
                    return PageComposerScreen(
                      collectionId: argument['collectionId'],
                      collectionPage: argument['collectionPage'],
                      mode: argument['mode'],
                    );
                  },
                );
              case AppRoutes.PAGE_VIEWER:
                final argument = settings.arguments as CollectionPage;
                return MaterialPageRoute(
                  builder: (context) {
                    return PageViewerScreen(argument);
                  },
                );
            }
          },
        );
      },
    );
  }
}
