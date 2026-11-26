import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tabs/home_tab.dart';
import 'tabs/daily_tab.dart';
import 'tabs/favorite_tab.dart';
import 'tabs/menu_tab.dart';
import '../services/favorites_service.dart';
import '../constants/ad_constants.dart';
import '../constants/app_theme.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const MainScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    FavoritesService.loadAppLinks();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _stopSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = "";
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Top Prompt AI Image';
      case 1:
        return 'Search Prompts';
      case 2:
        return 'Saved Prompts';
      case 3:
        return 'Library';
      default:
        return 'Top Prompt';
    }
  }

  String _getAppBarSubtitle() {
    switch (_currentIndex) {
      case 0:
        return 'Welcome App';
      case 1:
        return 'Find prompt templates';
      case 2:
        return 'Your saved templates';
      case 3:
        return 'App settings and customization';
      default:
        return 'Welcome';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      const HomeTab(),
      DailyTab(searchQuery: _searchQuery),
      FavoriteTab(
        isActive: _currentIndex == 2,
      ),
      MenuTab(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: PopScope(
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          
          if (_currentIndex != 0) {
            _stopSearch();
            setState(() {
              _currentIndex = 0;
            });
          }
        },
        child: Scaffold(
        appBar: _currentIndex == 3
            ? null
            : AppBar(
                systemOverlayStyle: overlayStyle,
                leading: null,
                title: _currentIndex == 1
                    ? Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'Search prompts...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              size: 20,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontSize: 14,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getAppBarTitle(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getAppBarSubtitle(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                actions: [
                  if (_currentIndex == 1 && _searchQuery.isNotEmpty) ...[
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: AdWidget(ad: _bannerAd!),
              ),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              padding: EdgeInsets.only(
                top: 10,
                bottom: MediaQuery.of(context).padding.bottom + 10,
                left: 16,
                right: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                  _buildNavItem(1, Icons.search_outlined, Icons.search, 'Search'),
                  _buildNavItem(2, Icons.favorite_border, Icons.favorite, 'Save'),
                  _buildNavItem(3, Icons.grid_view_outlined, Icons.grid_view, 'Menu'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final activeColor = primaryColor;
    final inactiveColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return InkWell(
      onTap: () {
        _stopSearch();
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
