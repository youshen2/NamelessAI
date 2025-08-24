import 'package:dio/dio.dart';
import 'package:nameless_ai/data/models/model.dart';

class ChatCompletionRequest {
  final String model;
  final List<Map<String, String>> messages;
  final double? temperature;
  final double? topP;
  final int? maxTokens;
  final bool stream;

  ChatCompletionRequest({
    required this.model,
    required this.messages,
    this.temperature = 0.7,
    this.topP,
    this.maxTokens,
    this.stream = false,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'stream': stream,
    };
    if (maxTokens != null && maxTokens! > 0) {
      data['max_tokens'] = maxTokens;
    }
    if (topP != null) {
      data['top_p'] = topP;
    }
    return data;
  }
}

class ChatCompletionResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatChoice> choices;
  final Usage? usage;

  ChatCompletionResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices:
          (json['choices'] as List).map((e) => ChatChoice.fromJson(e)).toList(),
      usage: json['usage'] != null ? Usage.fromJson(json['usage']) : null,
    );
  }
}

class ChatChoice {
  final int index;
  final ChatMessageResponse message;
  final String? finishReason;

  ChatChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      index: json['index'],
      message: ChatMessageResponse.fromJson(json['message']),
      finishReason: json['finish_reason'],
    );
  }
}

class ChatMessageResponse {
  final String role;
  final String content;
  final String? reasoningContent;

  ChatMessageResponse({
    required this.role,
    required this.content,
    this.reasoningContent,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      role: json['role'],
      content: json['content'],
      reasoningContent: json['reasoning_content'],
    );
  }
}

class Usage {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  Usage({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}

class ChatCompletionStreamResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatStreamChoice> choices;
  final Usage? usage;

  ChatCompletionStreamResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  factory ChatCompletionStreamResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionStreamResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices: (json['choices'] as List?)
              ?.map((e) => ChatStreamChoice.fromJson(e))
              .toList() ??
          [],
      usage: json['usage'] != null ? Usage.fromJson(json['usage']) : null,
    );
  }
}

class ChatStreamChoice {
  final int index;
  final ChatDelta delta;
  final String? finishReason;

  ChatStreamChoice({
    required this.index,
    required this.delta,
    this.finishReason,
  });

  factory ChatStreamChoice.fromJson(Map<String, dynamic> json) {
    return ChatStreamChoice(
      index: json['index'],
      delta: ChatDelta.fromJson(json['delta']),
      finishReason: json['finish_reason'],
    );
  }
}

class ChatDelta {
  final String? role;
  final String? content;

  ChatDelta({this.role, this.content});

  factory ChatDelta.fromJson(Map<String, dynamic> json) {
    return ChatDelta(
      role: json['role'],
      content: json['content'],
    );
  }
}

class ImageGenerationRequest {
  final String prompt;
  final Model modelSettings;
  final int? n;
  final String? size;
  final String? quality;
  final String? style;

  ImageGenerationRequest({
    required this.prompt,
    required this.modelSettings,
    this.n = 1,
    this.size = '1024x1024',
    this.quality,
    this.style,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'prompt': prompt,
      'n': n,
      'size': size,
      'model': modelSettings.name,
    };
    if (quality != null) {
      data['quality'] = quality;
    }
    if (style != null) {
      data['style'] = style;
    }
    return data;
  }
}

class ImageGenerationResponse {
  final int created;
  final List<ImageData> data;

  ImageGenerationResponse({
    required this.created,
    required this.data,
  });

  factory ImageGenerationResponse.fromJson(Map<String, dynamic> json) {
    // Handle API error responses that don't contain 'data'
    if (json.containsKey('error') && json['error'] != null) {
      final errorData = json['error'];
      final message = errorData['message'] ?? 'Unknown image generation error';
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        message: message.toString(),
        response:
            Response(requestOptions: RequestOptions(path: ''), data: json),
      );
    }

    return ImageGenerationResponse(
      created: json['created'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      data: (json['data'] as List).map((e) => ImageData.fromJson(e)).toList(),
    );
  }
}

class ImageData {
  final String? url;
  final String? b64Json;

  ImageData({this.url, this.b64Json});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      url: json['url'],
      b64Json: json['b64_json'],
    );
  }
}

class MidjourneyImagineRequest {
  final String prompt;
  final Model modelSettings;

  MidjourneyImagineRequest({required this.prompt, required this.modelSettings});

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'model': modelSettings.name,
      };
}

class MidjourneyImagineResponse {
  final int code;
  final String description;
  final String? result;

  MidjourneyImagineResponse(
      {required this.code, required this.description, this.result});

  factory MidjourneyImagineResponse.fromJson(Map<String, dynamic> json) {
    return MidjourneyImagineResponse(
      code: json['code'],
      description: json['description'],
      result: json['result'],
    );
  }
}

class MidjourneyFetchResponse {
  final String? action;
  final String? id;
  final String? prompt;
  final String? promptEn;
  final String? description;
  final String? state;
  final int? submitTime;
  final int? startTime;
  final int? finishTime;
  final String? imageUrl;
  final String? status;
  final String? progress;
  final String? failReason;
  final Map<String, dynamic>? properties;

  MidjourneyFetchResponse({
    this.action,
    this.id,
    this.prompt,
    this.promptEn,
    this.description,
    this.state,
    this.submitTime,
    this.startTime,
    this.finishTime,
    this.imageUrl,
    this.status,
    this.progress,
    this.failReason,
    this.properties,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'id': id,
      'prompt': prompt,
      'promptEn': promptEn,
      'description': description,
      'state': state,
      'submitTime': submitTime,
      'startTime': startTime,
      'finishTime': finishTime,
      'imageUrl': imageUrl,
      'status': status,
      'progress': progress,
      'failReason': failReason,
      'properties': properties,
    };
  }

  factory MidjourneyFetchResponse.fromJson(Map<String, dynamic> json) {
    return MidjourneyFetchResponse(
      action: json['action'],
      id: json['id'],
      prompt: json['prompt'],
      promptEn: json['promptEn'],
      description: json['description'],
      state: json['state'],
      submitTime: json['submitTime'],
      startTime: json['startTime'],
      finishTime: json['finishTime'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      progress: json['progress'],
      failReason: json['failReason'],
      properties: json['properties'],
    );
  }
}
