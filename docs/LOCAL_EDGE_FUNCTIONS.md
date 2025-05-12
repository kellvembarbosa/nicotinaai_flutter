# Local Edge Functions Implementation

This document describes the implementation of client-side alternatives to Supabase Edge Functions to improve performance, reduce server costs, and provide better offline capabilities.

## Overview

Some Supabase Edge Functions can be safely implemented on the client side when they don't require special permissions or external services. This project has implemented local alternatives for:

1. **updateUserStats** - Calculates user statistics from smoking logs and cravings
2. **checkHealthRecoveries** - Checks for health milestones based on days without smoking

## Implementation Pattern

Our implementation follows a consistent pattern:

1. Create a service class for the local implementation
2. Implement equivalent logic to the Edge Function
3. Use the repository pattern to provide a consistent API
4. Implement fallback to Edge Function if local implementation fails

## LocalStatsService

The `LocalStatsService` replaces the `updateUserStats` Edge Function by:

1. Fetching user data from the Supabase database
2. Calculating statistics locally using `ImprovedStatsCalculator`
3. Updating the database with the calculated values

Key benefits:
- Faster performance (no round-trip to Edge Function)
- Works in offline mode by using cached data
- Centralized calculation logic ensures consistency

## LocalHealthRecoveryService

The `LocalHealthRecoveryService` is a new implementation that replaces the `checkHealthRecoveries` Edge Function:

1. Fetches user statistics to determine days without smoking
2. Fetches health recovery definitions and already achieved recoveries
3. Checks for new achievements based on smoke-free days
4. Updates database and creates notifications for new achievements 

This implementation follows the same pattern as the `LocalStatsService` and provides similar benefits.

## Best Practices

When implementing local alternatives to Edge Functions:

1. Always maintain a fallback path to the original Edge Function
2. Centralize calculation logic (see `ImprovedStatsCalculator`)
3. Handle edge cases and errors gracefully
4. Ensure thread safety and handle concurrency
5. Use the repository pattern to abstract the implementation details

## Monitoring & Debugging

Local edge function implementations include enhanced logging with:

- Clear logging prefix to identify the source (`[LocalStatsService]`)
- Emoji indicators for log importance (✅ success, ⚠️ warning, ❌ error)
- Detailed debug info when `kDebugMode` is true

## Future Improvements

Additional enhancements that could be implemented:

1. Offline queue for operations that failed due to connectivity issues
2. Better caching mechanisms to reduce database reads
3. Retry mechanisms for failed operations
4. More comprehensive error reporting
5. Unit tests to ensure consistency with Edge Function implementations

## Edge Functions That Should Remain Server-Side

Some Edge Functions should remain server-side:

1. **store_fcm_token** - Requires admin privileges to bypass RLS
2. **generate-daily-motivation** - Requires OpenAI API access
3. **claim-motivation-reward** - Requires server-side validation
4. **delete-user-account** - Requires admin privileges to delete user data

These functions depend on secure services, admin privileges, or third-party APIs that would be insecure or impractical to implement client-side.