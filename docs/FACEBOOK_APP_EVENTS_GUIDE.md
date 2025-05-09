# Facebook App Events and App Tracking Implementation Guide

This document provides details on how Facebook App Events and App Tracking Transparency have been implemented in the NicotinaAI app.

## Overview

We have implemented Facebook App Events to track user behaviors and optimize our app's performance and user experience. App Tracking Transparency (ATT) is implemented for iOS to comply with Apple's privacy requirements.

## Setup Details

### Facebook App Configuration
- **App ID**: 1122057663011514
- **Client Token**: 5c322aa391bc253b88122690a80aec2e
- **App Name**: Nicotina.AI

### Packages Used
- `facebook_app_events`: For Facebook SDK integration and event tracking
- `app_tracking_transparency`: For requesting tracking permission on iOS devices

## Key Files

1. **AnalyticsService**: `/lib/services/analytics_service.dart`
   - Centralized service for handling all analytics events
   - Manages tracking permissions and consent
   - Provides methods for standard and custom events

2. **Main**: `/lib/main.dart`
   - Initializes the AnalyticsService during app startup
   - Logs app_open event on initialization

3. **AuthProvider**: `/lib/features/auth/providers/auth_provider.dart`
   - Tracks login and signup events
   - Sets user properties
   - Clears user data on logout

4. **OnboardingProvider**: `/lib/features/onboarding/providers/onboarding_provider.dart`
   - Tracks onboarding completion
   - Records user settings like cigarettes per day and price per pack

5. **TrackingProvider**: `/lib/features/tracking/providers/tracking_provider.dart`
   - Tracks health recovery achievements
   - Records craving resistance events
   - Updates user smoking streak properties

## iOS Configuration

iOS-specific configuration in `ios/Runner/Info.plist`:
- Facebook App ID and Client Token configuration
- ATT privacy message: "This identifier will be used to deliver personalized ads and content to you and help improve the app."

## Android Configuration

Android-specific configuration in `android/app/src/main/AndroidManifest.xml`:
- Facebook App ID and Client Token metadata
- Added AD_ID permission for advertising ID access

## Tracked Events

The AnalyticsService tracks the following events:

### Standard Events
- `app_open`: Logged when the app is launched
- `login`: When a user logs in
- `sign_up`: When a user registers a new account
- `completed_onboarding`: When a user completes the onboarding process

### Custom Events
- `smoking_free_milestone`: When user reaches key days without smoking (1, 7, 30, etc.)
- `health_recovery_achieved`: When a health recovery milestone is reached
- `craving_resisted`: When user records resisting a craving
- `money_saved_milestone`: For significant money savings achievements
- `feature_used`: To track usage of specific app features

## User Properties

The following user properties are tracked:
- User ID (anonymized)
- Email (for targeting, if provided)
- Days smoke-free
- Cigarettes per day (from onboarding)
- Price per pack (from onboarding)
- Currency (user preference)

## App Tracking Transparency

On iOS devices, the app requests tracking permission using the ATT framework:
1. Permission request shows on first launch
2. The user can choose to allow or deny tracking
3. Tracking is only enabled if explicitly permitted

## Best Practices Implemented

1. **Privacy-First Approach**:
   - Tracking permission requested transparently
   - No tracking on iOS if permission denied
   - Clear privacy message explaining data use

2. **Resilient Implementation**:
   - Graceful handling if analytics initialization fails
   - App continues to function if tracking is disabled
   - Error handling to prevent app crashes

3. **Efficient Tracking**:
   - Event batching where appropriate
   - Proper lifecycle management
   - Memory-efficient implementation

## Adding New Events

To add a new event to track:

1. Add a new method to `AnalyticsService` class:
```dart
Future<void> logNewEvent({Map<String, dynamic>? parameters}) async {
  await logEvent('new_event_name', parameters: parameters);
}
```

2. Call this method where appropriate in your code:
```dart
try {
  await AnalyticsService().logNewEvent(parameters: {
    'param1': value1,
    'param2': value2,
  });
} catch (e) {
  print('Failed to log event: $e');
}
```

## Troubleshooting

Common issues and solutions:

1. **Events Not Showing in Facebook Dashboard**:
   - There's typically a delay of 24-48 hours before events appear
   - Verify the app ID and client token are correct
   - Check that the device has internet connectivity

2. **ATT Dialog Not Showing on iOS**:
   - Ensure the app is running on iOS 14.5+
   - Verify Info.plist contains NSUserTrackingUsageDescription

3. **High Event Drop Rate**:
   - Check for permission issues
   - Verify network connectivity
   - Look for implementation errors in event parameters

## Data Privacy Considerations

Keep in mind these privacy considerations:
- Do not track personally identifiable information (PII)
- Respect user opt-out choices
- Keep the tracking dialog messaging truthful and clear
- Review Facebook's terms of service regularly for compliance