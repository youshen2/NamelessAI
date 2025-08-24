import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() {
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    appConfig.completeOnboarding();
    if (mounted) {
      context.go('/');
    }
  }

  List<Widget> _buildPages(
      BuildContext context, AppLocalizations localizations) {
    return [
      _buildWelcomePage(context, localizations),
      _buildSettingsPage(context, localizations),
      _buildFinishPage(context, localizations),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final pages = _buildPages(context, localizations);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: pages,
                  ),
                ),
                _buildBottomBar(context, localizations, pages.length),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, AppLocalizations localizations, int pageCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage == 0
              ? TextButton(
                  onPressed: _onFinish,
                  child: Text(localizations.skip),
                )
              : TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: Text(localizations.back),
                ),
          Row(
            children: List.generate(pageCount, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              );
            }),
          ),
          _currentPage < pageCount - 1
              ? FilledButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: Text(localizations.next),
                )
              : FilledButton(
                  onPressed: _onFinish,
                  child: Text(localizations.getStarted),
                ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(
      BuildContext context, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icon/icon.svg',
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            localizations.appName,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.welcomeMessage,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage(
      BuildContext context, AppLocalizations localizations) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          localizations.quickSettings,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Text(localizations.language,
            style: Theme.of(context).textTheme.titleMedium),
        RadioListTile<Locale?>(
          title: Text(localizations.systemDefault),
          value: null,
          groupValue: appConfig.locale,
          onChanged: (value) => appConfig.setLocale(value),
        ),
        RadioListTile<Locale?>(
          title: Text(localizations.english),
          value: const Locale('en'),
          groupValue: appConfig.locale,
          onChanged: (value) => appConfig.setLocale(value),
        ),
        RadioListTile<Locale?>(
          title: Text(localizations.chinese),
          value: const Locale('zh'),
          groupValue: appConfig.locale,
          onChanged: (value) => appConfig.setLocale(value),
        ),
        const SizedBox(height: 16),
        Text(localizations.theme,
            style: Theme.of(context).textTheme.titleMedium),
        RadioListTile<ThemeMode>(
          title: Text(localizations.systemDefault),
          value: ThemeMode.system,
          groupValue: appConfig.themeMode,
          onChanged: (value) => appConfig.setThemeMode(value!),
        ),
        RadioListTile<ThemeMode>(
          title: Text(localizations.light),
          value: ThemeMode.light,
          groupValue: appConfig.themeMode,
          onChanged: (value) => appConfig.setThemeMode(value!),
        ),
        RadioListTile<ThemeMode>(
          title: Text(localizations.dark),
          value: ThemeMode.dark,
          groupValue: appConfig.themeMode,
          onChanged: (value) => appConfig.setThemeMode(value!),
        ),
      ],
    );
  }

  Widget _buildFinishPage(
      BuildContext context, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.api_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            localizations.readyToGo,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.readyToGoMessage,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
