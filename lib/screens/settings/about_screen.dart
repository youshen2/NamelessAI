import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nameless_ai/services/update_service.dart';
import 'package:nameless_ai/utils/helpers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  int _tapCount = 0;
  bool _isCheckingForUpdate = false;

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  void _handleTap() {
    HapticService.onButtonPress(context);
    setState(() {
      _tapCount++;
    });
    if (_tapCount >= 7) {
      _tapCount = 0;
      if (mounted) {
        context.go('/settings/developer_options');
      }
    }
  }

  void _handleLongPress() {
    HapticService.onLongPress(context);
    _animationController.forward(from: 0.0);
    showSnackBar(context, AppLocalizations.of(context)!.easterEgg);
  }

  Future<void> _checkForUpdate() async {
    HapticService.onButtonPress(context);
    if (mounted) {
      setState(() {
        _isCheckingForUpdate = true;
      });
    }
    await UpdateService().check(context, showNoUpdateDialog: true);
    if (mounted) {
      setState(() {
        _isCheckingForUpdate = false;
      });
    }
  }

  Widget _buildBlurBackground(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    if (!appConfig.enableBlurEffect) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.about),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            0,
            kToolbarHeight + MediaQuery.of(context).padding.top + 24,
            0,
            isDesktop ? 24 : 96),
        children: <Widget>[
          Column(
            children: [
              GestureDetector(
                onLongPress: _handleLongPress,
                child: RotationTransition(
                  turns: _rotationAnimation,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: SvgPicture.asset(
                      'assets/icon/icon.svg',
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Nameless AI Box",
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _handleTap,
                child: Text(
                  '${localizations.version} ${_packageInfo.version} (${_packageInfo.buildNumber})',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(localizations.developer),
                subtitle: Text(localizations.developerName),
                onTap: () {
                  HapticService.onButtonPress(context);
                  launchUrl(Uri.parse('https://${localizations.developerUrl}'));
                },
                trailing: const Icon(Icons.open_in_new_rounded),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.code_rounded),
                    title: Text(localizations.sourceCode),
                    subtitle: Text(localizations.sourceCodeUrl),
                    onTap: () {
                      HapticService.onButtonPress(context);
                      launchUrl(
                          Uri.parse('https://${localizations.sourceCodeUrl}'));
                    },
                    trailing: const Icon(Icons.open_in_new_rounded),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.gavel_rounded),
                    title: Text(localizations.openSourceLicenses),
                    onTap: () {
                      HapticService.onButtonPress(context);
                      showLicensePage(
                        context: context,
                        applicationName: "Nameless AI Box",
                        applicationVersion: _packageInfo.version,
                        applicationIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/icon/icon.svg',
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      );
                    },
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.system_update_alt_rounded),
                    title: Text(localizations.checkForUpdates),
                    trailing: _isCheckingForUpdate
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: _isCheckingForUpdate ? null : _checkForUpdate,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.policy_rounded),
                title: Text(localizations.apacheLicense),
                onTap: () {
                  HapticService.onButtonPress(context);
                  launchUrl(
                      Uri.parse('https://${localizations.apacheLicenseUrl}'));
                },
                trailing: const Icon(Icons.open_in_new_rounded),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              localizations.madeWith,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
