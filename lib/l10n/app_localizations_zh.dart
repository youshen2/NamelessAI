// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'NamelessAI';

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
  String get prompt => '输入';

  @override
  String get completion => '输出';

  @override
  String get displaySettings => '显示设置';

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
  String get supportsThinking => '支持思考';

  @override
  String get supportsThinkingHint => '若实际不支持思考，流式输出过程中会作为思考内容，结束后会归类为正文。';

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
  String get reverseBubbleAlignment => '反转气泡对齐';

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
  String get pageUp => '向上翻页';
}
