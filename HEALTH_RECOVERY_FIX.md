# Health Recovery System Fix

This document describes the issues fixed with the health recovery system and the database schema.

## Issues Fixed

1. **Missing `cravings_count` column in user_stats table**
   - Error: `Could not find the 'cravings_count' column of 'user_stats' in the schema cache`
   - Fix: Added the missing column to the database schema and updated the UserStats model

2. **Type conversion issue with craving outcome enum**
   - Error: `operator does not exist: enum_craving_outcome = integer`
   - Fix: Created proper enum type handling in the database migration and improved conversion logic in the CravingModel

## Implementation Details

### Database Schema Updates

1. Added a new migration `20240523_fix_schema_issues.sql` that:
   - Adds the missing `cravings_count` column to the `user_stats` table if it doesn't exist
   - Fixes the `outcome` column in the `cravings` table to properly use the `craving_outcome` enum type

### Code Updates

1. Updated `UserStats` model to include the `cravingsCount` field:
   - Added the field to the model constructor
   - Updated the `copyWith` method to support the new field
   - Updated the `fromJson` and `toJson` methods
   - Added the field to equality operators and hashCode

2. Updated `LocalStatsService` to:
   - Calculate and track the total cravings count
   - Include the new field in update operations to the database

3. Created test cases to verify:
   - The `UserStats` model correctly handles the `cravingsCount` field
   - The `CravingModel` correctly handles enum conversion between database and app

## Testing

To test the fix:

1. Run the database migration script to add the missing column and fix the enum type
2. Run the app and verify that health recovery data is correctly tracked
3. Run the unit tests in `test/health_recovery_fix_test.dart` to verify the model changes

## Technical Notes

- The enum handling mismatch occurred because the database expected `enum_craving_outcome` but was receiving `integer` values
- The migration creates a safe conversion between existing data and the proper enum type
- The `cravings_count` field was used in the code but missing in the database schema