import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkymkhApp());
}

const Color _primaryColor = Color(0xFF071622);

@visibleForTesting
const List<NavigationTab> navigationTabs = <NavigationTab>[
  NavigationTab(
    title: 'الرئيسية',
    appBarTitle: 'SKY MKH',
    icon: Icons.home_outlined,
    url: 'https://skymkh.com/?page_id=192',
  ),
  NavigationTab(
    title: 'الدروس',
    appBarTitle: 'الدروس',
    icon: Icons.menu_book_outlined,
    url: 'https://skymkh.com/?page_id=1096',
  ),
  NavigationTab(
    title: 'الأدوات',
    appBarTitle: 'الأدوات',
    icon: Icons.explore_outlined,
    url: 'https://skymkh.com/?page_id=1082',
  ),
  NavigationTab(
    title: 'الاختبارات',
    appBarTitle: 'الاختبارات',
    icon: Icons.quiz_outlined,
    url: 'https://skymkh.com/?page_id=1170',
  ),
  NavigationTab(
    title: 'الحساب',
    appBarTitle: 'حسابي',
    icon: Icons.person_outline,
    url: 'https://skymkh.com/?page_id=484',
  ),
];

class SkymkhApp extends StatelessWidget {
  const SkymkhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SKY MKH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          primary: _primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF8FA0B9),
          backgroundColor: _primaryColor,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          primary: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF040B12),
        appBarTheme: const AppBarTheme(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF8FA0B9),
          backgroundColor: _primaryColor,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const SkymkhHome(),
    );
  }
}

class SkymkhHome extends StatefulWidget {
  const SkymkhHome({super.key});

  @override
  State<SkymkhHome> createState() => _SkymkhHomeState();
}

class _SkymkhHomeState extends State<SkymkhHome> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      params = AndroidWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _setLoading(true),
          onPageFinished: (_) => _setLoading(false),
          onWebResourceError: (error) {
            debugPrint(
              'WebView error (${navigationTabs[_currentIndex].title}): ${error.description}',
            );
            _setLoading(false);
          },
        ),
      )
      ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      )
      ..loadRequest(Uri.parse(navigationTabs.first.url));

    if (controller.platform is AndroidWebViewController) {
      final AndroidWebViewController androidController =
          controller.platform as AndroidWebViewController;
      androidController.setMixedContentMode(MixedContentMode.alwaysAllow);
      androidController.setMediaPlaybackRequiresUserGesture(false);
    } else if (controller.platform is WebKitWebViewController) {
      final WebKitWebViewController webKitController =
          controller.platform as WebKitWebViewController;
      webKitController.setAllowsBackForwardNavigationGestures(true);
    }

    _controller = controller;
  }

  void _setLoading(bool visible) {
    if (!mounted || _isLoading == visible) {
      return;
    }
    setState(() {
      _isLoading = visible;
    });
  }

  Future<void> _onTabSelected(int index) async {
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      _currentIndex = index;
      _isLoading = true;
    });
    await _controller.loadRequest(Uri.parse(navigationTabs[index].url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(navigationTabs[_currentIndex].appBarTitle),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const DecoratedBox(
              decoration: BoxDecoration(color: Color(0x1A071622)),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: navigationTabs
            .map(
              (NavigationTab tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.title,
              ),
            )
            .toList(),
      ),
    );
  }
}

class NavigationTab {
  const NavigationTab({
    required this.title,
    required this.appBarTitle,
    required this.icon,
    required this.url,
  });

  final String title;
  final String appBarTitle;
  final IconData icon;
  final String url;
}
