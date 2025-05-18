import 'package:flutter/widgets.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

/// A helper class that handles localization of achievement names and descriptions.
class AchievementLocalizer {
  /// Maps an achievement ID to its corresponding localized name.
  static String getLocalizedName(BuildContext context, String achievementId) {
    final l10n = AppLocalizations.of(context);
    
    // Map the achievement ID to the correct translation key
    switch (achievementId) {
      case '4bb169cc-8cc6-4440-ae1a-aa25a2105715':
        return l10n.achievementFirstStep;
      case 'b807746a-3988-44cf-88d4-fd99d92bc6aa':
        return l10n.achievementOneDayWonder;
      case '26deeffb-d7cf-4e69-8973-cdc07f1c2698':
        return l10n.achievementWeekWarrior;
      case 'fe4e5f79-2021-47ce-bd54-284325ec8acb':
        return l10n.achievementMonthMaster;
      case 'fe471ea4-0d4d-43ab-bb7e-46eb979ce400':
        return l10n.achievementMoneyMindful;
      case 'c1824daf-0d0b-4850-ad40-580fbb972510':
        return l10n.achievementCenturion;
      case '56cb9673-a29a-4019-af8e-be3cf58fde4d':
        return l10n.achievementCravingCrusher;
      default:
        // Fallback to using achievement name from database
        return 'Achievement';
    }
  }

  /// Maps an achievement ID to its corresponding localized description.
  static String getLocalizedDescription(BuildContext context, String achievementId) {
    final l10n = AppLocalizations.of(context);
    
    // Map the achievement ID to the correct translation key
    switch (achievementId) {
      case '4bb169cc-8cc6-4440-ae1a-aa25a2105715':
        return l10n.achievementFirstStepDescription;
      case 'b807746a-3988-44cf-88d4-fd99d92bc6aa':
        return l10n.achievementOneDayWonderDescription;
      case '26deeffb-d7cf-4e69-8973-cdc07f1c2698':
        return l10n.achievementWeekWarriorDescription;
      case 'fe4e5f79-2021-47ce-bd54-284325ec8acb':
        return l10n.achievementMonthMasterDescription;
      case 'fe471ea4-0d4d-43ab-bb7e-46eb979ce400':
        return l10n.achievementMoneyMindfulDescription;
      case 'c1824daf-0d0b-4850-ad40-580fbb972510':
        return l10n.achievementCenturionDescription;
      case '56cb9673-a29a-4019-af8e-be3cf58fde4d':
        return l10n.achievementCravingCrusherDescription;
      default:
        // Fallback to using achievement description from database
        return 'Achievement description';
    }
  }
  
  /// Formats currency in financial achievement descriptions based on the user's locale
  static String formatFinancialDescription(
    BuildContext context, 
    String achievementId, 
    String currencySymbol
  ) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    
    // Define replacement patterns for each currency format by locale
    Map<String, List<String>> currencyPatterns = {
      'en': [r'$50', r'$100'], 
      'pt': [r'R$50', r'R$100'],
      'es': [r'€50', r'€100'],
      'fr': [r'50€', r'100€'],
      'it': [r'50€', r'100€'],
      'de': [r'50€', r'100€'],
      'nl': [r'€50', r'€100'],
      'pl': [r'50 zł', r'100 zł'],
    };
    
    // Default to English patterns if locale not found
    List<String> patterns = currencyPatterns[locale] ?? currencyPatterns['en']!;
    
    // Handle Money Mindful achievement (50 units)
    if (achievementId == 'fe471ea4-0d4d-43ab-bb7e-46eb979ce400') {
      String desc = l10n.achievementMoneyMindfulDescription;
      
      // Replace the currency pattern with the user's preferred currency
      return desc.replaceAll(patterns[0], formatCurrency(locale, currencySymbol, '50'));
    } 
    // Handle Centurion achievement (100 units)
    else if (achievementId == 'c1824daf-0d0b-4850-ad40-580fbb972510') {
      String desc = l10n.achievementCenturionDescription;
      
      // Replace the currency pattern with the user's preferred currency
      return desc.replaceAll(patterns[1], formatCurrency(locale, currencySymbol, '100'));
    }
    
    // If not a financial achievement, just return the regular description
    return getLocalizedDescription(context, achievementId);
  }
  
  /// Gets the appropriate currency format based on locale
  /// (some locales put symbol before amount, others after)
  static String formatCurrency(String locale, String symbol, String amount) {
    // For languages that place currency symbol after the amount
    if (['fr', 'it', 'pl'].contains(locale)) {
      return '$amount$symbol';
    }
    // For all others, place currency symbol before the amount
    return '$symbol$amount';
  }
}