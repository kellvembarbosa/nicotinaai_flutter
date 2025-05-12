# Edge Functions Analysis and Migration Plan

## Summary of Edge Functions in the Project

1. **updateUserStats**
   - **Purpose**: Calculates user statistics based on smoking logs and cravings data
   - **Already Localized**: Yes, migrated to `LocalStatsService` with `ImprovedStatsCalculator`
   - **Implementation**: The local version fetches data from the database and performs the same calculations as the edge function, then updates the database with the results

2. **checkHealthRecoveries**
   - **Purpose**: Checks for health recovery milestones based on days without smoking
   - **Already Localized**: Partially - called from TrackingBloc but the logic is still server-side
   - **Candidate for Local Implementation**: Yes, good candidate for local implementation

3. **store_fcm_token**
   - **Purpose**: Workaround for RLS policy issues when storing FCM tokens
   - **Already Localized**: No
   - **Can Be Localized**: No, this is specifically designed to bypass RLS policies that mobile clients can't bypass

4. **generate-daily-motivation**
   - **Purpose**: Generates personalized daily motivational messages using OpenAI
   - **Already Localized**: No
   - **Can Be Localized**: No, requires OpenAI API integration on server-side

5. **claim-motivation-reward**
   - **Purpose**: Awards XP when a user views their daily motivation
   - **Already Localized**: No
   - **Can Be Localized**: No, requires server-side validation and XP award logic

6. **delete-user-account**
   - **Purpose**: Complex account deletion with cleanup of all related data
   - **Already Localized**: No
   - **Can Be Localized**: No, requires admin privileges to delete user accounts

## Candidates for Local Implementation

1. **checkHealthRecoveries**
   - This function could be implemented locally as it primarily involves:
     - Checking days since last smoking event
     - Comparing against predefined milestone thresholds
     - Creating records for achieved milestones
   - The client already has access to the necessary data: last smoke date and health recovery definitions
   - Implementation would be similar to `LocalStatsService` approach

## Implementation Plan for checkHealthRecoveries

1. Create a `LocalHealthRecoveryService` class that:
   - Fetches health recovery definitions from the database
   - Calculates days since last smoke based on user stats
   - Determines which health recoveries should be awarded
   - Updates the user_health_recoveries table accordingly

2. Integrate with the TrackingBloc similar to how LocalStatsService is integrated:
   - Add a fallback mechanism that calls the edge function if the local implementation fails
   - Reuse the ImprovedStatsCalculator for consistent day calculations

3. Benefits:
   - Reduced server costs
   - Faster user experience
   - Works offline (except for the final database write)
   - Consistent with the LocalStatsService pattern already implemented

## Key Observations

1. The project demonstrates a clear migration pattern from server-side to client-side calculations, as seen with `updateUserStats` -> `LocalStatsService`

2. The `TrackingNormalizer` improves consistency by providing a single source for normalized data calculations

3. The `ImprovedStatsCalculator` centralizes calculation logic to ensure consistency across the app

4. Edge functions like token storage, motivation generation, and account deletion should remain server-side due to security, API access, or permission requirements

This analysis shows that the project is already moving in the direction of optimizing edge function usage by implementing local alternatives where appropriate, with updateUserStats being a prime example. The checkHealthRecoveries function is the best next candidate for local implementation.