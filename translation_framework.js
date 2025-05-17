const fs = require('fs');
const path = require('path');

// Constants
const ARB_DIR = path.join(__dirname, 'assets', 'l10n');
const UNTRANSLATED_FILE = path.join(__dirname, 'untranslated_messages.json');
const ENGLISH_ARB = path.join(ARB_DIR, 'app_en.arb');
const OUTPUT_DIR = path.join(__dirname, 'translation_tasks');
const LANGUAGES = ['fr', 'it', 'de', 'nl', 'pl']; // Target languages

// Ensure output directory exists
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

/**
 * Loads and parses an ARB file
 * @param {string} filePath - Path to the ARB file
 * @returns {Object} - Parsed ARB content
 */
function loadArbFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    console.error(`Error loading ARB file ${filePath}:`, error.message);
    return {};
  }
}

/**
 * Loads untranslated messages
 * @returns {Object} - Untranslated messages by language
 */
function loadUntranslatedMessages() {
  try {
    const content = fs.readFileSync(UNTRANSLATED_FILE, 'utf8');
    return JSON.parse(content);
  } catch (error) {
    console.error('Error loading untranslated messages:', error.message);
    return {};
  }
}

/**
 * Extracts translation keys and metadata from English ARB
 * @returns {Object} - Keys, descriptions, and placeholders
 */
function extractTranslationKeysAndMetadata() {
  const englishArb = loadArbFile(ENGLISH_ARB);
  const keys = Object.keys(englishArb).filter(key => !key.startsWith('@') && key !== '@@locale');
  
  const metadata = {};
  keys.forEach(key => {
    const metaKey = `@${key}`;
    if (englishArb[metaKey]) {
      metadata[key] = englishArb[metaKey];
    }
  });
  
  return {
    keys,
    metadata,
    englishStrings: keys.reduce((acc, key) => {
      acc[key] = englishArb[key];
      return acc;
    }, {})
  };
}

/**
 * Creates translation tasks for each language
 * @param {Object} translationData - Keys, metadata, and English strings
 */
function createTranslationTasks(translationData) {
  const { keys, metadata, englishStrings } = translationData;
  const untranslatedMessages = loadUntranslatedMessages();
  
  LANGUAGES.forEach(lang => {
    const arbPath = path.join(ARB_DIR, `app_${lang}.arb`);
    const existing = loadArbFile(arbPath);
    const untranslatedKeys = untranslatedMessages[lang] || [];
    
    // Create translation task structure
    const taskData = {
      language: lang,
      translatedCount: 0,
      untranslatedCount: 0,
      translations: {}
    };
    
    keys.forEach(key => {
      const isUntranslated = untranslatedKeys.includes(key);
      const hasExistingTranslation = existing[key] && existing[key] !== englishStrings[key];
      
      taskData.translations[key] = {
        english: englishStrings[key],
        current: existing[key] || '',
        needsTranslation: isUntranslated || !hasExistingTranslation,
        description: metadata[key]?.description || '',
        placeholders: metadata[key]?.placeholders || null
      };
      
      if (taskData.translations[key].needsTranslation) {
        taskData.untranslatedCount++;
      } else {
        taskData.translatedCount++;
      }
    });
    
    // Save translation task
    const taskFile = path.join(OUTPUT_DIR, `translation_task_${lang}.json`);
    fs.writeFileSync(taskFile, JSON.stringify(taskData, null, 2));
    
    console.log(`${lang.toUpperCase()}: ${taskData.translatedCount} translated, ${taskData.untranslatedCount} untranslated`);
    
    // Create template CSV for easy translation
    const csvLines = ['key,english,translation,description'];
    keys.filter(key => taskData.translations[key].needsTranslation)
      .forEach(key => {
        const item = taskData.translations[key];
        const english = item.english.replace(/"/g, '""');
        const description = (item.description || '').replace(/"/g, '""');
        csvLines.push(`"${key}","${english}","","${description}"`);
      });
    
    const csvFile = path.join(OUTPUT_DIR, `translation_template_${lang}.csv`);
    fs.writeFileSync(csvFile, csvLines.join('\n'));
  });
}

/**
 * Applies translations from a completed task back to ARB file
 * @param {string} language - Language code
 * @param {string} taskFile - Path to the completed task file
 */
function applyTranslations(language, taskFile) {
  try {
    const taskData = JSON.parse(fs.readFileSync(taskFile, 'utf8'));
    const arbPath = path.join(ARB_DIR, `app_${language}.arb`);
    const existing = loadArbFile(arbPath);
    
    // Update existing ARB with new translations
    const updated = { 
      ...existing,
      "@@locale": language
    };
    
    Object.entries(taskData.translations).forEach(([key, data]) => {
      if (data.translation && data.translation.trim() !== '') {
        updated[key] = data.translation;
      }
    });
    
    // Write back to ARB file
    fs.writeFileSync(arbPath, JSON.stringify(updated, null, 2));
    console.log(`Updated ${language} translations`);
    
    // Update untranslated messages
    updateUntranslatedMessages(language, Object.keys(taskData.translations)
      .filter(key => !taskData.translations[key].translation));
    
  } catch (error) {
    console.error(`Error applying translations for ${language}:`, error.message);
  }
}

/**
 * Updates the untranslated_messages.json file
 * @param {string} language - Language code
 * @param {Array} untranslatedKeys - List of untranslated keys
 */
function updateUntranslatedMessages(language, untranslatedKeys) {
  try {
    const untranslated = loadUntranslatedMessages();
    untranslated[language] = untranslatedKeys;
    fs.writeFileSync(UNTRANSLATED_FILE, JSON.stringify(untranslated, null, 2));
    console.log(`Updated untranslated messages for ${language}`);
  } catch (error) {
    console.error('Error updating untranslated messages:', error.message);
  }
}

/**
 * Creates a script to import CSV translations
 */
function createImportScript() {
  const scriptContent = `const fs = require('fs');
const path = require('path');

// Usage: node import_translations.js language csv_file
// Example: node import_translations.js fr completed_fr.csv

if (process.argv.length < 4) {
  console.error('Usage: node import_translations.js language csv_file');
  process.exit(1);
}

const language = process.argv[2];
const csvFile = process.argv[3];

if (!fs.existsSync(csvFile)) {
  console.error(\`CSV file not found: \${csvFile}\`);
  process.exit(1);
}

const taskFile = path.join(__dirname, 'translation_tasks', \`translation_task_\${language}.json\`);
if (!fs.existsSync(taskFile)) {
  console.error(\`Task file not found: \${taskFile}\`);
  process.exit(1);
}

// Load task data
const taskData = JSON.parse(fs.readFileSync(taskFile, 'utf8'));

// Parse CSV
const csvContent = fs.readFileSync(csvFile, 'utf8');
const lines = csvContent.split('\\n');
const header = lines[0].split(',');
const keyIndex = header.indexOf('key');
const translationIndex = header.indexOf('translation');

if (keyIndex === -1 || translationIndex === -1) {
  console.error('CSV must contain "key" and "translation" columns');
  process.exit(1);
}

// Process translations
let updatedCount = 0;
for (let i = 1; i < lines.length; i++) {
  if (!lines[i].trim()) continue;
  
  // Handle quoted CSV properly
  const row = lines[i].match(/(?:^|,)("(?:[^"]*(?:""[^"]*)*)"|[^,]*)/g)
    .map(value => value.startsWith(',') ? value.substring(1) : value)
    .map(value => value.startsWith('"') && value.endsWith('"') 
      ? value.substring(1, value.length - 1).replace(/""/g, '"') 
      : value);
  
  const key = row[keyIndex];
  const translation = row[translationIndex];
  
  if (key && translation && taskData.translations[key]) {
    taskData.translations[key].translation = translation;
    updatedCount++;
  }
}

// Save updated task data
fs.writeFileSync(taskFile, JSON.stringify(taskData, null, 2));
console.log(\`Updated \${updatedCount} translations in task file\`);

// Apply to ARB file
const arbPath = path.join(__dirname, 'assets', 'l10n', \`app_\${language}.arb\`);
const existing = JSON.parse(fs.readFileSync(arbPath, 'utf8'));

// Update existing ARB with new translations
const updated = { 
  ...existing,
  "@@locale": language
};

Object.entries(taskData.translations).forEach(([key, data]) => {
  if (data.translation && data.translation.trim() !== '') {
    updated[key] = data.translation;
  }
});

// Write back to ARB file
fs.writeFileSync(arbPath, JSON.stringify(updated, null, 2));
console.log(\`Updated \${language} translations in ARB file\`);

// Update untranslated messages file
const untranslatedFile = path.join(__dirname, 'untranslated_messages.json');
const untranslated = JSON.parse(fs.readFileSync(untranslatedFile, 'utf8'));
untranslated[language] = Object.keys(taskData.translations)
  .filter(key => !taskData.translations[key].translation || 
              taskData.translations[key].translation.trim() === '');
fs.writeFileSync(untranslatedFile, JSON.stringify(untranslated, null, 2));
console.log(\`Updated untranslated messages for \${language}\`);
`;

  fs.writeFileSync(path.join(__dirname, 'import_translations.js'), scriptContent);
  console.log('Created import_translations.js script');
}

/**
 * Creates a validation script
 */
function createValidationScript() {
  const scriptContent = `const fs = require('fs');
const path = require('path');

const ARB_DIR = path.join(__dirname, 'assets', 'l10n');
const ENGLISH_ARB = path.join(ARB_DIR, 'app_en.arb');
const LANGUAGES = ['fr', 'it', 'de', 'nl', 'pl', 'es', 'pt'];

// Load English ARB as reference
const englishArb = JSON.parse(fs.readFileSync(ENGLISH_ARB, 'utf8'));
const englishKeys = Object.keys(englishArb)
  .filter(key => !key.startsWith('@') && key !== '@@locale');

console.log(\`English has \${englishKeys.length} translation keys\`);

// Check each language
LANGUAGES.forEach(lang => {
  const arbPath = path.join(ARB_DIR, \`app_\${lang}.arb\`);
  try {
    const arbData = JSON.parse(fs.readFileSync(arbPath, 'utf8'));
    const langKeys = Object.keys(arbData)
      .filter(key => !key.startsWith('@') && key !== '@@locale');
    
    // Find keys in English but not in this language
    const missingKeys = englishKeys.filter(key => !langKeys.includes(key));
    
    // Find keys in this language but not in English (obsolete)
    const extraKeys = langKeys.filter(key => !englishKeys.includes(key));
    
    console.log(\`\${lang.toUpperCase()}: \${langKeys.length} keys, \${missingKeys.length} missing, \${extraKeys.length} extra\`);
    
    if (missingKeys.length > 0) {
      console.log(\`  Missing keys: \${missingKeys.slice(0, 5).join(', ')}\${missingKeys.length > 5 ? '...' : ''}\`);
    }
    
    if (extraKeys.length > 0) {
      console.log(\`  Extra keys: \${extraKeys.slice(0, 5).join(', ')}\${extraKeys.length > 5 ? '...' : ''}\`);
    }
    
    // Check for placeholders in English that might be missing in translations
    const placeholderIssues = [];
    englishKeys.forEach(key => {
      if (arbData[key] && englishArb[key]) {
        const englishPlaceholders = (englishArb[key].match(/\\{[^}]+\\}/g) || []);
        const translatedPlaceholders = (arbData[key].match(/\\{[^}]+\\}/g) || []);
        
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
      console.log(\`  Found \${placeholderIssues.length} strings with missing placeholders\`);
      placeholderIssues.slice(0, 3).forEach(issue => {
        console.log(\`    \${issue.key}: missing \${issue.missingPlaceholders.join(', ')}\`);
      });
      if (placeholderIssues.length > 3) {
        console.log('    ...');
      }
    }
    
  } catch (error) {
    console.error(\`Error checking \${lang}:\`, error.message);
  }
});
`;

  fs.writeFileSync(path.join(__dirname, 'validate_translations.js'), scriptContent);
  console.log('Created validate_translations.js script');
}

/**
 * Main function
 */
function main() {
  console.log('NicotinaAI Translation Framework');
  console.log('===============================');
  
  // Extract translation keys and metadata
  console.log('Extracting translation keys and metadata...');
  const translationData = extractTranslationKeysAndMetadata();
  console.log(`Found ${translationData.keys.length} translation keys in English ARB`);
  
  // Create translation tasks
  console.log('\nCreating translation tasks for each language:');
  createTranslationTasks(translationData);
  
  // Create import script
  createImportScript();
  
  // Create validation script
  createValidationScript();
  
  console.log('\nTranslation framework setup complete!');
  console.log(`Translation tasks and templates created in: ${OUTPUT_DIR}`);
  console.log('\nWorkflow:');
  console.log('1. Find the CSV templates in the translation_tasks directory');
  console.log('2. Fill in the translations for each language');
  console.log('3. Import completed translations with: node import_translations.js LANG CSV_FILE');
  console.log('4. Validate all translations with: node validate_translations.js');
}

// Run the script
main();