enum SyncStatus {
  synced,   // Item is synced with server
  pending,  // Item is waiting to be synced
  failed,   // Sync failed but will retry
  error     // Permanent error, won't retry
}