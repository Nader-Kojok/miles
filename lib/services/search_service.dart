import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchHistoryItem {
  final int? id;
  final String query;
  final String? sku;
  final String? brand;
  final String? category;
  final DateTime timestamp;

  SearchHistoryItem({
    this.id,
    required this.query,
    this.sku,
    this.brand,
    this.category,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query,
      'sku': sku,
      'brand': brand,
      'category': category,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SearchHistoryItem.fromMap(Map<String, dynamic> map) {
    return SearchHistoryItem(
      id: map['id'] as int?,
      query: map['query'] as String,
      sku: map['sku'] as String?,
      brand: map['brand'] as String?,
      category: map['category'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}

class SearchService {
  static final SearchService _instance = SearchService._internal();
  Database? _db;
  bool _initialized = false;

  factory SearchService() {
    return _instance;
  }

  SearchService._internal();

  /// Initialize the search history database
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // On web, we don't use SQLite - use SharedPreferences instead
      if (kIsWeb) {
        print('SearchService: Running on web, using SharedPreferences');
        _initialized = true;
        return;
      }

      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'search_history.db');

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE search_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              query TEXT NOT NULL,
              sku TEXT,
              brand TEXT,
              category TEXT,
              timestamp INTEGER NOT NULL
            )
          ''');

          // Create index on timestamp for faster queries
          await db.execute('''
            CREATE INDEX idx_timestamp ON search_history(timestamp DESC)
          ''');
        },
      );

      _initialized = true;
      print('SearchService initialized successfully');
    } catch (e) {
      print('Error initializing SearchService: $e');
      // Don't throw - allow app to continue without search history
      _initialized = true;
    }
  }

  /// Ensure database is initialized
  Future<Database> get database async {
    if (_db == null || !_initialized) {
      await initialize();
    }
    return _db!;
  }

  /// Get search history from SharedPreferences (for web)
  Future<List<SearchHistoryItem>> _getWebSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('search_history') ?? [];
      
      return historyJson.map((json) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return SearchHistoryItem.fromMap(map);
      }).toList();
    } catch (e) {
      print('Error getting web search history: $e');
      return [];
    }
  }

  /// Save search history to SharedPreferences (for web)
  Future<void> _saveWebSearchHistory(List<SearchHistoryItem> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = history.map((item) => jsonEncode(item.toMap())).toList();
      await prefs.setStringList('search_history', historyJson);
    } catch (e) {
      print('Error saving web search history: $e');
    }
  }

  /// Save search query to history
  Future<void> saveSearchHistory(
    String query, {
    String? sku,
    String? brand,
    String? category,
  }) async {
    if (query.trim().isEmpty) return;

    try {
      if (kIsWeb) {
        // Web implementation using SharedPreferences
        var history = await _getWebSearchHistory();
        
        // Remove existing entry with same query
        history.removeWhere((item) => 
            item.query.toLowerCase() == query.toLowerCase());
        
        // Add new entry at the beginning
        history.insert(0, SearchHistoryItem(
          query: query,
          sku: sku,
          brand: brand,
          category: category,
          timestamp: DateTime.now(),
        ));
        
        // Keep only last 100 searches
        if (history.length > 100) {
          history = history.sublist(0, 100);
        }
        
        await _saveWebSearchHistory(history);
        return;
      }

      final db = await database;

      // Check if query exists in last 5 searches
      final recentSearches = await getSearchHistory(limit: 5);
      final exists = recentSearches.any((item) =>
          item.query.toLowerCase() == query.toLowerCase());

      if (exists) {
        // Update timestamp of existing search
        await db.update(
          'search_history',
          {'timestamp': DateTime.now().millisecondsSinceEpoch},
          where: 'LOWER(query) = ?',
          whereArgs: [query.toLowerCase()],
        );
      } else {
        // Insert new search
        await db.insert(
          'search_history',
          SearchHistoryItem(
            query: query,
            sku: sku,
            brand: brand,
            category: category,
            timestamp: DateTime.now(),
          ).toMap(),
        );
      }

      // Keep only last 100 searches
      await _cleanupOldHistory();
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  /// Get search history (default last 10)
  Future<List<SearchHistoryItem>> getSearchHistory({int limit = 10}) async {
    try {
      if (kIsWeb) {
        // Web implementation
        final history = await _getWebSearchHistory();
        return history.take(limit).toList();
      }

      final db = await database;
      final results = await db.query(
        'search_history',
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return results.map((map) => SearchHistoryItem.fromMap(map)).toList();
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  /// Get search history as string list (for quick display)
  Future<List<String>> getSearchHistoryQueries({int limit = 10}) async {
    final history = await getSearchHistory(limit: limit);
    return history.map((item) => item.query).toList();
  }

  /// Get trending searches (most frequent in last 7 days)
  Future<List<String>> getTrendingSearches({int limit = 5}) async {
    try {
      if (kIsWeb) {
        // Web implementation - simplified trending
        final history = await _getWebSearchHistory();
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        
        // Filter recent searches
        final recentSearches = history.where(
          (item) => item.timestamp.isAfter(sevenDaysAgo)
        ).toList();
        
        // Count frequencies
        final Map<String, int> queryCounts = {};
        for (var item in recentSearches) {
          final lowerQuery = item.query.toLowerCase();
          queryCounts[lowerQuery] = (queryCounts[lowerQuery] ?? 0) + 1;
        }
        
        // Sort by count and return
        final sortedEntries = queryCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return sortedEntries
          .take(limit)
          .map((e) => e.key)
          .toList();
      }

      final db = await database;
      final sevenDaysAgo = DateTime.now()
          .subtract(const Duration(days: 7))
          .millisecondsSinceEpoch;

      final results = await db.rawQuery('''
        SELECT query, COUNT(*) as count
        FROM search_history
        WHERE timestamp > ?
        GROUP BY LOWER(query)
        ORDER BY count DESC
        LIMIT ?
      ''', [sevenDaysAgo, limit]);

      return results.map((row) => row['query'] as String).toList();
    } catch (e) {
      print('Error getting trending searches: $e');
      return [];
    }
  }

  /// Delete a specific search from history
  Future<void> deleteSearchHistoryItem(int id) async {
    try {
      if (kIsWeb) {
        // Web implementation - ID-based deletion not supported, skip
        print('Web: ID-based deletion not supported');
        return;
      }

      final db = await database;
      await db.delete(
        'search_history',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting search history item: $e');
    }
  }

  /// Delete search by query string
  Future<void> deleteSearchByQuery(String query) async {
    try {
      if (kIsWeb) {
        // Web implementation
        var history = await _getWebSearchHistory();
        history.removeWhere(
          (item) => item.query.toLowerCase() == query.toLowerCase()
        );
        await _saveWebSearchHistory(history);
        return;
      }

      final db = await database;
      await db.delete(
        'search_history',
        where: 'LOWER(query) = ?',
        whereArgs: [query.toLowerCase()],
      );
    } catch (e) {
      print('Error deleting search by query: $e');
    }
  }

  /// Clear all search history
  Future<void> clearSearchHistory() async {
    try {
      if (kIsWeb) {
        // Web implementation
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('search_history');
        print('Search history cleared (web)');
        return;
      }

      final db = await database;
      await db.delete('search_history');
      print('Search history cleared');
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Cleanup old history (keep only last 100)
  Future<void> _cleanupOldHistory() async {
    try {
      if (kIsWeb) {
        // Web implementation - handled in saveSearchHistory
        return;
      }

      final db = await database;
      
      // Get count of all records
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM search_history'),
      );

      if (count != null && count > 100) {
        // Delete oldest records keeping only 100
        await db.rawDelete('''
          DELETE FROM search_history
          WHERE id NOT IN (
            SELECT id FROM search_history
            ORDER BY timestamp DESC
            LIMIT 100
          )
        ''');
      }
    } catch (e) {
      print('Error cleaning up old history: $e');
    }
  }

  /// Get search suggestions based on query
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      if (kIsWeb) {
        // Web implementation
        final history = await _getWebSearchHistory();
        final lowerQuery = query.toLowerCase();
        
        return history
          .where((item) => item.query.toLowerCase().contains(lowerQuery))
          .take(5)
          .map((item) => item.query)
          .toList();
      }

      final db = await database;
      final results = await db.query(
        'search_history',
        columns: ['query'],
        where: 'query LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'timestamp DESC',
        limit: 5,
      );

      return results.map((row) => row['query'] as String).toList();
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }

  /// Close database connection
  Future<void> close() async {
    try {
      if (kIsWeb) {
        // No database to close on web
        _initialized = false;
        return;
      }

      if (_db != null) {
        await _db!.close();
        _initialized = false;
      }
    } catch (e) {
      print('Error closing database: $e');
      _initialized = false;
    }
  }
}
