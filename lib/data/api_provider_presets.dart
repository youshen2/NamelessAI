import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

List<APIProvider> getProviderPresets(AppLocalizations localizations) {
  const defaultChatPath = '/v1/chat/completions';

  return [
    APIProvider(
      name: localizations.presetOpenAI,
      baseUrl: 'https://api.openai.com',
      apiKey: '',
      models: [
        Model(name: 'gpt-4o', isStreamable: true, chatPath: defaultChatPath),
        Model(
            name: 'gpt-4-turbo', isStreamable: true, chatPath: defaultChatPath),
        Model(
            name: 'gpt-3.5-turbo',
            isStreamable: true,
            chatPath: defaultChatPath),
      ],
    ),
    APIProvider(
      name: localizations.presetGroq,
      baseUrl: 'https://api.groq.com/openai',
      apiKey: '',
      models: [
        Model(
            name: 'llama3-8b-8192',
            isStreamable: true,
            chatPath: defaultChatPath),
        Model(
            name: 'llama3-70b-8192',
            isStreamable: true,
            chatPath: defaultChatPath),
        Model(
            name: 'mixtral-8x7b-32768',
            isStreamable: true,
            chatPath: defaultChatPath),
        Model(
            name: 'gemma-7b-it', isStreamable: true, chatPath: defaultChatPath),
      ],
    ),
    APIProvider(
      name: localizations.presetYi,
      baseUrl: 'https://api.01.ai',
      apiKey: '',
      models: [
        Model(name: 'yi-large', isStreamable: true, chatPath: defaultChatPath),
        Model(name: 'yi-medium', isStreamable: true, chatPath: defaultChatPath),
        Model(name: 'yi-vision', isStreamable: true, chatPath: defaultChatPath),
      ],
    ),
    APIProvider(
      name: localizations.presetMoonshot,
      baseUrl: 'https://api.moonshot.cn',
      apiKey: '',
      models: [
        Model(
            name: 'moonshot-v1-8k',
            isStreamable: true,
            chatPath: defaultChatPath),
        Model(
            name: 'moonshot-v1-32k',
            isStreamable: true,
            chatPath: defaultChatPath),
        Model(
            name: 'moonshot-v1-128k',
            isStreamable: true,
            chatPath: defaultChatPath),
      ],
    ),
    APIProvider(
      name: localizations.presetDeepseek,
      baseUrl: 'https://api.deepseek.com',
      apiKey: '',
      models: [
        Model(
            name: 'deepseek-chat',
            isStreamable: true,
            chatPath: defaultChatPath),
        Model(
            name: 'deepseek-reasoner',
            isStreamable: true,
            chatPath: defaultChatPath),
      ],
    ),
  ];
}
