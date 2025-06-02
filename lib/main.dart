import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common/models/user.dart';
import 'login/views/splash_screen.dart';
import 'providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

User? globalActiveUser;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (!languageProvider.isInitialized) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: languageProvider.currentLocale,
          home: const SplashScreen(),
        );
      },
    );
  }
}