import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'app/brand.dart';
import 'app/theme.dart';
import 'flag_service.dart';
import 'location_service.dart';
import 'screens/home_screen.dart';
import 'webview_page.dart';
import 'widgets/brand_mark.dart';

/// Splash plus the remote-config fork. Every failure path — no network, no
/// flag, unknown country, bad JSON — falls through to the quiz, never an error.
class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage>
    with SingleTickerProviderStateMixin {
  final FlagService _flagService = FlagService();
  final LocationService _locationService = LocationService();

  bool _isLoading = true;
  bool _shouldShowWebView = false;
  String _webViewUrl = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final splashFuture = Future<void>.delayed(
      const Duration(milliseconds: 1500),
    );

    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = connectivity.any((r) => r != ConnectivityResult.none);

    if (!hasInternet) {
      await splashFuture;
      _navigateToApp();
      return;
    }

    final flagFuture = _flagService.init();
    final locationFuture = _locationService.getCountryCode();

    await Future.wait([flagFuture, splashFuture]);
    final countryCode = await locationFuture;

    _handleRouting(countryCode);
  }

  void _handleRouting(String? countryCode) {
    if (!_flagService.showWebView) {
      _navigateToApp();
      return;
    }
    if (countryCode != null &&
        _flagService.webViewConfig.containsKey(countryCode)) {
      _navigateToWebView(_flagService.webViewConfig[countryCode]!);
    } else {
      _navigateToApp();
    }
  }

  void _navigateToApp() {
    if (!mounted) return;
    setState(() {
      _shouldShowWebView = false;
      _isLoading = false;
    });
  }

  void _navigateToWebView(String url) {
    if (!mounted) return;
    setState(() {
      _shouldShowWebView = true;
      _webViewUrl = url;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSplash();
    if (_shouldShowWebView && _webViewUrl.isNotEmpty) {
      return WebviewPage(url: _webViewUrl);
    }
    return const HomeScreen();
  }

  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: cBgDark,
      body: Container(
        decoration: AppTheme.pageBackground,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BrandMark(size: 96),
                const SizedBox(height: 22),
                Text(
                  kAppTitle,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  kSportTitle,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _flagService.close();
    super.dispose();
  }
}
