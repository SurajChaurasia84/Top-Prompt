// lib/services/prompt_data_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PromptDataService {
  static const String _cacheKey = 'cached_prompts_list';
  static const String _defaultUrl =
      'https://raw.githubusercontent.com/surajchaurasia84/Try-Prompt/main/prompts.json';

  // ── Bundled default prompts (guarantees offline & instant screen loading) ─
  static final List<Map<String, dynamic>> _defaultPrompts = [
    {
      'docId': 'p_1',
      'title': 'Neon Cyberpunk Street',
      'category': 'Cyberpunk',
      'type': 'Cyberpunk',
      'imageUrl': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&q=80',
      'prompt': 'A futuristic cyberpunk street at night with neon pink and blue signs reflecting on wet asphalt, cinematic lighting, ultra-detailed 8K, moody atmosphere, ray tracing.',
      'createdAt': DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_2',
      'title': 'Retro 90s Saree Portrait',
      'category': 'Portrait',
      'type': 'Portrait',
      'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
      'prompt': 'Vintage 90s style portrait of a graceful woman in an ornate silk saree, Kodak Portra 400 film grain, soft warm sunlight, retro Bollywood aesthetic, delicate bokeh.',
      'createdAt': DateTime.now().subtract(const Duration(minutes: 15)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_3',
      'title': 'Mystic Golden Forest',
      'category': 'Nature',
      'type': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80',
      'prompt': 'Magical ancient redwood forest during golden hour, majestic sunbeams cutting through morning mist, glowing fireflies, lush green moss, unreal engine 5 render.',
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_4',
      'title': 'Cyber Samurai Warrior',
      'category': 'Trending',
      'type': 'Trending',
      'imageUrl': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&q=80',
      'prompt': 'Futuristic robotic samurai wearing carbon fiber armor with glowing crimson katana, dynamic battle stance in rain, hyper-realistic, volumetric smoke, Octane render.',
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_5',
      'title': 'Cute 3D Pixar Creature',
      'category': '3D Art',
      'type': '3D Art',
      'imageUrl': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800&q=80',
      'prompt': 'Adorable fluffy fantasy creature with large sparkling eyes, Pixar animation style, soft studio rim lighting, 3D clay render, vibrant playful colors, 8k resolution.',
      'createdAt': DateTime.now().subtract(const Duration(hours: 3)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_6',
      'title': 'Anime Tokyo Rainy Sunset',
      'category': 'Anime',
      'type': 'Anime',
      'imageUrl': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800&q=80',
      'prompt': 'Makoto Shinkai anime aesthetic, quiet train station platform in Tokyo at sunset after summer rain, pastel clouds, glowing puddles, nostalgic peaceful feeling.',
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_7',
      'title': 'Celestial Cosmic Goddess',
      'category': 'Fantasy',
      'type': 'Fantasy',
      'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&q=80',
      'prompt': 'Ethereal cosmic goddess draped in shimmering nebulae and stardust, constellation halo, deep space background, bioluminescent glow, hyper-detailed digital oil painting.',
      'createdAt': DateTime.now().subtract(const Duration(hours: 8)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_8',
      'title': 'Cinematic Film Noir Detective',
      'category': 'Cinematic',
      'type': 'Cinematic',
      'imageUrl': 'https://images.unsplash.com/photo-1509114397022-ed747cca3f65?w=800&q=80',
      'prompt': '1940s detective in a trench coat standing beneath a street lamp in fog, high contrast black and white film photography, dramatic Venetian blind shadows, moody noir.',
      'createdAt': DateTime.now().subtract(const Duration(hours: 12)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_9',
      'title': 'Vibrant Watercolor Meadow',
      'category': 'Nature',
      'type': 'Nature',
      'imageUrl': 'https://images.unsplash.com/photo-1470240731273-7821a6eeb6bd?w=800&q=80',
      'prompt': 'Dreamy wildflower meadow with rolling hills in spring, loose impressionist watercolor style, pastel color palette, soft paper texture, gentle morning breeze.',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_10',
      'title': 'Futuristic Mecha Cityscape',
      'category': 'Trending',
      'type': 'Trending',
      'imageUrl': 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=800&q=80',
      'prompt': 'Towering vertical cyberpunk megacity with flying vehicles and glowing holographic advertisements, sunset sky, photorealistic matte painting, intricate architectural detail.',
      'createdAt': DateTime.now().subtract(const Duration(days: 1, hours: 4)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_11',
      'title': 'Studio Fashion Portrait',
      'category': 'Portrait',
      'type': 'Portrait',
      'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
      'prompt': 'High fashion magazine cover portrait, bold neon gel lighting, sharp focus on eyes, dramatic shadows, editorial photography, flawless skin tone, 85mm lens.',
      'createdAt': DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
    },
    {
      'docId': 'p_12',
      'title': 'Steampunk Airship Explorer',
      'category': 'Fantasy',
      'type': 'Fantasy',
      'imageUrl': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=800&q=80',
      'prompt': 'Ornate brass and copper Victorian airship flying above clouds, spinning cogs and steam vents, warm sunset glow, adventurous atmospheric concept art, ArtStation trending.',
      'createdAt': DateTime.now().subtract(const Duration(days: 2, hours: 6)).millisecondsSinceEpoch,
    },
  ];

  /// Fetch all prompts.
  /// 1. Return cached prompts immediately if present.
  /// 2. If empty, load bundled default prompts.
  /// 3. In the background, fetch remote static JSON if available.
  static Future<List<Map<String, dynamic>>> fetchAllPrompts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);

      List<Map<String, dynamic>> prompts = [];

      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedJson) as List<dynamic>;
          prompts = decoded
              .map((e) => _normalizePrompt(Map<String, dynamic>.from(e as Map)))
              .toList();
        } catch (_) {}
      }

      // If cache is empty, seed with rich default prompts
      if (prompts.isEmpty) {
        prompts = List<Map<String, dynamic>>.from(
          _defaultPrompts.map((p) => Map<String, dynamic>.from(p)),
        );
        // Save seed to cache for instant future loads
        await prefs.setString(_cacheKey, jsonEncode(prompts));
      }

      // Background remote check (silent non-blocking update)
      _fetchRemoteInBackground();

      return prompts;
    } catch (e) {
      debugPrint('Error loading prompts: $e');
      return List<Map<String, dynamic>>.from(
        _defaultPrompts.map((p) => Map<String, dynamic>.from(p)),
      );
    }
  }

  static Future<void> _fetchRemoteInBackground() async {
    try {
      final res = await http
          .get(Uri.parse(_defaultUrl))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic>? rawList;
        if (decoded is Map<String, dynamic> && decoded['prompts'] is List) {
          rawList = decoded['prompts'] as List;
        } else if (decoded is List) {
          rawList = decoded;
        }

        if (rawList != null && rawList.isNotEmpty) {
          final list = rawList
              .map((e) => _normalizePrompt(Map<String, dynamic>.from(e as Map)))
              .toList();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, jsonEncode(list));
        }
      }
    } catch (_) {
      // Remote silent fallback
    }
  }

  static Map<String, dynamic> _normalizePrompt(Map<String, dynamic> raw) {
    final docId = (raw['docId'] ?? raw['id'] ?? 'p_${raw.hashCode}').toString();
    final title = (raw['title'] as String?)?.trim() ?? 'Untitled';
    final prompt = (raw['prompt'] as String?)?.trim() ?? '';
    final imageUrl = (raw['imageUrl'] ?? raw['image'] as String?)?.trim() ?? '';
    
    String category = 'Trending';
    if (raw['categories'] is List && (raw['categories'] as List).isNotEmpty) {
      category = (raw['categories'] as List).first.toString();
    } else if (raw['category'] != null && raw['category'].toString().isNotEmpty) {
      category = raw['category'].toString();
    }

    final type = (raw['type'] != null && raw['type'].toString().isNotEmpty)
        ? raw['type'].toString()
        : category;

    final createdAt = raw['createdAt'] is int
        ? raw['createdAt']
        : DateTime.now().millisecondsSinceEpoch;

    return {
      'docId': docId,
      'title': title,
      'prompt': prompt,
      'imageUrl': imageUrl,
      'image': imageUrl,
      'category': category,
      'type': type,
      'createdAt': createdAt,
      'link': raw['link']?.toString() ?? '',
    };
  }
}
