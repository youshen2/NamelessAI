// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NamelessAI';

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
  String get overrideModelSettings => 'Override model settings';

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
  String get displaySettings => 'Display Settings';

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
}
