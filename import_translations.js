const fs = require('fs');
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
  console.error(`CSV file not found: ${csvFile}`);
  process.exit(1);
}

const taskFile = path.join(__dirname, 'translation_tasks', `translation_task_${language}.json`);
if (!fs.existsSync(taskFile)) {
  console.error(`Task file not found: ${taskFile}`);
  process.exit(1);
}

// Load task data
const taskData = JSON.parse(fs.readFileSync(taskFile, 'utf8'));

// Parse CSV
const csvContent = fs.readFileSync(csvFile, 'utf8');
const lines = csvContent.split('\n');
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
console.log(`Updated ${updatedCount} translations in task file`);

// Apply to ARB file
const arbPath = path.join(__dirname, 'assets', 'l10n', `app_${language}.arb`);
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
console.log(`Updated ${language} translations in ARB file`);

// Update untranslated messages file
const untranslatedFile = path.join(__dirname, 'untranslated_messages.json');
const untranslated = JSON.parse(fs.readFileSync(untranslatedFile, 'utf8'));
untranslated[language] = Object.keys(taskData.translations)
  .filter(key => !taskData.translations[key].translation || 
              taskData.translations[key].translation.trim() === '');
fs.writeFileSync(untranslatedFile, JSON.stringify(untranslated, null, 2));
console.log(`Updated untranslated messages for ${language}`);
