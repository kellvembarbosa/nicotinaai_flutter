const fs = require('fs');
const path = require('path');

const ARB_DIR = path.join(__dirname, 'assets', 'l10n');
const ENGLISH_ARB = path.join(ARB_DIR, 'app_en.arb');
const LANGUAGES = ['fr', 'it', 'de', 'nl', 'pl', 'es', 'pt'];

// Load English ARB as reference
const englishArb = JSON.parse(fs.readFileSync(ENGLISH_ARB, 'utf8'));
const englishKeys = Object.keys(englishArb)
  .filter(key => !key.startsWith('@') && key !== '@@locale');

console.log(`English has ${englishKeys.length} translation keys`);

// Check each language
LANGUAGES.forEach(lang => {
  const arbPath = path.join(ARB_DIR, `app_${lang}.arb`);
  try {
    const arbData = JSON.parse(fs.readFileSync(arbPath, 'utf8'));
    const langKeys = Object.keys(arbData)
      .filter(key => !key.startsWith('@') && key !== '@@locale');
    
    // Find keys in English but not in this language
    const missingKeys = englishKeys.filter(key => !langKeys.includes(key));
    
    // Find keys in this language but not in English (obsolete)
    const extraKeys = langKeys.filter(key => !englishKeys.includes(key));
    
    console.log(`${lang.toUpperCase()}: ${langKeys.length} keys, ${missingKeys.length} missing, ${extraKeys.length} extra`);
    
    if (missingKeys.length > 0) {
      console.log(`  Missing keys: ${missingKeys.slice(0, 5).join(', ')}${missingKeys.length > 5 ? '...' : ''}`);
    }
    
    if (extraKeys.length > 0) {
      console.log(`  Extra keys: ${extraKeys.slice(0, 5).join(', ')}${extraKeys.length > 5 ? '...' : ''}`);
    }
    
    // Check for placeholders in English that might be missing in translations
    const placeholderIssues = [];
    englishKeys.forEach(key => {
      if (arbData[key] && englishArb[key]) {
        const englishPlaceholders = (englishArb[key].match(/\{[^}]+\}/g) || []);
        const translatedPlaceholders = (arbData[key].match(/\{[^}]+\}/g) || []);
        
        // Check if translation is missing any placeholders that exist in English
        const missingPlaceholders = englishPlaceholders.filter(
          ph => !translatedPlaceholders.includes(ph)
        );
        
        if (missingPlaceholders.length > 0) {
          placeholderIssues.push({
            key,
            missingPlaceholders
          });
        }
      }
    });
    
    if (placeholderIssues.length > 0) {
      console.log(`  Found ${placeholderIssues.length} strings with missing placeholders`);
      placeholderIssues.slice(0, 3).forEach(issue => {
        console.log(`    ${issue.key}: missing ${issue.missingPlaceholders.join(', ')}`);
      });
      if (placeholderIssues.length > 3) {
        console.log('    ...');
      }
    }
    
  } catch (error) {
    console.error(`Error checking ${lang}:`, error.message);
  }
});
