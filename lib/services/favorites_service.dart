// lib/services/favorites_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_prompt_ids';

  // Memory cache of loaded prompts
  static final List<Map<String, dynamic>> _promptsCache = [];

  static final ValueNotifier<Set<String>> favoritesNotifier = ValueNotifier<Set<String>>({});

  /// Add/update prompts in the memory cache
  static void cachePrompts(List<Map<String, dynamic>> prompts) {
    for (final prompt in prompts) {
      if (prompt['docId'] == null) continue;
      final index = _promptsCache.indexWhere((p) => p['docId'] == prompt['docId']);
      if (index != -1) {
        _promptsCache[index] = prompt;
      } else {
        _promptsCache.add(prompt);
      }
    }
  }

  /// Get cached favorites matching the given IDs
  static List<Map<String, dynamic>> getCachedFavorites(Set<String> favIds) {
    return _promptsCache.where((p) => favIds.contains(p['docId'])).toList();
  }

  /// Get all cached prompts from the memory cache
  static List<Map<String, dynamic>> getCachedPrompts() {
    return _promptsCache;
  }

  /// Get the user's favorite IDs.
  static Future<Set<String>> getFavorites({bool fetchFromFirestore = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final set = list.toSet();
    if (favoritesNotifier.value.length != set.length || !favoritesNotifier.value.containsAll(set)) {
      favoritesNotifier.value = set;
    }
    return set;
  }

  /// Toggles a favorite item.
  /// Updates local SharedPreferences instantly so the UI is responsive.
  static Future<void> toggleFavorite(String docId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final set = list.toSet();
    
    final isAdding = !set.contains(docId);

    // Update local cache
    if (isAdding) {
      set.add(docId);
    } else {
      set.remove(docId);
    }
    await prefs.setStringList(_key, set.toList());
    favoritesNotifier.value = set;
  }

  /// Check if a prompt is in the favorites list.
  static Future<bool> isFavorite(String docId) async {
    final favorites = await getFavorites();
    return favorites.contains(docId);
  }

  /// Save prompts to persistent local cache
  static Future<void> savePromptsToLocalCache(List<Map<String, dynamic>> prompts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> serializable = prompts.map((p) {
        final Map<String, dynamic> copy = Map<String, dynamic>.from(p);
        if (copy['createdAt'] is DateTime) {
          copy['createdAt'] = (copy['createdAt'] as DateTime).millisecondsSinceEpoch;
        }
        return copy;
      }).toList();
      await prefs.setString('cached_prompts_list', jsonEncode(serializable));
    } catch (e) {
      debugPrint('Error saving prompts cache: $e');
    }
  }

  /// Load prompts from persistent local cache
  static Future<List<Map<String, dynamic>>> loadPromptsFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('cached_prompts_list');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((p) => Map<String, dynamic>.from(p as Map)).toList();
      }
    } catch (e) {
      debugPrint('Error loading prompts cache: $e');
    }
    return [];
  }

  static String followMeLink = 'https://instagram.com';
  static String howToUseLink = 'https://surajchaurasia84.github.io/Top-Prompt/';

  /// Load follow me and how to use links from local cache
  static Future<void> loadAppLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      followMeLink = prefs.getString('link_follow_me') ?? followMeLink;
      howToUseLink = prefs.getString('link_how_to_use') ?? howToUseLink;
    } catch (e) {
      debugPrint('Error loading app links: $e');
    }
  }

  // ── Instance methods for backward compatibility ────────────────────────────
  Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    return ids.map((id) => int.tryParse(id) ?? 0).where((id) => id != 0).toSet();
  }

  Future<void> saveFavorites(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      ids.map((id) => id.toString()).toList(),
    );
  }
}
