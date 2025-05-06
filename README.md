# NicotinaAI Flutter

Um aplicativo Flutter para ajudar pessoas a parar de fumar através de um sistema personalizado de acompanhamento e recompensas.

## Sobre o Projeto

NicotinaAI é uma plataforma que utiliza inteligência artificial para criar planos personalizados que ajudam usuários a reduzir e eventualmente eliminar o consumo de tabaco. O aplicativo acompanha o progresso do usuário, fornece motivação e calcula economias financeiras e benefícios à saúde.

## Funcionalidades

- Onboarding personalizado com várias etapas
- Autenticação segura
- Acompanhamento de progresso
- Sistema de conquistas
- Personalização de objetivos
- Tema claro e escuro

## Tecnologias Utilizadas

- Flutter
- Dart
- Supabase para backend e autenticação
- Provider para gerenciamento de estado

## Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/nicotinaai_flutter.git

# Entre na pasta do projeto
cd nicotinaai_flutter

# Instale as dependências
flutter pub get

# Execute o aplicativo
flutter run
```

## Estrutura do Projeto

```
lib/
├── config/         # Configurações como Supabase
├── core/           # Código central (rotas, temas, constantes)
├── features/       # Recursos organizados por domínio
│   ├── auth/       # Autenticação
│   ├── home/       # Tela principal
│   ├── onboarding/ # Processo de introdução
│   └── settings/   # Configurações
├── services/       # Serviços compartilhados
└── widgets/        # Widgets reutilizáveis
```

## Contribuição

Contribuições são bem-vindas! Por favor, siga estas etapas:

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo LICENSE para detalhes.