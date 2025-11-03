# Web Platform Compatibility Fix

## Problem
The application was crashing on web platform with the following error:
```
Error initializing SearchService: Bad state: databaseFactory not initialized
databaseFactory is only initialized when using sqflite. When using `sqflite_common_ffi` 
You must call `databaseFactory = databaseFactoryFfi;` before using global openDatabase API
```

Additionally, voice search was not available on web, showing:
```
"recherche vocale non disponible"
```

## Root Cause
- **SQLite (sqflite)** is designed for mobile platforms (iOS/Android) and doesn't work on web
- **Speech-to-text** functionality is not supported on web browsers
- The app was attempting to initialize both services on web without platform detection

## Solution Implemented

### 1. SearchService Web Compatibility
**File**: `lib/services/search_service.dart`

**Changes**:
- Added platform detection using `kIsWeb` from `flutter/foundation.dart`
- Implemented dual storage strategy:
  - **Mobile (iOS/Android)**: SQLite database for search history
  - **Web**: SharedPreferences for persistent search history storage
- All methods now check platform and use appropriate storage mechanism

**Key Methods Updated**:
- `initialize()` - Skips SQLite setup on web
- `saveSearchHistory()` - Uses SharedPreferences on web
- `getSearchHistory()` - Reads from SharedPreferences on web
- `getTrendingSearches()` - In-memory calculation on web
- `deleteSearchByQuery()` - Updates SharedPreferences on web
- `clearSearchHistory()` - Clears SharedPreferences on web
- `getSearchSuggestions()` - Filters in-memory on web
- `close()` - No-op on web (no database to close)

### 2. VoiceSearchService Web Compatibility
**File**: `lib/services/voice_search_service.dart`

**Changes**:
- Added platform detection using `kIsWeb`
- `initialize()` method returns `false` on web with clear message
- Gracefully handles unavailability on web platform

## How It Works

### Web Platform
```dart
// Search history stored as JSON in SharedPreferences
{
  "search_history": [
    "{\"query\":\"brake pads\",\"timestamp\":1234567890}",
    "{\"query\":\"oil filter\",\"timestamp\":1234567891}"
  ]
}
```

### Mobile Platform
```sql
-- Search history stored in SQLite database
CREATE TABLE search_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  query TEXT NOT NULL,
  sku TEXT,
  brand TEXT,
  category TEXT,
  timestamp INTEGER NOT NULL
);
```

## Benefits
1. ✅ **App works on web** - No more initialization errors
2. ✅ **Search history works on web** - Using SharedPreferences
3. ✅ **Graceful degradation** - Voice search shows as unavailable instead of crashing
4. ✅ **Code maintainability** - Single codebase handles multiple platforms
5. ✅ **No data loss** - Search history persists across sessions on web

## Testing
To verify the fix:

1. **Run on web**:
   ```bash
   flutter run -d chrome
   ```

2. **Test search history**:
   - Search for products
   - Verify searches appear in history
   - Clear history and verify it's cleared
   - Refresh page and verify history persists

3. **Test voice search**:
   - Voice search button should be visible but disabled on web
   - Shows message: "Speech recognition not available on web"

## Platform Support Matrix

| Feature | iOS | Android | Web | Desktop |
|---------|-----|---------|-----|---------|
| Search History (SQLite) | ✅ | ✅ | ❌ | ✅* |
| Search History (SharedPrefs) | ❌ | ❌ | ✅ | ❌ |
| Voice Search | ✅ | ✅ | ❌ | ❌ |
| Search Suggestions | ✅ | ✅ | ✅ | ✅ |

*Desktop platforms need `sqflite_common_ffi` initialization

## Future Improvements
1. Add web-specific voice search using Web Speech API
2. Implement IndexedDB for better web storage performance
3. Add offline support for web using service workers
4. Sync search history across devices using Supabase

## Notes
- The fix is backward compatible - mobile functionality remains unchanged
- SharedPreferences on web uses localStorage under the hood
- Maximum 100 search items maintained on all platforms
- All error handling is graceful - app continues working even if storage fails
