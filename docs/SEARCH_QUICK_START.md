# Advanced Search - Quick Start Guide

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd /opt/homebrew/var/www/bolide/bolide
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

---

## 💡 Key Features

### Real-Time Search (Dynamic)
**No need to press Enter!** Results update as you type.

```dart
// The search automatically:
// - Waits 500ms after you stop typing
// - Queries the database
// - Updates results in real-time
```

**Usage:**
1. Navigate to search screen
2. Start typing in search field
3. Results appear automatically
4. Keep typing to refine

---

### Voice Search (French)
**Speak your search in French!**

**Usage:**
1. Tap the microphone icon 🎤
2. Speak clearly: *"plaquettes de frein"*
3. Text appears in search field
4. Results show automatically

**Supported:**
- French (France) - `fr-FR` ✅
- Other French dialects available

**Tips:**
- Speak clearly and not too fast
- Works best in quiet environment
- Requires internet connection
- Microphone turns red when listening

---

### Search History
**Your recent searches are saved!**

**Features:**
- Last 5 searches displayed
- Click to re-search
- Click X to delete
- Auto-cleans old entries

**Clear All:**
```dart
await _searchService.clearSearchHistory();
```

---

### Trending Searches
**See what's popular!**

- Top 3 most searched terms (last 7 days)
- Updates automatically
- Click to search
- Icon: 📈

---

### Advanced Filters

**Price Range:**
```dart
advancedSearch(
  query: "filter",
  minPrice: 10000,
  maxPrice: 50000,
)
```

**Stock Only:**
```dart
advancedSearch(
  query: "pneus",
  inStockOnly: true,
)
```

**By Brand:**
```dart
advancedSearch(
  query: "brake",
  brand: "Bosch",
)
```

**By SKU:**
```dart
advancedSearch(
  sku: "BRK-12345",
)
```

---

## 🎨 UI Components

### Search Bar Features
- 🔍 Search icon (left)
- 🎤 Microphone icon (voice search)
- ❌ Clear button (when typing)
- Real-time suggestions dropdown

### Search States

**Empty:**
- Shows trending searches
- Shows recent searches
- Helpful placeholder text

**Typing:**
- Loading indicator appears
- Suggestions dropdown (from history)
- Real-time result count

**Results:**
- Product count badge
- Grid/List view toggle
- Filter and sort buttons
- Product cards with details

**No Results:**
- Helpful empty state
- Suggestion to try different terms
- Clear search button

**Error:**
- Error message displayed
- Retry button
- User-friendly text

---

## 📱 Code Examples

### Initialize Services in Main App
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize search services
  final searchService = SearchService();
  await searchService.initialize();
  
  final voiceService = VoiceSearchService();
  await voiceService.initialize();
  
  runApp(MyApp());
}
```

### Basic Search
```dart
final productService = ProductService();
final results = await productService.advancedSearch(
  query: "plaquettes",
);
```

### Advanced Search with Multiple Criteria
```dart
final results = await productService.advancedSearch(
  query: "brake pads",
  brand: "Bosch",
  minPrice: 20000,
  maxPrice: 100000,
  inStockOnly: true,
  sortBy: 'price_asc',
);
```

### Save Search to History
```dart
final searchService = SearchService();
await searchService.saveSearchHistory(
  "plaquettes de frein",
  sku: "BRK-001",
  brand: "Bosch",
);
```

### Get Search Suggestions
```dart
final suggestions = await searchService.getSearchSuggestions("pla");
// Returns: ["plaquettes de frein", "plaquettes arrière", ...]
```

### Voice Search
```dart
final voiceService = VoiceSearchService();

await voiceService.startListening(
  onResult: (text) {
    print("Recognized: $text");
    // Perform search with recognized text
  },
  localeId: 'fr-FR',
);
```

---

## 🔧 Customization

### Change Debounce Delay
```dart
// In SearchResultsScreen
_debouncer = Debouncer(delay: const Duration(milliseconds: 300)); // Faster
_debouncer = Debouncer(delay: const Duration(milliseconds: 1000)); // Slower
```

### Change History Limit
```dart
// In SearchService
await getSearchHistory(limit: 10); // Show 10 items
await getSearchHistory(limit: 20); // Show 20 items
```

### Change Trending Period
```dart
// In SearchService.getTrendingSearches()
final sevenDaysAgo = DateTime.now()
    .subtract(const Duration(days: 30)) // 30 days instead of 7
    .millisecondsSinceEpoch;
```

### Change Voice Locale
```dart
await voiceService.startListening(
  onResult: (text) { ... },
  localeId: 'fr-CA', // French Canada
);
```

---

## 🐛 Troubleshooting

### Voice Search Not Working

**Check permissions:**
- iOS: Info.plist has NSSpeechRecognitionUsageDescription ✅
- Android: AndroidManifest.xml has RECORD_AUDIO ✅

**Check availability:**
```dart
if (!voiceService.isAvailable) {
  print("Voice search not available on this device");
}
```

### Search History Not Saving

**Check initialization:**
```dart
await searchService.initialize(); // Call this first!
```

**Check database:**
```dart
final db = await searchService.database;
print("Database initialized: $db");
```

### Real-Time Search Too Slow/Fast

**Adjust debounce:**
```dart
// Faster response (but more API calls)
_debouncer = Debouncer(delay: const Duration(milliseconds: 300));

// Slower response (fewer API calls)
_debouncer = Debouncer(delay: const Duration(milliseconds: 800));
```

---

## 📊 Performance Tips

1. **Use debouncing** - Already implemented (500ms)
2. **Limit history** - Keeps only 100 records
3. **Index database** - Already indexed on timestamp
4. **Cache results** - Consider adding for common searches
5. **Pagination** - Add for large result sets

---

## 🎯 Best Practices

### For Users:
- Use voice search in quiet environments
- Speak clearly and naturally
- Use specific product names
- Try different search terms if no results
- Use filters to narrow results

### For Developers:
- Always initialize services before use
- Handle errors gracefully
- Provide visual feedback
- Test on real devices
- Monitor search analytics
- Optimize database queries

---

## 📚 Additional Resources

- Full implementation details: `ADVANCED_SEARCH_IMPLEMENTATION.md`
- Summary: `SEARCH_IMPLEMENTATION_SUMMARY.md`
- Project analysis: `PROJECT_ANALYSIS.md`

---

**Happy Searching! 🔍**
