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

  ChatMessageResponse({
    required this.role,
    required this.content,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      role: json['role'],
      content: json['content'],
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
