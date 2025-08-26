import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appConfig = Provider.of<AppConfigProvider>(context, listen: false);
    final pageDecoration = PageDecoration(
      titleTextStyle: Theme.of(context)
          .textTheme
          .headlineMedium!
          .copyWith(fontWeight: FontWeight.bold),
      bodyTextStyle: Theme.of(context).textTheme.bodyLarge!,
      pageColor: Theme.of(context).colorScheme.background,
      imagePadding: const EdgeInsets.all(24.0),
      bodyPadding: const EdgeInsets.all(16.0),
    );

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: localizations.onboardingWelcomeTitle,
          body: localizations.onboardingWelcomeBody,
          image: const Icon(Icons.waving_hand, size: 100),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: localizations.onboardingAppearanceTitle,
          body: localizations.onboardingAppearanceBody,
          image: const Icon(Icons.palette_outlined, size: 100),
          decoration: pageDecoration,
          footer: Consumer<AppConfigProvider>(
            builder: (context, config, child) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(localizations.light),
                    value: ThemeMode.light,
                    groupValue: config.themeMode,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      config.setThemeMode(value!);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(localizations.dark),
                    value: ThemeMode.dark,
                    groupValue: config.themeMode,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      config.setThemeMode(value!);
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(localizations.systemDefault),
                    value: ThemeMode.system,
                    groupValue: config.themeMode,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      config.setThemeMode(value!);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: Text(localizations.enableBlurEffect),
                    subtitle: Text(localizations.enableBlurEffectHint),
                    value: config.enableBlurEffect,
                    onChanged: (value) {
                      HapticService.onSwitchToggle(context);
                      config.setEnableBlurEffect(value);
                    },
                  ),
                ],
              );
            },
          ),
        ),
        PageViewModel(
          title: localizations.onboardingReadyTitle,
          body: localizations.onboardingReadyBody,
          image: const Icon(Icons.rocket_launch_outlined, size: 100),
          decoration: pageDecoration,
        ),
      ],
      onDone: () {
        HapticService.onButtonPress(context);
        appConfig.completeOnboarding();
        context.go('/');
      },
      showSkipButton: true,
      skip: Text(localizations.skip),
      next: const Icon(Icons.arrow_forward),
      done: Text(localizations.done,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).colorScheme.primary,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
