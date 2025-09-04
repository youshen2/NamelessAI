// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Nameless AI Box';

  @override
  String get chat => '聊天';

  @override
  String get history => '历史';

  @override
  String get settings => '设置';

  @override
  String get newChat => '新聊天';

  @override
  String get saveChat => '保存聊天';

  @override
  String get sendMessage => '发送消息...';

  @override
  String get modelSelection => '模型选择';

  @override
  String get systemPrompt => '系统提示词';

  @override
  String get enterSystemPrompt => '输入系统提示词...';

  @override
  String get apiProviderSettings => 'API 提供商';

  @override
  String get systemPromptTemplates => '提示词模板';

  @override
  String get taskSettings => '任务设置';

  @override
  String get asyncTaskRefreshInterval => '异步任务刷新间隔 (秒)';

  @override
  String get asyncTaskRefreshIntervalHint => '用于图片/视频生成。设置为0则禁用。';

  @override
  String get compatibilityMode => '兼容模式';

  @override
  String get compatibilityModeMidjourney => 'Midjourney 代理';

  @override
  String get saveToGallery => '保存到相册';

  @override
  String get saveSuccess => '图片已保存到相册。';

  @override
  String saveError(String error) {
    return '保存图片失败: $error';
  }

  @override
  String get rawResponse => '原始响应';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get imageModeInstant => '模式: 即时';

  @override
  String get imageModeAsync => '模式: 异步';

  @override
  String get streamable => '流式';

  @override
  String get addProvider => '添加提供商';

  @override
  String get editProvider => '编辑提供商';

  @override
  String get deleteProvider => '删除提供商';

  @override
  String get providerName => '提供商名称';

  @override
  String get baseUrl => '基础 URL';

  @override
  String get apiKey => 'API 密钥';

  @override
  String get chatPath => '聊天路径';

  @override
  String get models => '模型';

  @override
  String get addModel => '添加模型';

  @override
  String get editModel => '编辑模型';

  @override
  String get modelName => '模型名称';

  @override
  String get maxTokens => '最大Token数 (可选)';

  @override
  String get isStreamable => '支持流式输出';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get confirmDelete => '确认删除';

  @override
  String deleteConfirmation(Object itemType) {
    return '您确定要删除此$itemType吗？';
  }

  @override
  String get addTemplate => '添加模板';

  @override
  String get editTemplate => '编辑模板';

  @override
  String get deleteTemplate => '删除模板';

  @override
  String get templateName => '模板名称';

  @override
  String get templatePrompt => '模板内容';

  @override
  String get noProvidersAdded => '尚未添加 API 提供商。请前往“设置”添加。';

  @override
  String get noModelsConfigured => '此提供商未配置任何模型。';

  @override
  String get noChatHistory => '暂无聊天记录。开始新的聊天吧！';

  @override
  String get noSystemPromptTemplates => '暂无提示词模板。添加一个吧！';

  @override
  String get editMessage => '编辑消息';

  @override
  String get deleteMessage => '删除消息';

  @override
  String get message => '消息';

  @override
  String get copyCode => '复制代码';

  @override
  String get freeCopy => '自由复制';

  @override
  String get copiedToClipboard => '已复制到剪贴板！';

  @override
  String get error => '错误';

  @override
  String get somethingWentWrong => '发生了一些错误。';

  @override
  String get providerNameRequired => '提供商名称不能为空。';

  @override
  String get baseUrlRequired => '基础 URL 不能为空。';

  @override
  String get apiKeyRequired => 'API 密钥不能为空。';

  @override
  String get chatPathRequired => '聊天路径不能为空。';

  @override
  String get modelNameRequired => '模型名称不能为空。';

  @override
  String get templateNameRequired => '模板名称不能为空。';

  @override
  String get templatePromptRequired => '模板内容不能为空。';

  @override
  String get chatName => '聊天名称';

  @override
  String get enterChatName => '输入聊天名称...';

  @override
  String get chatSaved => '聊天已成功保存！';

  @override
  String get chatNameRequired => '聊天名称不能为空。';

  @override
  String get selectModel => '请选择一个模型以开始聊天。';

  @override
  String get language => '语言';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';

  @override
  String get theme => '主题';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get light => '浅色模式';

  @override
  String get dark => '深色模式';

  @override
  String get monetTheming => '莫奈取色 (Android 12+)';

  @override
  String get enableMonet => '启用莫奈取色';

  @override
  String get saveAndResubmit => '保存并重新提交';

  @override
  String get editChatName => '修改聊天名称';

  @override
  String get sendKeySettings => '发送快捷键';

  @override
  String get sendWithEnter => 'Enter';

  @override
  String get sendWithCtrlEnter => 'Ctrl+Enter';

  @override
  String get sendWithShiftCtrlEnter => 'Shift+Ctrl+Enter';

  @override
  String get shortcutInEditMode => '在编辑模式下使用快捷键';

  @override
  String get chatSettings => '聊天设置';

  @override
  String get temperature => 'Temperature';

  @override
  String get topP => 'Top P';

  @override
  String get useStreaming => '使用流式输出';

  @override
  String get overrideModelSettings => '使用模型默认设置';

  @override
  String get streamingDefault => '默认';

  @override
  String get streamingOn => '开启';

  @override
  String get streamingOff => '关闭';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get developerOptions => '开发者选项';

  @override
  String get showStatistics => '显示统计信息';

  @override
  String get clearAllData => '清除所有数据';

  @override
  String get clearDataConfirmation => '此操作将删除所有提供商、聊天记录和设置，且无法撤销。您确定吗？';

  @override
  String get dataCleared => '所有数据已清除。';

  @override
  String get totalTime => '总耗时';

  @override
  String get firstChunkTime => '首字耗时';

  @override
  String get tokens => 'Tokens';

  @override
  String get tokensEstimate => 'Tokens (估算)';

  @override
  String get prompt => '输入';

  @override
  String get completion => '输出';

  @override
  String get outputCharacters => '输出字数';

  @override
  String get showTotalTime => '显示总耗时';

  @override
  String get showFirstChunkTime => '显示首字耗时';

  @override
  String get showTokenUsage => '显示Token用量';

  @override
  String get showOutputCharacters => '显示输出字数';

  @override
  String thinking(String duration) {
    return '正在思考... $duration';
  }

  @override
  String thinkingTimeTaken(String duration) {
    return '思考耗时: $duration';
  }

  @override
  String get thinkingTitle => '思考';

  @override
  String get maxContextMessages => '最大上下文数量';

  @override
  String get maxContextMessagesHint => '要发送的消息数量 (0或留空则无限制)';

  @override
  String get appearanceSettings => '外观设置';

  @override
  String get statisticsSettings => '统计信息显示';

  @override
  String get scrollSettings => '滚动设置';

  @override
  String get disableAutoScrollOnUp => '手动滚动时禁用自动滚动';

  @override
  String get resumeAutoScrollOnBottom => '滚动到底部时恢复自动滚动';

  @override
  String get search => '搜索';

  @override
  String get noResultsFound => '未找到结果。';

  @override
  String get stopGenerating => '停止生成';

  @override
  String get chatDisplay => '聊天显示';

  @override
  String get fontSize => '字号';

  @override
  String get small => '小';

  @override
  String get medium => '中';

  @override
  String get large => '大';

  @override
  String get chatBubbleAlignment => '聊天气泡对齐';

  @override
  String get normal => '常规';

  @override
  String get center => '居中';

  @override
  String get showTimestamps => '显示时间戳';

  @override
  String get chatBubbleWidth => '聊天气泡宽度';

  @override
  String get compactMode => '紧凑模式';

  @override
  String get compactModeHint => '减少边距与间距，使界面更紧凑。';

  @override
  String get showModelName => '显示模型名称';

  @override
  String get showModelNameHint => '在每条AI回复下方显示模型名称。';

  @override
  String get regenerateResponse => '重新生成';

  @override
  String get copyMessage => '复制';

  @override
  String get selectTemplate => '选择模板';

  @override
  String get searchTemplates => '搜索模板...';

  @override
  String get noTemplatesFound => '未找到模板。';

  @override
  String get exportData => '导出数据';

  @override
  String get importData => '导入数据';

  @override
  String get reinitializeDatabase => '重新初始化数据库';

  @override
  String get reinitializeDatabaseWarning =>
      '这是一个用于调试的破坏性操作。它将重新注册数据库适配器。应用可能需要重启。要继续吗？';

  @override
  String get databaseReinitialized => '数据库已重新初始化。请重启应用。';

  @override
  String get generalSettings => '通用设置';

  @override
  String itemDeleted(String itemName) {
    return '$itemName 已被删除。';
  }

  @override
  String get exportSuccess => '数据导出成功。';

  @override
  String exportError(String error) {
    return '导出数据时出错: $error';
  }

  @override
  String get importSuccess => '数据导入成功。请重启应用以查看更改。';

  @override
  String importError(String error) {
    return '导入数据时出错: $error';
  }

  @override
  String get importConfirmation => '这将覆盖所有当前数据，此操作无法撤销。您确定要从备份中恢复吗？';

  @override
  String get useFirstSentenceAsTitle => '使用首条消息作为标题';

  @override
  String get useFirstSentenceAsTitleHint => '自动使用发送的第一条消息作为该聊天会话的标题。';

  @override
  String get dataManagement => '数据管理';

  @override
  String get modelLabel => '模型';

  @override
  String get timeLabel => '时间';

  @override
  String get reverseBubbleAlignment => '反转气泡';

  @override
  String get reverseBubbleAlignmentHint => '用户消息在左，AI消息在右';

  @override
  String get exportSettings => '导出设置';

  @override
  String get selectContentToExport => '选择要导出的内容';

  @override
  String get appSettings => '应用设置';

  @override
  String get codeBlockTheme => '代码块主题';

  @override
  String get showDebugButton => '显示调试按钮';

  @override
  String get showDebugButtonHint => '在消息气泡上显示一个调试按钮以检查数据。';

  @override
  String get debugInfo => '调试信息';

  @override
  String get scrollToTop => '回到顶部';

  @override
  String get scrollToBottom => '回到底部';

  @override
  String get pageUp => '上一条消息';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get checkForUpdatesOnStartup => '启动时检查更新';

  @override
  String updateAvailable(String version) {
    return '发现新版本: v$version';
  }

  @override
  String get newVersionMessage => '发现 Nameless AI Box 的新版本。';

  @override
  String get releaseNotes => '更新日志:';

  @override
  String get later => '稍后';

  @override
  String get update => '更新';

  @override
  String get close => '关闭';

  @override
  String get noUpdates => '没有更新';

  @override
  String get latestVersionMessage => '您正在使用最新版本。';

  @override
  String updateCheckFailed(String error) {
    return '检查更新失败: $error';
  }

  @override
  String get sourceCode => '项目源代码';

  @override
  String get sourceCodeUrl => 'github.com/youshen2/NamelessAI';

  @override
  String get openSourceLicenses => '开源库许可';

  @override
  String get madeWith => '使用 Flutter 构建';

  @override
  String get collapse => '折叠';

  @override
  String get expand => '展开';

  @override
  String get unsupportedModelTypeInChat => '此模型类型不支持聊天。';

  @override
  String get modelTypeLanguage => '语言';

  @override
  String get modelTypeImage => '图像';

  @override
  String get modelTypeVideo => '视频';

  @override
  String get modelTypeTts => '语音合成';

  @override
  String get imageSize => '图像尺寸';

  @override
  String get imageQuality => '图像质量';

  @override
  String get imageStyle => '图像风格';

  @override
  String get qualityStandard => '标准';

  @override
  String get qualityHD => '高清';

  @override
  String get styleVivid => '鲜艳';

  @override
  String get styleNatural => '自然';

  @override
  String get imageGenerationMode => '图像生成模式';

  @override
  String get instant => '即时';

  @override
  String get asynchronous => '异步';

  @override
  String get midjourney => 'Midjourney';

  @override
  String get imaginePath => 'Imagine 路径';

  @override
  String get fetchPath => 'Fetch 路径';

  @override
  String get taskSubmitted => '任务已提交';

  @override
  String get taskInProgress => '处理中';

  @override
  String get taskFailed => '失败';

  @override
  String get taskSuccess => '成功';

  @override
  String get refresh => '刷新';

  @override
  String get imageGenerationFailed => '图像生成失败';

  @override
  String get failedToLoadImage => '加载图像失败';

  @override
  String refreshingIn(String seconds) {
    return '将在 $seconds 秒后自动刷新';
  }

  @override
  String get requestError => '请求错误';

  @override
  String httpError(int statusCode, String statusMessage) {
    return 'HTTP 错误: $statusCode $statusMessage';
  }

  @override
  String get error401 => '身份验证失败。请检查您的 API 密钥。';

  @override
  String get error404 => '未找到。请检查您的基础 URL 和 API 路径。';

  @override
  String get error429 => '请求过多。您可能已超出速率限制或配额。';

  @override
  String get errorTimeout => '请求超时。请检查您的网络连接。';

  @override
  String get errorConnection => '连接错误。请检查您的网络连接和基础 URL。';

  @override
  String get errorUnknownNetwork => '发生未知网络错误。';

  @override
  String get unknownErrorOccurred => '发生未知错误';

  @override
  String get cancelled => '已取消';

  @override
  String get ok => '好的';

  @override
  String get asyncImaginePathHint => '例如 /mj/submit/imagine';

  @override
  String asyncFetchPathHint(String taskId) {
    return '例如 /mj/task/$taskId/fetch';
  }

  @override
  String get taskStatus => '状态';

  @override
  String get midjourneyPromptHint => '输入提示词，可附带 --ar 16:9 等参数';

  @override
  String get clearHistory => '清空历史记录';

  @override
  String get clearHistoryConfirmation => '您确定要删除所有聊天记录吗？此操作无法撤销。';

  @override
  String get jsonDebugViewer => 'JSON 查看器';

  @override
  String get searchHint => '搜索...';

  @override
  String get historyCleared => '历史记录已清空。';

  @override
  String get imageExpirationWarning => '图片存在有效期，请及时下载。';

  @override
  String get imageGenerationPathHint => '例如 /v1/images/generations';

  @override
  String get resetOnboarding => '重置引导';

  @override
  String get resetOnboardingHint => '这将在下次启动应用时显示引导页面。';

  @override
  String get reset => '重置';

  @override
  String get resetOnboardingConfirmation => '您确定要重置引导状态吗？';

  @override
  String get apiPathTemplate => '接口模板';

  @override
  String get selectApiPathTemplate => '选择模板';

  @override
  String get apiPathTemplateQingyunTop => '青云Top';

  @override
  String get apiPathTemplateStandardOpenAI => '标准 OpenAI';

  @override
  String get apiPathTemplateStandardInstantImage => '通用即时生图';

  @override
  String get apiPathTemplateStandardMidjourney => '标准 Midjourney';

  @override
  String get nonLanguageModelPathWarning => '使用前请确定接口路径是否正确。';

  @override
  String get noApiPathTemplatesFound => '未找到接口模板。';

  @override
  String get searchApiPathTemplates => '搜索模板...';

  @override
  String get chatPathHint => '例如 /v1/chat/completions';

  @override
  String get createVideoPath => '创建视频路径';

  @override
  String get queryVideoPath => '查询视频路径';

  @override
  String get createVideoPathHint => '例如 /v1/video/create';

  @override
  String get queryVideoPathHint => '例如 /v1/video/query';

  @override
  String get apiPathTemplateQingyunTopVeo => '青云Top - Veo通用';

  @override
  String get enhancedPrompt => '优化后的提示词';

  @override
  String get videoUrl => '视频链接';

  @override
  String get copyUrl => '复制链接';

  @override
  String get playVideo => '播放视频';

  @override
  String get videoGenerationFailed => '视频生成失败';

  @override
  String get failedToLoadVideo => '加载视频失败';

  @override
  String get videoExpirationWarning => '文件有效期2天，请及时下载。';

  @override
  String get hapticSettings => '振动反馈';

  @override
  String get enableHapticFeedback => '启用振动反馈';

  @override
  String get hapticIntensity => '振动强度';

  @override
  String get hapticIntensityNone => '无';

  @override
  String get hapticIntensityLight => '轻';

  @override
  String get hapticIntensityMedium => '中';

  @override
  String get hapticIntensityHeavy => '重';

  @override
  String get hapticIntensitySelection => '默认';

  @override
  String get hapticButtonPress => '按钮点按';

  @override
  String get hapticSwitchToggle => '开关切换';

  @override
  String get hapticLongPress => '长按';

  @override
  String get hapticSliderChanged => '滑块更改';

  @override
  String get hapticsNotSupported => '此平台不支持振动反馈。';

  @override
  String get hapticStreamOutput => '流式输出';

  @override
  String get hapticThinking => '思考时';

  @override
  String get importFromNamelessAI => '从 NamelessAI';

  @override
  String get importFromChatBox => '从 ChatBox';

  @override
  String get importPreview => '导入预览';

  @override
  String get selectItemsToImport => '选择要导入的项目：';

  @override
  String get importMode => '导入模式';

  @override
  String get mergeData => '合并';

  @override
  String get replaceData => '替换';

  @override
  String get mergeDataHint => '将数据追加到现有内容中。';

  @override
  String get replaceDataHint => '导入前删除现有数据。';

  @override
  String get skipped => '已跳过';

  @override
  String get warning => '警告';

  @override
  String get unsupportedData => '不支持的数据类型，将被跳过。';

  @override
  String get noSystemPrompt => '无系统提示词';

  @override
  String get import => '导入';

  @override
  String get onboardingReset => '引导页已重置。';

  @override
  String get defaultStartupPage => '默认启动页';

  @override
  String get restoreLastSession => '启动时恢复上次会话';

  @override
  String get restoreLastSessionHint => '如果禁用，每次启动都会开始一个新的聊天。';

  @override
  String get importOptions => '导入选项';

  @override
  String get importing => '正在导入...';

  @override
  String get parsingFile => '正在解析文件...';

  @override
  String importFrom(String source) {
    return '从 $source 导入';
  }

  @override
  String get namelessAiSource => 'NamelessAI';

  @override
  String get chatBoxSource => 'ChatBox';

  @override
  String get dataToImport => '待导入数据';

  @override
  String get cornerRadius => '圆角大小';

  @override
  String get cornerRadiusHint => '调整卡片、按钮等界面元素的圆角大小。';

  @override
  String get enableBlurEffect => '启用模糊效果';

  @override
  String get enableBlurEffectHint => '为导航栏等部分UI元素应用模糊效果。';

  @override
  String get pageTransition => '页面切换动画';

  @override
  String get pageTransitionSystem => '系统默认';

  @override
  String get pageTransitionSlide => '滑动';

  @override
  String get pageTransitionFade => '淡入淡出';

  @override
  String get pageTransitionScale => '缩放';

  @override
  String get onboardingTitle => '设置向导';

  @override
  String get onboardingPage1Title => '欢迎使用 Nameless AI';

  @override
  String get onboardingPage1Body => '一个简洁且强大的跨平台 AI 客户端。让我们开始设置吧。';

  @override
  String get onboardingPage2Title => '外观';

  @override
  String get onboardingPage2Body => '自定义应用的外观和感觉。';

  @override
  String get onboardingPage3Title => '偏好设置';

  @override
  String get onboardingPage3Body => '设置您与应用交互的首选方式。';

  @override
  String get onboardingPage4Title => '一切就绪！';

  @override
  String get onboardingPage4Body => '您可以开始聊天了。请记得在“设置”中添加 API 提供商以开始使用。';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingBack => '上一步';

  @override
  String get onboardingFinish => '开始使用';

  @override
  String get onboardingSendKey => '发送快捷键';

  @override
  String get addProviderManually => '手动添加';

  @override
  String get addFromPreset => '从预设添加';

  @override
  String get presetOpenAI => 'OpenAI';

  @override
  String get presetGroq => 'Groq';

  @override
  String get presetYi => '零一万物';

  @override
  String get presetMoonshot => '月之暗面 (Kimi)';

  @override
  String get presetDeepseek => '深度求索 (DeepSeek)';

  @override
  String get crashReport => '崩溃报告';

  @override
  String get errorDetails => '错误详情';

  @override
  String get stackTrace => '堆栈追踪';

  @override
  String get restartApp => '重启应用';

  @override
  String get crashTest => '崩溃测试';

  @override
  String get crashTestDescription => '点击以触发一次测试崩溃。';

  @override
  String get anErrorOccurred => '发生了一个意外错误。';

  @override
  String get submitIssue => '提交 Issue';

  @override
  String get submitIssueDescription =>
      '为了帮助我们修复此问题，请在 GitHub 上提交一个 Issue。\n您可以将复制的信息粘贴到问题描述中。';

  @override
  String get developer => '开发者';

  @override
  String get developerName => '爅峫';

  @override
  String get developerUrl => 'space.bilibili.com/394675616';

  @override
  String get easterEgg => 'Ciallo～(∠・ω< )⌒★';

  @override
  String get apacheLicense => '本项目基于 Apache License 2.0 许可开源';

  @override
  String get apacheLicenseUrl => 'www.apache.org/licenses/LICENSE-2.0';

  @override
  String get distinguishAssistantBubble => '区分 AI 气泡';

  @override
  String get distinguishAssistantBubbleHint => '为AI的气泡添加边框，让它区别于背景色。';

  @override
  String get scrollButtonPosition => '滚动按钮位置';

  @override
  String get scrollButtonBottomOffset => '底部偏移';

  @override
  String get scrollButtonRightOffset => '右侧偏移';

  @override
  String get accentColor => '强调色';
}
