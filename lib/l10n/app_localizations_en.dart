// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nameless AI Box';

  @override
  String get chat => 'Chat';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get newChat => 'New Chat';

  @override
  String get saveChat => 'Save Chat';

  @override
  String get sendMessage => 'Send message...';

  @override
  String get modelSelection => 'Model Selection';

  @override
  String get systemPrompt => 'System Prompt';

  @override
  String get enterSystemPrompt => 'Enter system prompt...';

  @override
  String get apiProviderSettings => 'API Providers';

  @override
  String get systemPromptTemplates => 'Prompt Templates';

  @override
  String get taskSettings => 'Task Settings';

  @override
  String get asyncTaskRefreshInterval =>
      'Async Task Refresh Interval (seconds)';

  @override
  String get asyncTaskRefreshIntervalHint =>
      'For image/video generation. Set to 0 to disable.';

  @override
  String get compatibilityMode => 'Compatibility Mode';

  @override
  String get compatibilityModeMidjourney => 'Midjourney Proxy';

  @override
  String get saveToGallery => 'Save to Gallery';

  @override
  String get saveSuccess => 'Image saved to gallery.';

  @override
  String saveError(String error) {
    return 'Failed to save image: $error';
  }

  @override
  String get rawResponse => 'Raw Response';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get imageModeInstant => 'Mode: Instant';

  @override
  String get imageModeAsync => 'Mode: Asynchronous';

  @override
  String get streamable => 'Stream';

  @override
  String get addProvider => 'Add Provider';

  @override
  String get editProvider => 'Edit Provider';

  @override
  String get deleteProvider => 'Delete Provider';

  @override
  String get providerName => 'Provider Name';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get apiKey => 'API Key';

  @override
  String get chatPath => 'Chat Path';

  @override
  String get models => 'Models';

  @override
  String get addModel => 'Add Model';

  @override
  String get editModel => 'Edit Model';

  @override
  String get modelName => 'Model Name';

  @override
  String get maxTokens => 'Max Tokens (Optional)';

  @override
  String get isStreamable => 'Supports Streaming';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String deleteConfirmation(Object itemType) {
    return 'Are you sure you want to delete this $itemType?';
  }

  @override
  String get addTemplate => 'Add Template';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get deleteTemplate => 'Delete Template';

  @override
  String get templateName => 'Template Name';

  @override
  String get templatePrompt => 'Template Prompt';

  @override
  String get noProvidersAdded =>
      'No API providers added yet. Go to Settings to add one.';

  @override
  String get noModelsConfigured => 'No models configured for this provider.';

  @override
  String get noChatHistory => 'No chat history yet. Start a new chat!';

  @override
  String get noSystemPromptTemplates =>
      'No system prompt templates yet. Add one!';

  @override
  String get editMessage => 'Edit Message';

  @override
  String get deleteMessage => 'Delete Message';

  @override
  String get message => 'message';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get freeCopy => 'Free Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard!';

  @override
  String get error => 'Error';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get providerNameRequired => 'Provider name is required.';

  @override
  String get baseUrlRequired => 'Base URL is required.';

  @override
  String get apiKeyRequired => 'API Key is required.';

  @override
  String get chatPathRequired => 'Chat path is required.';

  @override
  String get modelNameRequired => 'Model name is required.';

  @override
  String get templateNameRequired => 'Template name is required.';

  @override
  String get templatePromptRequired => 'Template prompt is required.';

  @override
  String get chatName => 'Chat Name';

  @override
  String get enterChatName => 'Enter chat name...';

  @override
  String get chatSaved => 'Chat saved successfully!';

  @override
  String get chatNameRequired => 'Chat name is required.';

  @override
  String get selectModel => 'Select a model to start chatting.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get theme => 'Theme';

  @override
  String get systemDefault => 'System Default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get monetTheming => 'Monet Theming (Android 12+)';

  @override
  String get enableMonet => 'Enable Monet Theming';

  @override
  String get saveAndResubmit => 'Save & Resubmit';

  @override
  String get editChatName => 'Edit Chat Name';

  @override
  String get sendKeySettings => 'Send Key Setting';

  @override
  String get sendWithEnter => 'Enter';

  @override
  String get sendWithCtrlEnter => 'Ctrl+Enter';

  @override
  String get sendWithShiftCtrlEnter => 'Shift+Ctrl+Enter';

  @override
  String get shortcutInEditMode => 'Use shortcut in edit mode';

  @override
  String get chatSettings => 'Chat Settings';

  @override
  String get temperature => 'Temperature';

  @override
  String get topP => 'Top P';

  @override
  String get useStreaming => 'Use Streaming';

  @override
  String get overrideModelSettings => 'Use default model settings';

  @override
  String get streamingDefault => 'Default';

  @override
  String get streamingOn => 'On';

  @override
  String get streamingOff => 'Off';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get developerOptions => 'Developer Options';

  @override
  String get showStatistics => 'Show Statistics';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearDataConfirmation =>
      'This will delete all providers, chats, and settings. This action cannot be undone. Are you sure?';

  @override
  String get dataCleared => 'All data has been cleared.';

  @override
  String get totalTime => 'Total Time';

  @override
  String get firstChunkTime => 'Time to First Chunk';

  @override
  String get tokens => 'Tokens';

  @override
  String get prompt => 'Prompt';

  @override
  String get completion => 'Completion';

  @override
  String get outputCharacters => 'Output Characters';

  @override
  String get showTotalTime => 'Show Total Time';

  @override
  String get showFirstChunkTime => 'Show Time to First Chunk';

  @override
  String get showTokenUsage => 'Show Token Usage';

  @override
  String get showOutputCharacters => 'Show Output Characters';

  @override
  String thinking(String duration) {
    return 'Thinking... $duration';
  }

  @override
  String thinkingTimeTaken(String duration) {
    return 'Thinking time: $duration';
  }

  @override
  String get thinkingTitle => 'Thinking';

  @override
  String get maxContextMessages => 'Max Context Messages';

  @override
  String get maxContextMessagesHint =>
      'Number of recent messages to send (0 or empty = unlimited)';

  @override
  String get appearanceSettings => 'Appearance';

  @override
  String get statisticsSettings => 'Statistics Display';

  @override
  String get scrollSettings => 'Scroll Settings';

  @override
  String get disableAutoScrollOnUp => 'Disable auto-scroll on manual scroll';

  @override
  String get resumeAutoScrollOnBottom => 'Resume auto-scroll when at bottom';

  @override
  String get search => 'Search';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get stopGenerating => 'Stop Generating';

  @override
  String get chatDisplay => 'Chat Display';

  @override
  String get fontSize => 'Font Size';

  @override
  String get small => 'Small';

  @override
  String get medium => 'Medium';

  @override
  String get large => 'Large';

  @override
  String get chatBubbleAlignment => 'Chat Bubble Alignment';

  @override
  String get normal => 'Normal';

  @override
  String get center => 'Center';

  @override
  String get showTimestamps => 'Show Timestamps';

  @override
  String get chatBubbleWidth => 'Chat Bubble Width';

  @override
  String get compactMode => 'Compact Mode';

  @override
  String get compactModeHint => 'Reduces padding and margins for a denser UI.';

  @override
  String get showModelName => 'Show Model Name';

  @override
  String get showModelNameHint =>
      'Display the model name under each AI response.';

  @override
  String get regenerateResponse => 'Regenerate';

  @override
  String get copyMessage => 'Copy';

  @override
  String get selectTemplate => 'Select a Template';

  @override
  String get searchTemplates => 'Search templates...';

  @override
  String get noTemplatesFound => 'No templates found.';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get reinitializeDatabase => 'Re-initialize Database';

  @override
  String get reinitializeDatabaseWarning =>
      'This is a destructive action for debugging. It will re-register database adapters. The app may need to be restarted. Continue?';

  @override
  String get databaseReinitialized =>
      'Database re-initialized. Please restart the app.';

  @override
  String get generalSettings => 'General';

  @override
  String itemDeleted(String itemName) {
    return '$itemName has been deleted.';
  }

  @override
  String get exportSuccess => 'Data exported successfully.';

  @override
  String exportError(String error) {
    return 'Error exporting data: $error';
  }

  @override
  String get importSuccess =>
      'Data imported successfully. Please restart the app to see the changes.';

  @override
  String importError(String error) {
    return 'Error importing data: $error';
  }

  @override
  String get importConfirmation =>
      'This will overwrite all current data. This action cannot be undone. Are you sure you want to restore from a backup?';

  @override
  String get useFirstSentenceAsTitle => 'Use first message as title';

  @override
  String get useFirstSentenceAsTitleHint =>
      'Automatically use the first sent message as the chat title.';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get modelLabel => 'Model';

  @override
  String get timeLabel => 'Time';

  @override
  String get reverseBubbleAlignment => 'Reverse Bubble Alignment';

  @override
  String get reverseBubbleAlignmentHint =>
      'User messages on the left, AI on the right';

  @override
  String get exportSettings => 'Export Settings';

  @override
  String get selectContentToExport => 'Select content to export';

  @override
  String get appSettings => 'App Settings';

  @override
  String get codeBlockTheme => 'Code Block Theme';

  @override
  String get showDebugButton => 'Show Debug Button';

  @override
  String get showDebugButtonHint =>
      'Show a debug button on message bubbles to inspect data.';

  @override
  String get debugInfo => 'Debug Info';

  @override
  String get scrollToTop => 'Scroll to top';

  @override
  String get scrollToBottom => 'Scroll to bottom';

  @override
  String get pageUp => 'Previous Message';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get checkForUpdatesOnStartup => 'Check for updates on startup';

  @override
  String updateAvailable(String version) {
    return 'Update Available: v$version';
  }

  @override
  String get newVersionMessage => 'A new version of NamelessAI is available.';

  @override
  String get releaseNotes => 'Release Notes:';

  @override
  String get later => 'Later';

  @override
  String get update => 'Update';

  @override
  String get close => 'Close';

  @override
  String get noUpdates => 'No Updates';

  @override
  String get latestVersionMessage => 'You are using the latest version.';

  @override
  String updateCheckFailed(String error) {
    return 'Failed to check for updates: $error';
  }

  @override
  String get sourceCode => 'Source Code';

  @override
  String get sourceCodeUrl => 'github.com/youshen2/NamelessAI';

  @override
  String get openSourceLicenses => 'Open-source Licenses';

  @override
  String get madeWith => 'Made with Flutter';

  @override
  String get collapse => 'Collapse';

  @override
  String get expand => 'Expand';

  @override
  String get unsupportedModelTypeInChat =>
      'This model type is not supported in chat.';

  @override
  String get modelTypeLanguage => 'Language';

  @override
  String get modelTypeImage => 'Image';

  @override
  String get modelTypeVideo => 'Video';

  @override
  String get modelTypeTts => 'TTS';

  @override
  String get imageSize => 'Image Size';

  @override
  String get imageQuality => 'Image Quality';

  @override
  String get imageStyle => 'Image Style';

  @override
  String get qualityStandard => 'Standard';

  @override
  String get qualityHD => 'HD';

  @override
  String get styleVivid => 'Vivid';

  @override
  String get styleNatural => 'Natural';

  @override
  String get imageGenerationMode => 'Image Generation Mode';

  @override
  String get instant => 'Instant';

  @override
  String get asynchronous => 'Asynchronous';

  @override
  String get midjourney => 'Midjourney';

  @override
  String get imaginePath => 'Imagine Path (Optional)';

  @override
  String get fetchPath => 'Fetch Path (Optional)';

  @override
  String get taskSubmitted => 'Task submitted';

  @override
  String get taskInProgress => 'In Progress';

  @override
  String get taskFailed => 'Failed';

  @override
  String get taskSuccess => 'Success';

  @override
  String get refresh => 'Refresh';

  @override
  String get imageGenerationFailed => 'Image generation failed';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String refreshingIn(String seconds) {
    return 'Auto-refresh in ${seconds}s';
  }

  @override
  String get requestError => 'Request Error';

  @override
  String get unknownErrorOccurred => 'An unknown error occurred';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get ok => 'OK';

  @override
  String get asyncImaginePathHint => 'e.g., /mj/submit/imagine';

  @override
  String asyncFetchPathHint(String taskId) {
    return 'e.g., /mj/task/$taskId/fetch';
  }

  @override
  String get taskStatus => 'Status';

  @override
  String get midjourneyPromptHint =>
      'Enter prompt, you can add parameters like --ar 16:9';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearHistoryConfirmation =>
      'Are you sure you want to delete all chat history? This action cannot be undone.';

  @override
  String get jsonDebugViewer => 'JSON Viewer';

  @override
  String get searchHint => 'Search...';

  @override
  String get historyCleared => 'History has been cleared.';

  @override
  String get imageExpirationWarning =>
      'Image may expire, please save it in time.';

  @override
  String get imageGenerationPathHint => 'e.g., /v1/images/generations';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get resetOnboardingHint =>
      'This will show the onboarding screen on the next app launch.';

  @override
  String get reset => 'Reset';

  @override
  String get resetOnboardingConfirmation =>
      'Are you sure you want to reset the onboarding status?';

  @override
  String get apiPathTemplate => 'API Path Template';

  @override
  String get selectApiPathTemplate => 'Select a Template';

  @override
  String get apiPathTemplateQingyunTop => 'Qingyun Top';

  @override
  String get apiPathTemplateStandardOpenAI => 'Standard OpenAI';

  @override
  String get apiPathTemplateStandardInstantImage => 'Standard Instant Image';

  @override
  String get apiPathTemplateStandardMidjourney => 'Standard Midjourney';

  @override
  String get nonLanguageModelPathWarning =>
      'Please ensure the API path is correct before use.';

  @override
  String get noApiPathTemplatesFound => 'No API path templates found.';

  @override
  String get searchApiPathTemplates => 'Search templates...';

  @override
  String get chatPathHint => 'e.g., /v1/chat/completions';

  @override
  String get createVideoPath => 'Create Video Path (Optional)';

  @override
  String get queryVideoPath => 'Query Video Path (Optional)';

  @override
  String get createVideoPathHint => 'e.g., /v1/video/create';

  @override
  String get queryVideoPathHint => 'e.g., /v1/video/query';

  @override
  String get apiPathTemplateQingyunTopVeo => 'Qingyun Top - Veo Universal';

  @override
  String get enhancedPrompt => 'Enhanced Prompt';

  @override
  String get videoUrl => 'Video URL';

  @override
  String get copyUrl => 'Copy URL';

  @override
  String get playVideo => 'Play Video';

  @override
  String get videoGenerationFailed => 'Video generation failed';

  @override
  String get failedToLoadVideo => 'Failed to load video';

  @override
  String get videoExpirationWarning =>
      'File is valid for 2 days, please download it in time.';

  @override
  String get hapticSettings => 'Haptic Feedback';

  @override
  String get enableHapticFeedback => 'Enable Haptic Feedback';

  @override
  String get hapticIntensity => 'Haptic Intensity';

  @override
  String get hapticIntensityNone => 'None';

  @override
  String get hapticIntensityLight => 'Light';

  @override
  String get hapticIntensityMedium => 'Medium';

  @override
  String get hapticIntensityHeavy => 'Heavy';

  @override
  String get hapticIntensitySelection => 'Default';

  @override
  String get hapticButtonPress => 'Button Press';

  @override
  String get hapticSwitchToggle => 'Switch Toggle';

  @override
  String get hapticLongPress => 'Long Press';

  @override
  String get hapticSliderChanged => 'Slider Change';

  @override
  String get hapticsNotSupported =>
      'Haptic feedback is not supported on this platform.';

  @override
  String get hapticStreamOutput => 'Stream Output';

  @override
  String get hapticThinking => 'Thinking';

  @override
  String get importFromNamelessAI => 'From NamelessAI';

  @override
  String get importFromChatBox => 'From ChatBox';

  @override
  String get importPreview => 'Import Preview';

  @override
  String get selectItemsToImport => 'Select items to import:';

  @override
  String get importMode => 'Import Mode';

  @override
  String get mergeData => 'Merge';

  @override
  String get replaceData => 'Replace';

  @override
  String get mergeDataHint => 'Add data to existing content.';

  @override
  String get replaceDataHint => 'Delete existing data before importing.';

  @override
  String get skipped => 'Skipped';

  @override
  String get warning => 'Warning';

  @override
  String get unsupportedData => 'Unsupported data type, will be skipped.';

  @override
  String get noSystemPrompt => 'No system prompt';

  @override
  String get import => 'Import';

  @override
  String get onboardingReset => 'Onboarding has been reset.';

  @override
  String get defaultStartupPage => 'Default Startup Page';

  @override
  String get restoreLastSession => 'Restore last session on startup';

  @override
  String get restoreLastSessionHint =>
      'If disabled, a new chat will be started every time.';

  @override
  String get importOptions => 'Import Options';

  @override
  String get importing => 'Importing...';

  @override
  String get parsingFile => 'Parsing file...';

  @override
  String importFrom(String source) {
    return 'Import from $source';
  }

  @override
  String get namelessAiSource => 'NamelessAI';

  @override
  String get chatBoxSource => 'ChatBox';

  @override
  String get dataToImport => 'Data to import';

  @override
  String get cornerRadius => 'Corner Radius';

  @override
  String get cornerRadiusHint =>
      'Adjust the roundness of UI elements like cards and buttons.';

  @override
  String get enableBlurEffect => 'Enable Blur Effect';

  @override
  String get enableBlurEffectHint =>
      'Applies a blur effect to some UI elements like the navigation bar.';

  @override
  String get pageTransition => 'Page Transition';

  @override
  String get pageTransitionSystem => 'System Default';

  @override
  String get pageTransitionSlide => 'Slide';

  @override
  String get pageTransitionFade => 'Fade';

  @override
  String get pageTransitionScale => 'Scale';

  @override
  String get onboardingTitle => 'Setup';

  @override
  String get onboardingPage1Title => 'Welcome to Nameless AI';

  @override
  String get onboardingPage1Body =>
      'A concise and powerful cross-platform AI client. Let\'s get you set up.';

  @override
  String get onboardingPage2Title => 'Appearance';

  @override
  String get onboardingPage2Body =>
      'Customize the look and feel of the app to your liking.';

  @override
  String get onboardingPage3Title => 'Preferences';

  @override
  String get onboardingPage3Body =>
      'Set up your preferred way of interacting with the app.';

  @override
  String get onboardingPage4Title => 'You\'re All Set!';

  @override
  String get onboardingPage4Body =>
      'You\'re ready to start chatting. Remember to add an API Provider in Settings to begin.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingFinish => 'Get Started';

  @override
  String get onboardingSendKey => 'Send Shortcut';

  @override
  String get addProviderManually => 'Add Manually';

  @override
  String get addFromPreset => 'Add from Preset';

  @override
  String get presetOpenAI => 'OpenAI';

  @override
  String get presetGroq => 'Groq';

  @override
  String get presetYi => '01.AI';

  @override
  String get presetMoonshot => 'Moonshot AI (Kimi)';

  @override
  String get presetDeepseek => 'DeepSeek AI';

  @override
  String get crashReport => 'Crash Report';

  @override
  String get errorDetails => 'Error Details';

  @override
  String get stackTrace => 'Stack Trace';

  @override
  String get restartApp => 'Restart App';

  @override
  String get crashTest => 'Crash Test';

  @override
  String get crashTestDescription =>
      'Tap to trigger a test crash and display the error report screen.';

  @override
  String get anErrorOccurred => 'An unexpected error occurred.';

  @override
  String get submitIssue => 'Submit Issue';

  @override
  String get submitIssueDescription =>
      'To help us fix this bug, please consider submitting an issue on GitHub.\nYou can paste the copied information into the issue description.';

  @override
  String get developer => 'Developer';

  @override
  String get developerName => 'Moye';

  @override
  String get developerUrl => 'space.bilibili.com/3946756160';

  @override
  String get easterEgg => 'Ciallo～(∠・ω< )⌒★';
}
