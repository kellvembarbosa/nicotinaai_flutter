# Account Deletion Implementation

This document outlines the approach used for implementing account deletion in the app, ensuring compliance with privacy regulations and app store requirements.

## Architecture Overview

The account deletion feature follows a multi-layered approach:

1. **Data Cleanup**: Remove all user data from application tables
2. **Hard Delete**: Attempt to completely remove the user account
3. **Soft Delete Fallback**: If hard delete fails, mark the account as deleted in metadata
4. **Authentication Flow**: Handle logout and redirection

## Implementation Details

### Client-Side Implementation

- **Repository**: `SettingsRepository.deleteAccount()`
  - Password verification for security
  - Modularized approach with separate methods for each step
  - Robust error handling at each stage
  - Detailed logging for troubleshooting

- **BLoC**: `SettingsBloc._onDeleteAccount()`
  - Proper state management
  - Success status propagation
  - Error handling and reporting

- **UI**: `DeleteAccountScreen`
  - Password verification
  - Confirmation checkbox
  - Clear user warnings
  - Success dialog with information about future registration
  - Proper navigation to login screen

### Server-Side Implementation

- **Edge Function**: `delete-user-account`
  - Simple interface accepting only user_id
  - Service role authentication for administrative actions
  - Two-phase approach: data cleanup followed by account deletion
  - Robust error handling

- **Database Function**: `delete_user_data()`
  - Secure implementation with SECURITY DEFINER
  - Parameter disambiguation to avoid column name conflicts
  - Table-by-table cleanup with try/catch blocks
  - Service role restricted access

- **RLS Policies**:
  - Prevent deleted accounts from accessing data
  - Function `auth.is_account_active()` to check account status

## Key Features

1. **Compliance with Requirements**:
   - Complete data removal from all tables
   - Clear UI flow with explicit user consent
   - Proper handling of the deletion process

2. **Robustness**:
   - Fallback mechanisms if hard delete fails
   - Individual error handling for each table deletion
   - Comprehensive logging for troubleshooting

3. **Future Registration Support**:
   - Allows users to register again with the same email
   - Does not modify email or password during deletion
   - Uses metadata to mark accounts as deleted

## Data Cleanup Process

The implementation cleans up user data from the following tables:

- `profiles`
- `user_stats`
- `cravings`
- `smoking_logs`
- `user_notifications`
- `user_achievements`
- `user_health_recoveries`
- `user_fcm_tokens`
- `viewed_achievements`
- `daily_motivations`
- `saved_motivations`

## Testing

To thoroughly test the account deletion flow:

1. Create a test account
2. Add data to various aspects of the app (tracking, achievements, etc.)
3. Request account deletion
4. Verify all data has been removed from the database
5. Try to register again with the same email
6. Verify the new registration works properly

## Future Improvements

- Add feedback mechanism to let users provide deletion reason
- Implement a "cooling-off" period with account recovery option
- Add account export functionality before deletion
- Implement administrative dashboard for deletion metrics