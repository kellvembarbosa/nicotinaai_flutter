# Guia de Internacionalização (i18n) - NicotinaAI

Este documento descreve como usar e manter o sistema de internacionalização (i18n) do aplicativo NicotinaAI.

## Estrutura

O aplicativo usa o sistema de internacionalização integrado do Flutter (flutter_localizations) junto com o pacote `intl` para gerenciar traduções.

### Arquivos e pastas importantes:

- `lib/core/localization/locale_provider.dart` - Provedor para gerenciar o idioma do aplicativo
- `assets/l10n/` - Diretório contendo arquivos de tradução
  - `app_pt.arb` - Arquivo de tradução para Português (Brasil)
  - `app_en.arb` - Arquivo de tradução para Inglês (EUA)
- `l10n.yaml` - Arquivo de configuração para o gerador do Flutter

## Como Usar

### 1. Acessando traduções nos widgets

Para usar textos traduzidos em qualquer widget, primeiro importe:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

Então, dentro do método `build`:

```dart
// Obtenha a instância de AppLocalizations para o contexto atual
final localizations = AppLocalizations.of(context);

// Use as strings traduzidas
Text(localizations.settings)
```

### 2. Adicionando novas strings

Para adicionar novas strings ao sistema de internacionalização:

1. Adicione a string no arquivo base `assets/l10n/app_pt.arb`:

```json
"minhaNovaChave": "Meu texto em português",
"@minhaNovaChave": {
  "description": "Descrição para tradutores"
}
```

2. Adicione a mesma chave com a tradução correspondente em `assets/l10n/app_en.arb`:

```json
"minhaNovaChave": "My text in English",
"@minhaNovaChave": {
  "description": "Descrição para tradutores"
}
```

3. Execute o comando para regenerar os arquivos de localização:

```bash
flutter gen-l10n
```

### 3. Parâmetros em Strings

Para strings que precisam de parâmetros dinâmicos:

```json
"bemVindo": "Olá, {nome}!",
"@bemVindo": {
  "description": "Mensagem de boas-vindas",
  "placeholders": {
    "nome": {
      "type": "String",
      "example": "João"
    }
  }
}
```

Uso:
```dart
Text(localizations.bemVindo('João'))
```

### 4. Plurais

Para strings que mudam com base em quantidades:

```json
"macos": "{quantidade, plural, =0{Nenhum maço} =1{1 maço} other{{quantidade} maços}}",
"@macos": {
  "description": "Quantidade de maços",
  "placeholders": {
    "quantidade": {
      "type": "num",
      "format": "compact"
    }
  }
}
```

### 5. Alterando o idioma do aplicativo

O idioma do aplicativo pode ser alterado usando o `LocaleProvider`:

```dart
final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
localeProvider.setLocale(const Locale('en', 'US')); // Muda para inglês
```

O idioma é automaticamente salvo usando `SharedPreferences` e persistido entre sessões.

## Adicionando novos idiomas

Para adicionar um novo idioma:

1. Crie um novo arquivo ARB na pasta `assets/l10n/` seguindo a convenção `app_<código_idioma>.arb` (ex: `app_es.arb` para espanhol)

2. Copie todas as chaves do arquivo `app_pt.arb` e traduza os valores

3. Adicione o novo idioma na lista de idiomas suportados em `lib/core/localization/locale_provider.dart`:

```dart
List<Locale> get supportedLocales => const [
  Locale('pt', 'BR'), // Português (Brasil)
  Locale('en', 'US'), // Inglês (EUA)
  Locale('es', 'ES'), // Espanhol (adicionar esta linha)
];
```

4. Adicione também o nome do idioma no método `getLanguageName`:

```dart
String getLanguageName(Locale locale) {
  switch ('${locale.languageCode}_${locale.countryCode}') {
    case 'pt_BR':
      return 'Português (Brasil)';
    case 'en_US':
      return 'English (US)';
    case 'es_ES':
      return 'Español';  // adicionar esta linha
    default:
      return 'Unknown';
  }
}
```

5. Execute `flutter gen-l10n` para atualizar os arquivos gerados

## Boas práticas

1. **Use chaves descritivas**: Prefira `loginButton` ao invés de apenas `login`
2. **Adicione descrições**: Sempre forneça descrições claras para ajudar tradutores
3. **Evite concatenações**: Use placeholders em vez de concatenar strings
4. **Mantenha organização**: Agrupe strings relacionadas com prefixos comuns
5. **Teste cada idioma**: Sempre verifique como o layout se comporta em todos os idiomas

## Solução de problemas

* Se as traduções não aparecerem, verifique se `AppLocalizations.delegate` está corretamente adicionado ao `localizationsDelegates` no MaterialApp
* Para forçar a regeneração dos arquivos, exclua a pasta `.dart_tool/flutter_gen` e execute `flutter clean` seguido de `flutter pub get`
* Se estiver adicionando idiomas com scripts complexos (árabe, chinês, etc.), certifique-se de que as fontes utilizadas suportam esses caracteres