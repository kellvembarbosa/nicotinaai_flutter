#!/bin/bash

# This script adds achievement translations to the language files
# Usage: ./add_achievement_translations.sh

# Root directory of the project
ROOT_DIR="$(pwd)"
L10N_DIR="$ROOT_DIR/assets/l10n"

# Languages to process
LANGUAGES=("en" "pt" "es" "fr" "it" "de" "nl" "pl")

for lang in "${LANGUAGES[@]}"; do
  echo "Processing $lang translations..."
  
  # Create a temporary file
  TEMP_FILE=$(mktemp)
  
  # Read the existing file content (except the closing brace)
  cat "$L10N_DIR/app_$lang.arb" | grep -v "}" > "$TEMP_FILE"
  
  # Append a comma if the last line doesn't end with one
  LAST_CHAR=$(tail -c 2 "$TEMP_FILE")
  if [[ "$LAST_CHAR" != "," && "$LAST_CHAR" != "{" ]]; then
    echo "," >> "$TEMP_FILE"
  fi
  
  # Add the achievement translations based on language
  case $lang in
    "en")
      cat << 'EOF' >> "$TEMP_FILE"
  "achievementFirstStep": "First Step",
  "achievementFirstStepDescription": "Complete the onboarding process",
  "achievementOneDayWonder": "One Day Wonder",
  "achievementOneDayWonderDescription": "Stay smoke-free for 1 day",
  "achievementWeekWarrior": "Week Warrior",
  "achievementWeekWarriorDescription": "Stay smoke-free for 7 days",
  "achievementMonthMaster": "Month Master",
  "achievementMonthMasterDescription": "Stay smoke-free for 30 days",
  "achievementMoneyMindful": "Money Mindful",
  "achievementMoneyMindfulDescription": "Save $50 by not smoking",
  "achievementCenturion": "Centurion",
  "achievementCenturionDescription": "Save $100 by not smoking",
  "achievementCravingCrusher": "Craving Crusher",
  "achievementCravingCrusherDescription": "Successfully resist 10 cravings"
EOF
      ;;
    "pt")
      cat << 'EOF' >> "$TEMP_FILE"
  "achievementFirstStep": "Primeiro Passo",
  "achievementFirstStepDescription": "Complete o processo de introdução",
  "achievementOneDayWonder": "Maravilha de Um Dia",
  "achievementOneDayWonderDescription": "Fique sem fumar por 1 dia",
  "achievementWeekWarrior": "Guerreiro da Semana",
  "achievementWeekWarriorDescription": "Fique sem fumar por 7 dias",
  "achievementMonthMaster": "Mestre do Mês",
  "achievementMonthMasterDescription": "Fique sem fumar por 30 dias",
  "achievementMoneyMindful": "Consciente Financeiro",
  "achievementMoneyMindfulDescription": "Economize R$50 não fumando",
  "achievementCenturion": "Centurião",
  "achievementCenturionDescription": "Economize R$100 não fumando",
  "achievementCravingCrusher": "Destruidor de Desejos",
  "achievementCravingCrusherDescription": "Resista com sucesso a 10 desejos de fumar"
EOF
      ;;
    "es")
      cat << 'EOF' >> "$TEMP_FILE"
  "achievementFirstStep": "Primer Paso",
  "achievementFirstStepDescription": "Completa el proceso de iniciación",
  "achievementOneDayWonder": "Maravilla de Un Día",
  "achievementOneDayWonderDescription": "Mantente sin fumar por 1 día",
  "achievementWeekWarrior": "Guerrero de la Semana",
  "achievementWeekWarriorDescription": "Mantente sin fumar por 7 días",
  "achievementMonthMaster": "Maestro del Mes",
  "achievementMonthMasterDescription": "Mantente sin fumar por 30 días",
  "achievementMoneyMindful": "Consciente Financiero",
  "achievementMoneyMindfulDescription": "Ahorra €50 al no fumar",
  "achievementCenturion": "Centurión",
  "achievementCenturionDescription": "Ahorra €100 al no fumar",
  "achievementCravingCrusher": "Aplastador de Antojos",
  "achievementCravingCrusherDescription": "Resiste con éxito 10 antojos de fumar"
EOF
      ;;
    "fr")
      cat << 'EOF' >> "$TEMP_FILE"
  "achievementFirstStep": "Premier Pas",
  "achievementFirstStepDescription": "Complétez le processus d'intégration",
  "achievementOneDayWonder": "Merveille d'un Jour",
  "achievementOneDayWonderDescription": "Restez sans fumer pendant 1 jour",
  "achievementWeekWarrior": "Guerrier de la Semaine",
  "achievementWeekWarriorDescription": "Restez sans fumer pendant 7 jours",
  "achievementMonthMaster": "Maître du Mois",
  "achievementMonthMasterDescription": "Restez sans fumer pendant 30 jours",
  "achievementMoneyMindful": "Conscience Financière",
  "achievementMoneyMindfulDescription": "Économisez 50€ en ne fumant pas",
  "achievementCenturion": "Centurion",
  "achievementCenturionDescription": "Économisez 100€ en ne fumant pas",
  "achievementCravingCrusher": "Destructeur d'Envies",
  "achievementCravingCrusherDescription": "Résistez avec succès à 10 envies de fumer"
EOF
      ;;
    "it")
      cat << 'EOF' >> "$TEMP_FILE"
  "achievementFirstStep": "Primo Passo",
  "achievementFirstStepDescription": "Completa il processo di onboarding",
  "achievementOneDayWonder": "Meraviglia di un Giorno",
  "achievementOneDayWonderDescription": "Rimani senza fumare per 1 giorno",
  "achievementWeekWarrior": "Guerriero della Settimana",
  "achievementWeekWarriorDescription": "Rimani senza fumare per 7 giorni",
  "achievementMonthMaster": "Maestro del Mese",
  "achievementMonthMasterDescription": "Rimani senza fumare per 30 giorni",
  "achievementMoneyMindful": "Consapevolezza Finanziaria",
  "achievementMoneyMindfulDescription": "Risparmia 50€ non fumando",
  "achievementCenturion": "Centurione",
  "achievementCenturionDescription": "Risparmia 100€ non fumando",
  "achievementCravingCrusher": "Distruttore di Voglie",
  "achievementCravingCrusherDescription": "Resisti con successo a 10 voglie di fumare"
EOF
      ;;
    "de")
      cat << 'EOF' >> "$TEMP_FILE"
  "achievementFirstStep": "Erster Schritt",
  "achievementFirstStepDescription": "Schließe den Einführungsprozess ab",
  "achievementOneDayWonder": "Ein-Tages-Wunder",
  "achievementOneDayWonderDescription": "Bleibe einen Tag rauchfrei",
  "achievementWeekWarrior": "Wochen-Krieger",
  "achievementWeekWarriorDescription": "Bleibe 7 Tage rauchfrei",
  "achievementMonthMaster": "Monats-Meister",
  "achievementMonthMasterDescription": "Bleibe 30 Tage rauchfrei",
  "achievementMoneyMindful": "Finanzbewusst",
  "achievementMoneyMindfulDescription": "Spare 50€ durch Nichtrauchen",
  "achievementCenturion": "Zenturio",
  "achievementCenturionDescription": "Spare 100€ durch Nichtrauchen",
  "achievementCravingCrusher": "Gelüstbezwinger",
  "achievementCravingCrusherDescription": "Widerstehe erfolgreich 10 Rauchgelüsten"
EOF
      ;;
    "nl")
      cat << 'EOF' >> "$TEMP_FILE"
  "achievementFirstStep": "Eerste Stap",
  "achievementFirstStepDescription": "Voltooi het introductieproces",
  "achievementOneDayWonder": "Eendags Wonder",
  "achievementOneDayWonderDescription": "Blijf 1 dag rookvrij",
  "achievementWeekWarrior": "Weekstrijder",
  "achievementWeekWarriorDescription": "Blijf 7 dagen rookvrij",
  "achievementMonthMaster": "Maand Meester",
  "achievementMonthMasterDescription": "Blijf 30 dagen rookvrij",
  "achievementMoneyMindful": "Geldbewust",
  "achievementMoneyMindfulDescription": "Bespaar €50 door niet te roken",
  "achievementCenturion": "Centurion",
  "achievementCenturionDescription": "Bespaar €100 door niet te roken",
  "achievementCravingCrusher": "Verlangensverslager",
  "achievementCravingCrusherDescription": "Weersta succesvol 10 rookverleidingen"
EOF
      ;;
    "pl")
      cat << 'EOF' >> "$TEMP_FILE"
  "achievementFirstStep": "Pierwszy Krok",
  "achievementFirstStepDescription": "Ukończ proces wprowadzający",
  "achievementOneDayWonder": "Jednodniowy Cud",
  "achievementOneDayWonderDescription": "Nie pal przez 1 dzień",
  "achievementWeekWarrior": "Tygodniowy Wojownik",
  "achievementWeekWarriorDescription": "Nie pal przez 7 dni",
  "achievementMonthMaster": "Miesięczny Mistrz",
  "achievementMonthMasterDescription": "Nie pal przez 30 dni",
  "achievementMoneyMindful": "Świadomość Finansowa",
  "achievementMoneyMindfulDescription": "Zaoszczędź 50 zł nie paląc",
  "achievementCenturion": "Centurion",
  "achievementCenturionDescription": "Zaoszczędź 100 zł nie paląc",
  "achievementCravingCrusher": "Pogromca Zachcianek",
  "achievementCravingCrusherDescription": "Skutecznie oprzyj się 10 zachciankom palenia"
EOF
      ;;
  esac
  
  # Close the JSON object
  echo "}" >> "$TEMP_FILE"
  
  # Replace the original file
  mv "$TEMP_FILE" "$L10N_DIR/app_$lang.arb"
  
  echo "✅ Completed $lang translations"
done

echo "All translations added successfully!"
echo "Don't forget to run 'flutter gen-l10n' to update the generated files."