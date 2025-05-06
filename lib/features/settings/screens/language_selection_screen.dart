import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicotinaai_flutter/core/localization/locale_provider.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  static const String routeName = '/settings/language';

  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(localizations.language, style: context.titleStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.backgroundColor,
        iconTheme: IconThemeData(color: context.contentColor),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Descrição
            Text(
              localizations.changeLanguage,
              style: context.bodyStyle,
            ),
            
            const SizedBox(height: 24),
            
            // Lista de idiomas disponíveis
            ...localeProvider.supportedLocales.map((locale) {
              final String languageName = localeProvider.getLanguageName(locale);
              final bool isSelected = locale.languageCode == localeProvider.locale.languageCode && 
                                     locale.countryCode == localeProvider.locale.countryCode;
              
              return Card(
                elevation: 0,
                color: context.cardColor,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? context.primaryColor : context.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    localeProvider.setLocale(locale);
                  },
                  title: Text(
                    languageName,
                    style: context.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? context.primaryColor : context.contentColor,
                    ),
                  ),
                  trailing: isSelected 
                    ? Icon(Icons.check_circle, color: context.primaryColor)
                    : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}