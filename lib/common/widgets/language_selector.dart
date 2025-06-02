import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return GestureDetector(
      onTap: () async {
        final newLang = languageProvider.currentLocale.languageCode != 'en'
            ? 'en'
            : 'hi';
        await languageProvider.setLanguage(newLang);
      },
      child: Container(
        margin: EdgeInsets.only(right: 20),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          languageProvider.currentLocale.languageCode != 'en'
              ? "अ / A"
              : "A / अ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 