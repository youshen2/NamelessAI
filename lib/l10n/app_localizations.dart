import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NamelessAI'**
  String get appName;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @saveChat.
  ///
  /// In en, this message translates to:
  /// **'Save Chat'**
  String get saveChat;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message...'**
  String get sendMessage;

  /// No description provided for @modelSelection.
  ///
  /// In en, this message translates to:
  /// **'Model Selection'**
  String get modelSelection;

  /// No description provided for @systemPrompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get systemPrompt;

  /// No description provided for @enterSystemPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter system prompt...'**
  String get enterSystemPrompt;

  /// No description provided for @apiProviderSettings.
  ///
  /// In en, this message translates to:
  /// **'API Providers'**
  String get apiProviderSettings;

  /// No description provided for @systemPromptTemplates.
  ///
  /// In en, this message translates to:
  /// **'Prompt Templates'**
  String get systemPromptTemplates;

  /// No description provided for @addProvider.
  ///
  /// In en, this message translates to:
  /// **'Add Provider'**
  String get addProvider;

  /// No description provided for @editProvider.
  ///
  /// In en, this message translates to:
  /// **'Edit Provider'**
  String get editProvider;

  /// No description provided for @deleteProvider.
  ///
  /// In en, this message translates to:
  /// **'Delete Provider'**
  String get deleteProvider;

  /// No description provided for @providerName.
  ///
  /// In en, this message translates to:
  /// **'Provider Name'**
  String get providerName;

  /// No description provided for @baseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @chatPath.
  ///
  /// In en, this message translates to:
  /// **'Chat Path'**
  String get chatPath;

  /// No description provided for @models.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get models;

  /// No description provided for @addModel.
  ///
  /// In en, this message translates to:
  /// **'Add Model'**
  String get addModel;

  /// No description provided for @editModel.
  ///
  /// In en, this message translates to:
  /// **'Edit Model'**
  String get editModel;

  /// No description provided for @modelName.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelName;

  /// No description provided for @maxTokens.
  ///
  /// In en, this message translates to:
  /// **'Max Tokens (Optional)'**
  String get maxTokens;

  /// No description provided for @isStreamable.
  ///
  /// In en, this message translates to:
  /// **'Supports Streaming'**
  String get isStreamable;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this {itemType}?'**
  String deleteConfirmation(Object itemType);

  /// No description provided for @addTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add Template'**
  String get addTemplate;

  /// No description provided for @editTemplate.
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get editTemplate;

  /// No description provided for @deleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get deleteTemplate;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateName;

  /// No description provided for @templatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Template Prompt'**
  String get templatePrompt;

  /// No description provided for @noProvidersAdded.
  ///
  /// In en, this message translates to:
  /// **'No API providers added yet. Go to Settings to add one.'**
  String get noProvidersAdded;

  /// No description provided for @noModelsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No models configured for this provider.'**
  String get noModelsConfigured;

  /// No description provided for @noChatHistory.
  ///
  /// In en, this message translates to:
  /// **'No chat history yet. Start a new chat!'**
  String get noChatHistory;

  /// No description provided for @noSystemPromptTemplates.
  ///
  /// In en, this message translates to:
  /// **'No system prompt templates yet. Add one!'**
  String get noSystemPromptTemplates;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessage;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'message'**
  String get message;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @freeCopy.
  ///
  /// In en, this message translates to:
  /// **'Free Copy'**
  String get freeCopy;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @providerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Provider name is required.'**
  String get providerNameRequired;

  /// No description provided for @baseUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Base URL is required.'**
  String get baseUrlRequired;

  /// No description provided for @apiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'API Key is required.'**
  String get apiKeyRequired;

  /// No description provided for @chatPathRequired.
  ///
  /// In en, this message translates to:
  /// **'Chat path is required.'**
  String get chatPathRequired;

  /// No description provided for @modelNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Model name is required.'**
  String get modelNameRequired;

  /// No description provided for @templateNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Template name is required.'**
  String get templateNameRequired;

  /// No description provided for @templatePromptRequired.
  ///
  /// In en, this message translates to:
  /// **'Template prompt is required.'**
  String get templatePromptRequired;

  /// No description provided for @chatName.
  ///
  /// In en, this message translates to:
  /// **'Chat Name'**
  String get chatName;

  /// No description provided for @enterChatName.
  ///
  /// In en, this message translates to:
  /// **'Enter chat name...'**
  String get enterChatName;

  /// No description provided for @chatSaved.
  ///
  /// In en, this message translates to:
  /// **'Chat saved successfully!'**
  String get chatSaved;

  /// No description provided for @chatNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Chat name is required.'**
  String get chatNameRequired;

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select a model to start chatting.'**
  String get selectModel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @monetTheming.
  ///
  /// In en, this message translates to:
  /// **'Monet Theming (Android 12+)'**
  String get monetTheming;

  /// No description provided for @enableMonet.
  ///
  /// In en, this message translates to:
  /// **'Enable Monet Theming'**
  String get enableMonet;

  /// No description provided for @saveAndResubmit.
  ///
  /// In en, this message translates to:
  /// **'Save & Resubmit'**
  String get saveAndResubmit;

  /// No description provided for @editChatName.
  ///
  /// In en, this message translates to:
  /// **'Edit Chat Name'**
  String get editChatName;

  /// No description provided for @sendKeySettings.
  ///
  /// In en, this message translates to:
  /// **'Send Key Setting'**
  String get sendKeySettings;

  /// No description provided for @sendWithEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get sendWithEnter;

  /// No description provided for @sendWithCtrlEnter.
  ///
  /// In en, this message translates to:
  /// **'Ctrl+Enter'**
  String get sendWithCtrlEnter;

  /// No description provided for @sendWithShiftCtrlEnter.
  ///
  /// In en, this message translates to:
  /// **'Shift+Ctrl+Enter'**
  String get sendWithShiftCtrlEnter;

  /// No description provided for @shortcutInEditMode.
  ///
  /// In en, this message translates to:
  /// **'Use shortcut in edit mode'**
  String get shortcutInEditMode;

  /// No description provided for @chatSettings.
  ///
  /// In en, this message translates to:
  /// **'Chat Settings'**
  String get chatSettings;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @topP.
  ///
  /// In en, this message translates to:
  /// **'Top P'**
  String get topP;

  /// No description provided for @useStreaming.
  ///
  /// In en, this message translates to:
  /// **'Use Streaming'**
  String get useStreaming;

  /// No description provided for @overrideModelSettings.
  ///
  /// In en, this message translates to:
  /// **'Use default model settings'**
  String get overrideModelSettings;

  /// No description provided for @streamingDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get streamingDefault;

  /// No description provided for @streamingOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get streamingOn;

  /// No description provided for @streamingOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get streamingOff;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developerOptions.
  ///
  /// In en, this message translates to:
  /// **'Developer Options'**
  String get developerOptions;

  /// No description provided for @showStatistics.
  ///
  /// In en, this message translates to:
  /// **'Show Statistics'**
  String get showStatistics;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will delete all providers, chats, and settings. This action cannot be undone. Are you sure?'**
  String get clearDataConfirmation;

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data has been cleared.'**
  String get dataCleared;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @firstChunkTime.
  ///
  /// In en, this message translates to:
  /// **'Time to First Chunk'**
  String get firstChunkTime;

  /// No description provided for @tokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get tokens;

  /// No description provided for @prompt.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get prompt;

  /// No description provided for @completion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get completion;

  /// No description provided for @displaySettings.
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get displaySettings;

  /// No description provided for @outputCharacters.
  ///
  /// In en, this message translates to:
  /// **'Output Characters'**
  String get outputCharacters;

  /// No description provided for @showTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Show Total Time'**
  String get showTotalTime;

  /// No description provided for @showFirstChunkTime.
  ///
  /// In en, this message translates to:
  /// **'Show Time to First Chunk'**
  String get showFirstChunkTime;

  /// No description provided for @showTokenUsage.
  ///
  /// In en, this message translates to:
  /// **'Show Token Usage'**
  String get showTokenUsage;

  /// No description provided for @showOutputCharacters.
  ///
  /// In en, this message translates to:
  /// **'Show Output Characters'**
  String get showOutputCharacters;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking... {duration}'**
  String thinking(String duration);

  /// No description provided for @thinkingTimeTaken.
  ///
  /// In en, this message translates to:
  /// **'Thinking time: {duration}'**
  String thinkingTimeTaken(String duration);

  /// No description provided for @thinkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinkingTitle;

  /// No description provided for @maxContextMessages.
  ///
  /// In en, this message translates to:
  /// **'Max Context Messages'**
  String get maxContextMessages;

  /// No description provided for @maxContextMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Number of recent messages to send (0 or empty = unlimited)'**
  String get maxContextMessagesHint;

  /// No description provided for @appearanceSettings.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSettings;

  /// No description provided for @statisticsSettings.
  ///
  /// In en, this message translates to:
  /// **'Statistics Display'**
  String get statisticsSettings;

  /// No description provided for @scrollSettings.
  ///
  /// In en, this message translates to:
  /// **'Scroll Settings'**
  String get scrollSettings;

  /// No description provided for @disableAutoScrollOnUp.
  ///
  /// In en, this message translates to:
  /// **'Disable auto-scroll on manual scroll'**
  String get disableAutoScrollOnUp;

  /// No description provided for @resumeAutoScrollOnBottom.
  ///
  /// In en, this message translates to:
  /// **'Resume auto-scroll when at bottom'**
  String get resumeAutoScrollOnBottom;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// No description provided for @stopGenerating.
  ///
  /// In en, this message translates to:
  /// **'Stop Generating'**
  String get stopGenerating;

  /// No description provided for @chatDisplay.
  ///
  /// In en, this message translates to:
  /// **'Chat Display'**
  String get chatDisplay;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @chatBubbleAlignment.
  ///
  /// In en, this message translates to:
  /// **'Chat Bubble Alignment'**
  String get chatBubbleAlignment;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// No description provided for @showTimestamps.
  ///
  /// In en, this message translates to:
  /// **'Show Timestamps'**
  String get showTimestamps;

  /// No description provided for @supportsThinking.
  ///
  /// In en, this message translates to:
  /// **'Supports Thinking'**
  String get supportsThinking;

  /// No description provided for @supportsThinkingHint.
  ///
  /// In en, this message translates to:
  /// **'If not supported, streaming content is shown as thinking and merged into the main body on completion.'**
  String get supportsThinkingHint;

  /// No description provided for @chatBubbleWidth.
  ///
  /// In en, this message translates to:
  /// **'Chat Bubble Width'**
  String get chatBubbleWidth;

  /// No description provided for @compactMode.
  ///
  /// In en, this message translates to:
  /// **'Compact Mode'**
  String get compactMode;

  /// No description provided for @compactModeHint.
  ///
  /// In en, this message translates to:
  /// **'Reduces padding and margins for a denser UI.'**
  String get compactModeHint;

  /// No description provided for @showModelName.
  ///
  /// In en, this message translates to:
  /// **'Show Model Name'**
  String get showModelName;

  /// No description provided for @showModelNameHint.
  ///
  /// In en, this message translates to:
  /// **'Display the model name under each AI response.'**
  String get showModelNameHint;

  /// No description provided for @regenerateResponse.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerateResponse;

  /// No description provided for @copyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyMessage;

  /// No description provided for @selectTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select a Template'**
  String get selectTemplate;

  /// No description provided for @searchTemplates.
  ///
  /// In en, this message translates to:
  /// **'Search templates...'**
  String get searchTemplates;

  /// No description provided for @noTemplatesFound.
  ///
  /// In en, this message translates to:
  /// **'No templates found.'**
  String get noTemplatesFound;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @reinitializeDatabase.
  ///
  /// In en, this message translates to:
  /// **'Re-initialize Database'**
  String get reinitializeDatabase;

  /// No description provided for @reinitializeDatabaseWarning.
  ///
  /// In en, this message translates to:
  /// **'This is a destructive action for debugging. It will re-register database adapters. The app may need to be restarted. Continue?'**
  String get reinitializeDatabaseWarning;

  /// No description provided for @databaseReinitialized.
  ///
  /// In en, this message translates to:
  /// **'Database re-initialized. Please restart the app.'**
  String get databaseReinitialized;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSettings;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'{itemName} has been deleted.'**
  String itemDeleted(String itemName);

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully.'**
  String get exportSuccess;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting data: {error}'**
  String exportError(String error);

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully. Please restart the app to see the changes.'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Error importing data: {error}'**
  String importError(String error);

  /// No description provided for @importConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite all current data. This action cannot be undone. Are you sure you want to restore from a backup?'**
  String get importConfirmation;

  /// No description provided for @useFirstSentenceAsTitle.
  ///
  /// In en, this message translates to:
  /// **'Use first message as title'**
  String get useFirstSentenceAsTitle;

  /// No description provided for @useFirstSentenceAsTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Automatically use the first sent message as the chat title.'**
  String get useFirstSentenceAsTitleHint;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @reverseBubbleAlignment.
  ///
  /// In en, this message translates to:
  /// **'Reverse Bubble Alignment'**
  String get reverseBubbleAlignment;

  /// No description provided for @reverseBubbleAlignmentHint.
  ///
  /// In en, this message translates to:
  /// **'User messages on the left, AI on the right'**
  String get reverseBubbleAlignmentHint;

  /// No description provided for @exportSettings.
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get exportSettings;

  /// No description provided for @selectContentToExport.
  ///
  /// In en, this message translates to:
  /// **'Select content to export'**
  String get selectContentToExport;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @codeBlockTheme.
  ///
  /// In en, this message translates to:
  /// **'Code Block Theme'**
  String get codeBlockTheme;

  /// No description provided for @showDebugButton.
  ///
  /// In en, this message translates to:
  /// **'Show Debug Button'**
  String get showDebugButton;

  /// No description provided for @showDebugButtonHint.
  ///
  /// In en, this message translates to:
  /// **'Show a debug button on message bubbles to inspect data.'**
  String get showDebugButtonHint;

  /// No description provided for @debugInfo.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get debugInfo;

  /// No description provided for @scrollToTop.
  ///
  /// In en, this message translates to:
  /// **'Scroll to top'**
  String get scrollToTop;

  /// No description provided for @scrollToBottom.
  ///
  /// In en, this message translates to:
  /// **'Scroll to bottom'**
  String get scrollToBottom;

  /// No description provided for @pageUp.
  ///
  /// In en, this message translates to:
  /// **'Previous Message'**
  String get pageUp;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesOnStartup.
  ///
  /// In en, this message translates to:
  /// **'Check for updates on startup'**
  String get checkForUpdatesOnStartup;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available: v{version}'**
  String updateAvailable(String version);

  /// No description provided for @newVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of NamelessAI is available.'**
  String get newVersionMessage;

  /// No description provided for @releaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release Notes:'**
  String get releaseNotes;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @noUpdates.
  ///
  /// In en, this message translates to:
  /// **'No Updates'**
  String get noUpdates;

  /// No description provided for @latestVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'You are using the latest version.'**
  String get latestVersionMessage;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates: {error}'**
  String updateCheckFailed(String error);

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get sourceCode;

  /// No description provided for @sourceCodeUrl.
  ///
  /// In en, this message translates to:
  /// **'github.com/youshen2/NamelessAI'**
  String get sourceCodeUrl;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with Flutter'**
  String get madeWith;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @unsupportedModelTypeInChat.
  ///
  /// In en, this message translates to:
  /// **'This model type is not supported in chat.'**
  String get unsupportedModelTypeInChat;

  /// No description provided for @modelTypeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get modelTypeLanguage;

  /// No description provided for @modelTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get modelTypeImage;

  /// No description provided for @modelTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get modelTypeVideo;

  /// No description provided for @modelTypeTts.
  ///
  /// In en, this message translates to:
  /// **'TTS'**
  String get modelTypeTts;

  /// No description provided for @imageSize.
  ///
  /// In en, this message translates to:
  /// **'Image Size'**
  String get imageSize;

  /// No description provided for @imageQuality.
  ///
  /// In en, this message translates to:
  /// **'Image Quality'**
  String get imageQuality;

  /// No description provided for @imageStyle.
  ///
  /// In en, this message translates to:
  /// **'Image Style'**
  String get imageStyle;

  /// No description provided for @qualityStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get qualityStandard;

  /// No description provided for @qualityHD.
  ///
  /// In en, this message translates to:
  /// **'HD'**
  String get qualityHD;

  /// No description provided for @styleVivid.
  ///
  /// In en, this message translates to:
  /// **'Vivid'**
  String get styleVivid;

  /// No description provided for @styleNatural.
  ///
  /// In en, this message translates to:
  /// **'Natural'**
  String get styleNatural;

  /// No description provided for @imageGenerationMode.
  ///
  /// In en, this message translates to:
  /// **'Image Generation Mode'**
  String get imageGenerationMode;

  /// No description provided for @instant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instant;

  /// No description provided for @asynchronous.
  ///
  /// In en, this message translates to:
  /// **'Asynchronous'**
  String get asynchronous;

  /// No description provided for @asyncImageType.
  ///
  /// In en, this message translates to:
  /// **'Asynchronous Type'**
  String get asyncImageType;

  /// No description provided for @midjourney.
  ///
  /// In en, this message translates to:
  /// **'Midjourney'**
  String get midjourney;

  /// No description provided for @imaginePath.
  ///
  /// In en, this message translates to:
  /// **'Imagine Path (Optional)'**
  String get imaginePath;

  /// No description provided for @fetchPath.
  ///
  /// In en, this message translates to:
  /// **'Fetch Path (Optional)'**
  String get fetchPath;

  /// No description provided for @taskSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Task submitted'**
  String get taskSubmitted;

  /// No description provided for @taskInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get taskInProgress;

  /// No description provided for @taskFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get taskFailed;

  /// No description provided for @taskSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get taskSuccess;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @imageGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Image generation failed'**
  String get imageGenerationFailed;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @requestError.
  ///
  /// In en, this message translates to:
  /// **'Request Error'**
  String get requestError;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownErrorOccurred;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @asyncImaginePathHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., /mj/submit/imagine'**
  String get asyncImaginePathHint;

  /// No description provided for @asyncFetchPathHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., /mj/task/{taskId}/fetch'**
  String asyncFetchPathHint(String taskId);

  /// No description provided for @taskStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get taskStatus;

  /// No description provided for @midjourneyPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter prompt, you can add parameters like --ar 16:9'**
  String get midjourneyPromptHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
