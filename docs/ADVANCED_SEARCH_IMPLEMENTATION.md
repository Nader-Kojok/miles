# Advanced Search Features - Implementation Guide

## Overview
Complete guide for implementing advanced search with multi-criteria filtering, search history persistence, and French voice search support.

---

## 1. Multi-Criteria Search Implementation

### Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0  # For search history database
  shared_preferences: ^2.2.0  # For quick settings
  speech_to_text: ^7.3.0  # For voice search
```

### SearchService Implementation

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();
  late Database _db;
  
  factory SearchService() {
    return _instance;
  }
  
  SearchService._internal();
  
  Future<void> initialize() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'search_history.db');
    
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE search_history (
            id INTEGER PRIMARY KEY,
            query TEXT NOT NULL,
            sku TEXT,
            brand TEXT,
            category TEXT,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }
  
  /// Advanced search with multiple criteria
  Future<List<Product>> advancedSearch({
    String? query,
    String? sku,
    String? brand,
    String? category,
    VehicleInfo? vehicle,
  }) async {
    // Build dynamic query
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (name LIKE ? OR description LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%']);
    }
    
    if (sku != null && sku.isNotEmpty) {
      whereClause += ' AND sku LIKE ?';
      whereArgs.add('%$sku%');
    }
    
    if (brand != null && brand.isNotEmpty) {
      whereClause += ' AND brand = ?';
      whereArgs.add(brand);
    }
    
    if (category != null && category.isNotEmpty) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }
    
    // If vehicle info provided, filter by compatibility
    if (vehicle != null) {
      whereClause += ' AND vehicle_compatibility LIKE ?';
      whereArgs.add('%${vehicle.year}%');
    }
    
    // Query your database/API
    final results = await _queryProducts(whereClause, whereArgs);
    
    // Save to search history
    if (query != null && query.isNotEmpty) {
      await saveSearchHistory(query, sku, brand, category);
    }
    
    return results;
  }
  
  /// Save search query to history
  Future<void> saveSearchHistory(
    String query, [
    String? sku,
    String? brand,
    String? category,
  ]) async {
    await _db.insert(
      'search_history',
      {
        'query': query,
        'sku': sku,
        'brand': brand,
        'category': category,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get search history (last 10)
  Future<List<String>> getSearchHistory() async {
    final results = await _db.query(
      'search_history',
      columns: ['query'],
      distinct: true,
      orderBy: 'timestamp DESC',
      limit: 10,
    );
    
    return results.map((row) => row['query'] as String).toList();
  }
  
  /// Get trending searches (most frequent in last 7 days)
  Future<List<String>> getTrendingSearches() async {
    final sevenDaysAgo = DateTime.now()
        .subtract(Duration(days: 7))
        .millisecondsSinceEpoch;
    
    final results = await _db.rawQuery('''
      SELECT query, COUNT(*) as count
      FROM search_history
      WHERE timestamp > ?
      GROUP BY query
      ORDER BY count DESC
      LIMIT 5
    ''', [sevenDaysAgo]);
    
    return results.map((row) => row['query'] as String).toList();
  }
  
  /// Clear search history
  Future<void> clearSearchHistory() async {
    await _db.delete('search_history');
  }
  
  // Mock implementation - replace with your actual database/API call
  Future<List<Product>> _queryProducts(
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    // TODO: Implement actual database or API query
    return [];
  }
}
```

---

## 2. Search History UI Widget

```dart
import 'package:flutter/material.dart';

class SearchHistoryWidget extends StatefulWidget {
  final Function(String) onSearchSelected;
  
  const SearchHistoryWidget({
    required this.onSearchSelected,
    Key? key,
  }) : super(key: key);
  
  @override
  State<SearchHistoryWidget> createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  late SearchService _searchService;
  List<String> _history = [];
  List<String> _trending = [];
  
  @override
  void initState() {
    super.initState();
    _searchService = SearchService();
    _loadHistory();
  }
  
  Future<void> _loadHistory() async {
    final history = await _searchService.getSearchHistory();
    final trending = await _searchService.getTrendingSearches();
    
    setState(() {
      _history = history;
      _trending = trending;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_trending.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Trending Searches',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _trending.map((search) {
                return FilterChip(
                  label: Text(search),
                  onSelected: (_) => widget.onSearchSelected(search),
                  avatar: Icon(Icons.trending_up, size: 16),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
          ],
          if (_history.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () async {
                      await _searchService.clearSearchHistory();
                      _loadHistory();
                    },
                    child: Text('Clear'),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.history),
                  title: Text(_history[index]),
                  onTap: () => widget.onSearchSelected(_history[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      // TODO: Implement individual history deletion
                    },
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 3. Voice Search Implementation (French Support)

### Dependencies
Already added: `speech_to_text: ^7.3.0`

### VoiceSearchService

```dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchService {
  static final VoiceSearchService _instance = VoiceSearchService._internal();
  late stt.SpeechToText _speechToText;
  
  factory VoiceSearchService() {
    return _instance;
  }
  
  VoiceSearchService._internal() {
    _speechToText = stt.SpeechToText();
  }
  
  /// Initialize speech recognition
  Future<bool> initialize() async {
    try {
      final available = await _speechToText.initialize(
        onError: (error) => print('Error: $error'),
        onStatus: (status) => print('Status: $status'),
      );
      return available;
    } catch (e) {
      print('Error initializing speech: $e');
      return false;
    }
  }
  
  /// Get available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    return await _speechToText.locales();
  }
  
  /// Start listening for speech (French: fr-FR)
  Future<String?> startListening({
    String localeId = 'fr-FR', // Default to French
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!_speechToText.isAvailable) {
      print('Speech recognition not available');
      return null;
    }
    
    String recognizedText = '';
    
    try {
      _speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          print('Recognized: $recognizedText');
        },
        localeId: localeId,
        listenMode: stt.ListenMode.search,
        pauseDuration: Duration(seconds: 3),
      );
      
      // Wait for speech to complete or timeout
      await Future.delayed(timeout);
      await stopListening();
      
      return recognizedText.isNotEmpty ? recognizedText : null;
    } catch (e) {
      print('Error during speech recognition: $e');
      return null;
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
  
  /// Check if currently listening
  bool get isListening => _speechToText.isListening;
}
```

### Voice Search UI Widget

```dart
import 'package:flutter/material.dart';

class VoiceSearchButton extends StatefulWidget {
  final Function(String) onVoiceResult;
  final String locale;
  
  const VoiceSearchButton({
    required this.onVoiceResult,
    this.locale = 'fr-FR',
    Key? key,
  }) : super(key: key);
  
  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton> {
  late VoiceSearchService _voiceService;
  bool _isListening = false;
  String _recognizedText = '';
  
  @override
  void initState() {
    super.initState();
    _voiceService = VoiceSearchService();
    _initializeVoiceSearch();
  }
  
  Future<void> _initializeVoiceSearch() async {
    final initialized = await _voiceService.initialize();
    if (!initialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice search not available')),
      );
    }
  }
  
  Future<void> _startListening() async {
    setState(() => _isListening = true);
    
    try {
      final result = await _voiceService.startListening(
        localeId: widget.locale,
        timeout: Duration(seconds: 10),
      );
      
      if (result != null && result.isNotEmpty) {
        widget.onVoiceResult(result);
        setState(() => _recognizedText = result);
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during voice search')),
      );
    } finally {
      setState(() => _isListening = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _isListening ? null : _startListening,
      backgroundColor: _isListening ? Colors.red : Colors.blue,
      child: Icon(
        _isListening ? Icons.mic : Icons.mic_none,
        color: Colors.white,
      ),
      tooltip: _isListening ? 'Listening...' : 'Voice Search',
    );
  }
  
  @override
  void dispose() {
    _voiceService.stopListening();
    super.dispose();
  }
}
```

---

## 4. Advanced Search Screen Integration

```dart
import 'package:flutter/material.dart';

class AdvancedSearchScreen extends StatefulWidget {
  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  late SearchService _searchService;
  
  final _queryController = TextEditingController();
  final _skuController = TextEditingController();
  String? _selectedBrand;
  String? _selectedCategory;
  
  List<Product> _searchResults = [];
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _searchService = SearchService();
  }
  
  Future<void> _performSearch() async {
    setState(() => _isSearching = true);
    
    try {
      final results = await _searchService.advancedSearch(
        query: _queryController.text.isEmpty ? null : _queryController.text,
        sku: _skuController.text.isEmpty ? null : _skuController.text,
        brand: _selectedBrand,
        category: _selectedCategory,
      );
      
      setState(() => _searchResults = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }
  
  void _handleVoiceResult(String text) {
    _queryController.text = text;
    _performSearch();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Search'),
      ),
      body: Column(
        children: [
          // Search Filters
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Query field
                TextField(
                  controller: _queryController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                
                // SKU field
                TextField(
                  controller: _skuController,
                  decoration: InputDecoration(
                    labelText: 'SKU / Part Number',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                
                // Brand dropdown
                DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  decoration: InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Bosch', 'Denso', 'Valeo', 'Continental']
                      .map((brand) => DropdownMenuItem(
                            value: brand,
                            child: Text(brand),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBrand = value),
                ),
                SizedBox(height: 12),
                
                // Category dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Engine', 'Transmission', 'Suspension', 'Brakes']
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
                SizedBox(height: 16),
                
                // Search button
                ElevatedButton.icon(
                  onPressed: _isSearching ? null : _performSearch,
                  icon: Icon(Icons.search),
                  label: Text(_isSearching ? 'Searching...' : 'Search'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
          
          // Search History / Trending
          if (_searchResults.isEmpty && !_isSearching)
            Expanded(
              child: SearchHistoryWidget(
                onSearchSelected: (query) {
                  _queryController.text = query;
                  _performSearch();
                },
              ),
            ),
          
          // Results
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('SKU: ${product.sku}'),
                    trailing: Text('\$${product.price}'),
                  );
                },
              ),
            ),
          
          if (_isSearching)
            Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: VoiceSearchButton(
        onVoiceResult: _handleVoiceResult,
        locale: 'fr-FR', // French
      ),
    );
  }
  
  @override
  void dispose() {
    _queryController.dispose();
    _skuController.dispose();
    super.dispose();
  }
}
```

---

## 5. French Voice Search Configuration

### Available Locales
- `fr-FR` - French (France)
- `fr-CA` - French (Canada)
- `fr-BE` - French (Belgium)
- `fr-CH` - French (Switzerland)

### iOS Configuration
Add to `ios/Runner/Info.plist`:
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to your microphone for voice search</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice search</string>
```

### Android Configuration
Add to `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 31 // or higher
}
```

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 6. Testing Voice Search with French

```dart
void testVoiceSearchFrench() async {
  final voiceService = VoiceSearchService();
  
  // Initialize
  final initialized = await voiceService.initialize();
  print('Initialized: $initialized');
  
  // Get available locales
  final locales = await voiceService.getAvailableLocales();
  print('Available locales: ${locales.map((l) => l.localeId).toList()}');
  
  // Start listening in French
  final result = await voiceService.startListening(
    localeId: 'fr-FR',
    timeout: Duration(seconds: 10),
  );
  
  print('Recognized text: $result');
}
```

---

## 7. Key Features Summary

✅ **Multi-Criteria Search**
- Search by product name, SKU, brand, category
- Vehicle compatibility filtering (when YMM data available)

✅ **Search History**
- Persistent local storage using SQLite
- Last 10 searches displayed
- Clear history option

✅ **Trending Searches**
- Tracks most frequent searches in last 7 days
- Top 5 trending displayed
- Helps users discover popular searches

✅ **Voice Search (French)**
- `speech_to_text` package with French locale support
- Works on iOS and Android
- Requires microphone permissions
- Timeout handling for better UX

---

## 8. Performance Considerations

- **Debounce search input** to avoid excessive queries
- **Limit search history** to 100 records (auto-cleanup)
- **Cache trending searches** for 1 hour
- **Use pagination** for large result sets
- **Index database** on frequently searched columns

---

## 9. Next Steps

1. Add database initialization to app startup
2. Integrate SearchService into product repository
3. Add permissions handling for voice search
4. Implement search analytics tracking
5. Add search suggestions/autocomplete
6. Test voice recognition on real devices
