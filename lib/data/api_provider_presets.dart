import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

List<APIProvider> getProviderPresets(AppLocalizations localizations) {
  return [
    APIProvider(
      name: localizations.presetOpenAI,
      baseUrl: 'https://api.openai.com',
      apiKey: '',
      models: [
        Model(name: 'gpt-4o', isStreamable: true),
        Model(name: 'gpt-4-turbo', isStreamable: true),
        Model(name: 'gpt-3.5-turbo', isStreamable: true),
      ],
    ),
    APIProvider(
      name: localizations.presetGroq,
      baseUrl: 'https://api.groq.com/openai',
      apiKey: '',
      models: [
        Model(name: 'llama3-8b-8192', isStreamable: true),
        Model(name: 'llama3-70b-8192', isStreamable: true),
        Model(name: 'mixtral-8x7b-32768', isStreamable: true),
        Model(name: 'gemma-7b-it', isStreamable: true),
      ],
    ),
    APIProvider(
      name: localizations.presetYi,
      baseUrl: 'https://api.01.ai',
      apiKey: '',
      models: [
        Model(name: 'yi-large', isStreamable: true),
        Model(name: 'yi-medium', isStreamable: true),
        Model(name: 'yi-vision', isStreamable: true),
      ],
    ),
    APIProvider(
      name: localizations.presetMoonshot,
      baseUrl: 'https://api.moonshot.cn',
      apiKey: '',
      models: [
        Model(name: 'moonshot-v1-8k', isStreamable: true),
        Model(name: 'moonshot-v1-32k', isStreamable: true),
        Model(name: 'moonshot-v1-128k', isStreamable: true),
      ],
    ),
    APIProvider(
      name: localizations.presetGeneric,
      baseUrl: 'http://localhost:11434',
      apiKey: 'ollama',
      models: [
        Model(name: 'llama3', isStreamable: true),
      ],
    ),
  ];
}
