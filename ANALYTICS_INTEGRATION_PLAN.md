# Analytics Integration Plan

This document outlines a comprehensive plan to enhance the analytics tracking implementation in the app, focusing on user identification and onboarding flow tracking.

## Current Status

The app currently has:
- A well-structured analytics system with Facebook and PostHog integration
- User identification tracking in login/registration flows
- Limited event tracking in the onboarding process (only tracks completion)
- Missing step-by-step tracking for onboarding screens and interactions

## Implementation Plan

### 1. User Identification Enhancement

#### High Priority
- [ ] Ensure user ID is set after successful login/registration in auth_bloc.dart
- [ ] Implement persistent anonymous ID tracking before user login
- [ ] Add user property tracking with demographic and usage data
- [ ] Create user identification transition (merge anonymous with logged in user)

#### Implementation Details
```dart
// In auth_bloc.dart, update _onLoginRequested method
Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
  try {
    // Existing login logic...
    
    // Enhanced analytics
    try {
      final anonymousId = await AnalyticsService().getAnonymousId();
      await AnalyticsService().identify(
        userId: user.id,
        userTraits: {
          'email': user.email,
          'createdAt': user.createdAt,
          'previousAnonymousId': anonymousId,
        },
      );
      await AnalyticsService().trackEvent('User Logged In', parameters: {
        'method': 'email',
        'userId': user.id,
      });
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  } catch (e) {
    // Error handling...
  }
}
```

### 2. Onboarding Flow Tracking

#### High Priority
- [ ] Add analytics tracking to each onboarding screen
- [ ] Track screen views for all onboarding screens
- [ ] Track user interactions (selections, button clicks)
- [ ] Implement onboarding funnel analysis

#### Implementation Steps
1. Create a base OnboardingAnalytics mixin:
```dart
mixin OnboardingAnalytics {
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    AnalyticsService().trackScreenView(
      screenName: 'Onboarding_$screenName',
      properties: properties,
    );
  }
  
  void trackInteraction(String action, {Map<String, dynamic>? properties}) {
    AnalyticsService().trackEvent(
      'Onboarding_Interaction',
      parameters: {
        'action': action,
        ...?properties,
      },
    );
  }
}
```

2. Add tracking to each onboarding screen:
```dart
class IntroductionScreen extends StatelessWidget with OnboardingAnalytics {
  @override
  Widget build(BuildContext context) {
    // Track screen view when rendered
    trackScreenView('Introduction');
    
    return Scaffold(
      // Screen content...
      body: Column(
        children: [
          // Existing widgets...
          ElevatedButton(
            onPressed: () {
              // Track interaction before navigation
              trackInteraction('NextButtonClicked', properties: {
                'from_screen': 'Introduction',
                'to_screen': 'CigarettesPerDay'
              });
              // Navigate to next screen...
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}
```

### 3. Tracking in Existing Screens

#### Medium Priority
- [ ] Add analytics to home screen interactions
- [ ] Track feature usage across the app
- [ ] Implement smoke tracking events

#### Implementation Example:
```dart
// In home_screen.dart
void _logSmokingRecord() {
  // Existing code...
  
  // Add analytics
  AnalyticsService().trackEvent('Smoking_Record_Added', parameters: {
    'cigarette_count': count,
    'timestamp': DateTime.now().toIso8601String(),
    'location': selectedLocation,
  });
}
```

### 4. Analytics Service Enhancement

#### Medium Priority
- [ ] Add error tracking and monitoring
- [ ] Create custom event definitions for better data consistency
- [ ] Implement automatic session tracking
- [ ] Add opt-out capability for GDPR compliance

#### Implementation Details:
```dart
// In analytics_service.dart
Future<void> logError(String errorName, String errorMessage) async {
  await trackEvent('Error_Occurred', parameters: {
    'error_name': errorName,
    'error_message': errorMessage,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

// Add analytics constants
class AnalyticsEvents {
  static const String APP_OPENED = 'App_Opened';
  static const String USER_LOGGED_IN = 'User_Logged_In';
  static const String USER_REGISTERED = 'User_Registered';
  static const String ONBOARDING_STARTED = 'Onboarding_Started';
  static const String ONBOARDING_COMPLETED = 'Onboarding_Completed';
  static const String ONBOARDING_ABANDONED = 'Onboarding_Abandoned';
  // Add more standardized events...
}
```

### 5. Testing and Validation

#### High Priority
- [ ] Create analytics testing screen
- [ ] Add automated tests for analytics events
- [ ] Implement debug mode for analytics validation

#### Implementation Details:
```dart
// Create analytics_debug_screen.dart
class AnalyticsDebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics Debug')),
      body: ListView(
        children: [
          _buildTestButton(
            'Test User Login',
            () => AnalyticsService().trackEvent('User_Logged_In', 
                parameters: {'test': true}),
          ),
          _buildTestButton(
            'Test Onboarding Complete',
            () => AnalyticsService().trackEvent('Onboarding_Completed', 
                parameters: {'test': true}),
          ),
          // Add more test buttons...
        ],
      ),
    );
  }
  
  Widget _buildTestButton(String title, VoidCallback onPressed) {
    return ListTile(
      title: Text(title),
      trailing: ElevatedButton(
        onPressed: onPressed,
        child: Text('Test'),
      ),
    );
  }
}
```

## Implementation Timeline

### Week 1: User Identification & Foundation
- Enhance user identification in auth flows
- Create analytics constants and standardized events
- Implement persistent user tracking
- Add basic error tracking

### Week 2: Onboarding Analytics
- Create OnboardingAnalytics mixin
- Add tracking to all onboarding screens
- Implement interaction tracking
- Create onboarding funnel

### Week 3: App-wide Implementation
- Add tracking to home screen
- Implement feature usage analytics
- Add tracking for key user actions
- Create testing screen

### Week 4: Testing & Validation
- Test all analytics events
- Validate data in PostHog and Facebook dashboards
- Document event schema
- Training for analytics dashboard usage

## Technical Recommendations

1. **Use BLoC Pattern for Analytics**
   - Consider using the BLoC pattern for consistent analytics implementation
   - Add analytics events to BLoC event handlers instead of UI

2. **Batch Processing**
   - Implement batching for analytics events to reduce API calls
   - Consider offline storage for analytics when no connectivity

3. **User Properties Schema**
   - Standardize user property names across all analytics providers
   - Document all property names and expected values

## Dashboard Setup

1. **PostHog Dashboard**
   - Create funnels for onboarding flow
   - Set up user cohorts by registration date
   - Configure retention analysis
   - Set up custom metrics for key KPIs

2. **Facebook Analytics**
   - Configure conversion events
   - Set up audience segmentation
   - Implement ROAS tracking

## GDPR and Privacy Considerations

1. **User Consent**
   - Implement explicit opt-in for analytics tracking
   - Provide clear privacy policy explanation
   - Allow users to opt-out at any time

2. **Data Handling**
   - Ensure PII is properly handled according to regulations
   - Implement data retention policies
   - Document all tracked events and properties

---

This integration plan provides a structured approach to enhancing the app's analytics capabilities, focusing on user identification and onboarding tracking while ensuring compliance with privacy regulations.