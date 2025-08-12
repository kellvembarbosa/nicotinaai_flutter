# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NicotinaAI is a Flutter app that helps people quit smoking through personalized tracking, achievements, and AI-powered motivation. It uses Supabase as the backend for authentication, database, and edge functions, with comprehensive analytics and monetization through RevenueCat and Superwall.

## Architecture

### State Management - BLoC Pattern
- **Primary Pattern**: Flutter BLoC for all state management
- **Structure**: Each feature has `bloc.dart`, `event.dart`, and `state.dart` files
- **Observer**: `AppBlocObserver` provides comprehensive debugging logs
- **Key BLoCs**: 
  - `AuthBloc`: User authentication state
  - `TrackingBloc`: Smoking records and cravings
  - `AchievementBloc`: User achievements and notifications
  - `OnboardingBloc`: Multi-step onboarding process
  - `ThemeBloc`, `LocaleBloc`, `CurrencyBloc`: App preferences

### Navigation
- **Router**: go_router with `AppRouter` class handling authentication-based redirection
- **Route Protection**: Automatic redirects based on auth and onboarding completion
- **Structure**: Routes defined in `core/routes/app_routes.dart`

### Feature Organization
```
lib/features/
├── auth/           # Authentication screens and logic
├── onboarding/     # Multi-step user onboarding
├── home/          # Main dashboard and smoking tracking
├── achievements/  # Achievement system
├── settings/      # User preferences and configuration
└── tracking/      # Statistics and health recovery tracking
```

### Backend Integration
- **Database**: Supabase PostgreSQL with comprehensive RLS policies
- **Authentication**: Supabase Auth with session management
- **Edge Functions**: TypeScript functions in `supabase/functions/`
- **Real-time**: Supabase real-time subscriptions for live data
- **Migrations**: SQL migrations in `supabase/migrations/`

### Analytics & Monetization
- **Analytics**: Multi-adapter system supporting PostHog, Facebook, and Superwall
- **Subscriptions**: RevenueCat integration with Superwall paywall
- **Notifications**: Firebase Cloud Messaging with local notifications

## Common Development Commands

### Flutter Development
```bash
# Install dependencies (NEVER edit pubspec.yaml manually)
flutter pub get

# Clean build cache
flutter clean

# Generate code (localizations, etc.)
flutter gen-l10n

# Build for different platforms
flutter build apk --release          # Android APK
flutter build ios --release          # iOS
flutter build web                    # Web

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

### Database & Supabase
```bash
# Link to Supabase project
supabase link --project-ref <project-ref>

# Generate TypeScript types
supabase gen types typescript --local > lib/types/database.dart

# Run migrations
supabase db push

# Deploy edge functions
supabase functions deploy <function-name>

# View logs
supabase functions logs <function-name>
```

## Key Implementation Patterns

### BLoC Implementation
- All events extend `Equatable` for proper comparison
- States follow loading -> success/error pattern
- Repository pattern for data access
- Dependency injection through BLoC constructors

### Localization
- ARB files in `assets/l10n/` for 9 languages
- Generated localizations in `lib/l10n/`
- LocaleBloc manages language selection and preferences

### Repository Pattern
- Each feature has its own repository (AuthRepository, TrackingRepository, etc.)
- Repositories handle Supabase client interactions
- Comprehensive error handling with custom exceptions

### Testing Strategy
- BLoC testing with `bloc_test` package
- Repository mocking with `mockito`
- Widget testing for UI components

## Environment Setup

### Required Files
- `.env` file with Supabase credentials and API keys
- `GoogleService-Info.plist` for iOS Firebase
- `google-services.json` for Android Firebase

### Key Environment Variables
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

## Database Schema

The app uses a comprehensive PostgreSQL schema with:
- User onboarding data with enums for preferences
- Smoking logs and craving records with timestamps
- Achievement system with triggers and notifications
- Health recovery milestones with time-based calculations
- User feedback and analytics events

## Security Considerations

- Row Level Security (RLS) enabled on all tables
- User data isolated by `auth.users.id`
- API keys stored in environment variables
- Secure authentication flow with session management
- Input validation on both client and server side

## Performance Optimizations

- BLoC state management prevents unnecessary rebuilds
- Skeleton loading states for better UX
- Optimistic updates for immediate feedback
- Lazy loading for large datasets
- Image optimization and caching

## Debugging

- Comprehensive BLoC logging via `AppBlocObserver`
- Supabase debug mode enabled in development
- Analytics event tracking for user behavior
- Error handling with detailed stack traces
- Database diagnostic tools for troubleshooting