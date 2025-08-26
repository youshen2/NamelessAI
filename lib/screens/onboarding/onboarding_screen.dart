import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (!mounted) return;
      final newPage = _pageController.page?.round();
      if (newPage != null && newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() {
    HapticService.onButtonPress(context);
    Provider.of<AppConfigProvider>(context, listen: false).completeOnboarding();
    context.go('/');
  }

  void _navigate(int page) {
    HapticService.onButtonPress(context);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context);

    final pages = [
      _buildWelcomePage(context, localizations, appConfig),
      _buildAppearancePage(context, localizations, appConfig),
      _buildPreferencesPage(context, localizations, appConfig),
      _buildFinishPage(context, localizations),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedOpacity(
                  opacity: _currentPage > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _currentPage > 0
                        ? () => _navigate(_currentPage - 1)
                        : null,
                    child: Text(localizations.onboardingBack),
                  ),
                ),
                _buildPageIndicator(pages.length),
                FilledButton(
                  onPressed: _currentPage < pages.length - 1
                      ? () => _navigate(_currentPage + 1)
                      : _onFinish,
                  child: Text(_currentPage < pages.length - 1
                      ? localizations.onboardingNext
                      : localizations.onboardingFinish),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String body,
    Widget? content,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (content != null) ...[
                  const SizedBox(height: 32),
                  content,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context, AppLocalizations localizations,
      AppConfigProvider appConfig) {
    return _buildPage(
      context: context,
      icon: Icons.waving_hand_rounded,
      title: localizations.onboardingPage1Title,
      body: localizations.onboardingPage1Body,
      content: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.language,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<Locale?>(
                segments: [
                  ButtonSegment(
                      value: null, label: Text(localizations.systemDefault)),
                  ButtonSegment(
                      value: const Locale('en'),
                      label: Text(localizations.english)),
                  ButtonSegment(
                      value: const Locale('zh'),
                      label: Text(localizations.chinese)),
                ],
                selected: {appConfig.locale},
                onSelectionChanged: (newSelection) {
                  HapticService.onSwitchToggle(context);
                  appConfig.setLocale(newSelection.first);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearancePage(BuildContext context,
      AppLocalizations localizations, AppConfigProvider appConfig) {
    return _buildPage(
      context: context,
      icon: Icons.palette_outlined,
      title: localizations.onboardingPage2Title,
      body: localizations.onboardingPage2Body,
      content: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.theme,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(localizations.light),
                      icon: const Icon(Icons.light_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(localizations.dark),
                      icon: const Icon(Icons.dark_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(localizations.systemDefault),
                      icon: const Icon(Icons.brightness_auto_outlined)),
                ],
                selected: {appConfig.themeMode},
                onSelectionChanged: (newSelection) {
                  HapticService.onSwitchToggle(context);
                  appConfig.setThemeMode(newSelection.first);
                },
              ),
              const Divider(height: 24),
              SwitchListTile(
                title: Text(localizations.enableBlurEffect),
                value: appConfig.enableBlurEffect,
                onChanged: (value) {
                  HapticService.onSwitchToggle(context);
                  appConfig.setEnableBlurEffect(value);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesPage(BuildContext context,
      AppLocalizations localizations, AppConfigProvider appConfig) {
    return _buildPage(
      context: context,
      icon: Icons.tune_rounded,
      title: localizations.onboardingPage3Title,
      body: localizations.onboardingPage3Body,
      content: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.onboardingSendKey,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              RadioListTile<SendKeyOption>(
                title: Text(localizations.sendWithEnter),
                value: SendKeyOption.enter,
                groupValue: appConfig.sendKeyOption,
                onChanged: (value) {
                  HapticService.onSwitchToggle(context);
                  if (value != null) appConfig.setSendKeyOption(value);
                },
              ),
              RadioListTile<SendKeyOption>(
                title: Text(localizations.sendWithCtrlEnter),
                value: SendKeyOption.ctrlEnter,
                groupValue: appConfig.sendKeyOption,
                onChanged: (value) {
                  HapticService.onSwitchToggle(context);
                  if (value != null) appConfig.setSendKeyOption(value);
                },
              ),
              RadioListTile<SendKeyOption>(
                title: Text(localizations.sendWithShiftCtrlEnter),
                value: SendKeyOption.shiftCtrlEnter,
                groupValue: appConfig.sendKeyOption,
                onChanged: (value) {
                  HapticService.onSwitchToggle(context);
                  if (value != null) appConfig.setSendKeyOption(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishPage(
      BuildContext context, AppLocalizations localizations) {
    return _buildPage(
      context: context,
      icon: Icons.rocket_launch_outlined,
      title: localizations.onboardingPage4Title,
      body: localizations.onboardingPage4Body,
    );
  }
}
