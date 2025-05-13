import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_bloc.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_event.dart';
import 'package:nicotinaai_flutter/blocs/locale/locale_state.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';

class LanguageSelectionScreenBloc extends StatelessWidget {
  static const String routeName = '/settings/language';

  const LanguageSelectionScreenBloc({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocConsumer<LocaleBloc, LocaleState>(
      listener: (context, state) {
        if (state.status == LocaleStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? localizations.errorOccurred),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: AppBar(
            title: Text(
              localizations.language,
              style: context.titleStyle,
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: context.backgroundColor,
            iconTheme: IconThemeData(color: context.contentColor),
          ),
          body: SafeArea(
            child: state.status == LocaleStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Description
                      Text(
                        localizations.changeLanguage,
                        style: context.bodyStyle,
                      ),

                      const SizedBox(height: 16),

                      // Button to reset to English
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<LocaleBloc>()
                              .add(ResetToDefaultLocale());
                        },
                        child: const Text("Reset to English (Default)"),
                      ),

                      const SizedBox(height: 16),

                      // List of available languages
                      ...state.supportedLocales.map((locale) {
                        final String languageName = state.getLanguageName(locale);
                        final bool isSelected = locale.languageCode ==
                                state.locale.languageCode &&
                            locale.countryCode == state.locale.countryCode;

                        return Card(
                          elevation: 0,
                          color: context.cardColor,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  isSelected ? context.primaryColor : context.borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              context
                                  .read<LocaleBloc>()
                                  .add(ChangeLocale(locale));
                            },
                            title: Text(
                              languageName,
                              style: context.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? context.primaryColor
                                    : context.contentColor,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle,
                                    color: context.primaryColor)
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
          ),
        );
      },
    );
  }
}