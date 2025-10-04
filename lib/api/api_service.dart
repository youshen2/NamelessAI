import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/api/models.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:uuid/uuid.dart';

List<Map<String, dynamic>> _transformMessagesToGemini(
    List<Map<String, String>> messages) {
  final List<Map<String, dynamic>> geminiContents = [];
  for (var message in messages) {
    if (message['role'] == 'system') continue;
    final role = message['role'] == 'assistant' ? 'model' : 'user';
    geminiContents.add({
      'role': role,
      'parts': [
        {'text': message['content'] ?? ''}
      ]
    });
  }

  if (geminiContents.isEmpty) return geminiContents;

  final List<Map<String, dynamic>> mergedContents = [geminiContents.first];
  for (int i = 1; i < geminiContents.length; i++) {
    if (geminiContents[i]['role'] == mergedContents.last['role']) {
      final lastText =
          (mergedContents.last['parts'] as List).first['text'] as String;
      final currentText =
          (geminiContents[i]['parts'] as List).first['text'] as String;
      (mergedContents.last['parts'] as List).first['text'] =
          '$lastText\n\n$currentText';
    } else {
      mergedContents.add(geminiContents[i]);
    }
  }

  if (mergedContents.isNotEmpty && mergedContents.first['role'] == 'model') {
    mergedContents.insert(0, {
      'role': 'user',
      'parts': [
        {'text': ' '}
      ]
    });
  }

  return mergedContents;
}

class ApiService {
  final Dio _dio;
  final APIProvider provider;

  ApiService(this.provider)
      : _dio = Dio(BaseOptions(
          baseUrl: provider.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${provider.apiKey}',
          },
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(minutes: 10),
        ));

  // 处理Dio异常，解析JSON响应中的错误信息
  Exception _handleDioError(DioException error) {
    if (error.response?.data != null) {
      try {
        // 尝试将响应体解析为JSON
        Map<String, dynamic> errorData;
        if (error.response?.data is String) {
          errorData = jsonDecode(error.response?.data as String);
        } else {
          errorData = error.response?.data as Map<String, dynamic>;
        }
        
        // 提取error字段信息
        if (errorData.containsKey('error')) {
          final errorObj = errorData['error'];
          if (errorObj is Map) {
            final message = errorObj['message'] ?? error.message;
            return Exception(message);
          } else {
            return Exception(errorObj.toString());
          }
        } else if (errorData.containsKey('message')) {
          return Exception(errorData['message']);
        }
      } catch (e) {
        // 如果解析失败，回退到原始错误信息
        debugPrint('Error parsing error response: $e');
      }
    }
    return error;
  }

  Future<ChatCompletionResponse> getChatCompletion(
      ChatCompletionRequest request,
      [CancelToken? cancelToken]) async {
    if (request.model.compatibilityMode == CompatibilityMode.gemini) {
      return _getGeminiChatCompletion(request, cancelToken);
    }

    try {
      final requestBody = jsonEncode(request.toJson());
      debugPrint("NamelessAI - Sending Request: $requestBody");
      final path = request.model.chatPath ?? '/v1/chat/completions';
      final response = await _dio.post(
        path,
        data: requestBody,
        cancelToken: cancelToken,
      );
      final rawResponseString = 
          response.data is String ? response.data : jsonEncode(response.data);
      debugPrint("NamelessAI - Received Response: $rawResponseString");

      if (response.data is String) {
        try {
          final jsonData = jsonDecode(response.data as String);
          return ChatCompletionResponse.fromJson(jsonData,
              rawResponse: rawResponseString);
        } catch (e) {
          return ChatCompletionResponse(
            id: 'non-compliant-${const Uuid().v4()}',
            object: 'chat.completion',
            created: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            model: request.model.name,
            choices: [
              ChatChoice(
                index: 0,
                message: ChatMessageResponse(
                  role: 'assistant',
                  content: response.data as String,
                ),
                finishReason: 'stop',
              ),
            ],
            rawResponse: rawResponseString,
          );
        }
      }

      return ChatCompletionResponse.fromJson(response.data,
          rawResponse: rawResponseString);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Stream<dynamic> getChatCompletionStream(ChatCompletionRequest request,
      [CancelToken? cancelToken]) {
    if (request.model.compatibilityMode == CompatibilityMode.gemini) {
      return _getGeminiChatCompletionStream(request, cancelToken);
    }
    return _getOpenAIChatCompletionStream(request, cancelToken);
  }

  Future<ChatCompletionResponse> _getGeminiChatCompletion(
      ChatCompletionRequest request,
      [CancelToken? cancelToken]) async {
    final systemPrompt = request.messages
        .firstWhere((m) => m['role'] == 'system', orElse: () => {})['content'];
    final userMessages = 
        request.messages.where((m) => m['role'] != 'system').toList();
    final geminiMessages = _transformMessagesToGemini(userMessages);

    final Map<String, dynamic> requestData = {'contents': geminiMessages};
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      requestData['system_instruction'] = {
        'parts': [
          {'text': systemPrompt}
        ]
      };
    }

    final requestBody = jsonEncode(requestData);
    debugPrint("NamelessAI - Sending Gemini Request: $requestBody");
    final path = request.model.chatPath ??
        '/v1beta/models/${request.model.name}:generateContent';

    try {
      final response = await _dio.post(
        path,
        data: requestBody,
        queryParameters: {'key': provider.apiKey},
        options: Options(headers: {'Authorization': null}),
        cancelToken: cancelToken,
      );

      final rawResponseString = jsonEncode(response.data);
      debugPrint("NamelessAI - Received Gemini Response: $rawResponseString");

      final candidates = response.data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini API returned no candidates.');
      }
      final content = candidates.first['content'];
      final parts = content['parts'] as List;
      final text = parts.first['text'];

      return ChatCompletionResponse(
        id: 'gemini-${const Uuid().v4()}',
        object: 'chat.completion',
        created: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        model: request.model.name,
        choices: [
          ChatChoice(
            index: 0,
            message: ChatMessageResponse(role: 'assistant', content: text),
            finishReason: 'stop',
          ),
        ],
        rawResponse: rawResponseString,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Stream<dynamic> _getGeminiChatCompletionStream(ChatCompletionRequest request,
      [CancelToken? cancelToken]) async* {
    final systemPrompt = request.messages
        .firstWhere((m) => m['role'] == 'system', orElse: () => {})['content'];
    final userMessages =
        request.messages.where((m) => m['role'] != 'system').toList();
    final geminiMessages = _transformMessagesToGemini(userMessages);

    final Map<String, dynamic> requestData = {'contents': geminiMessages};
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      requestData['system_instruction'] = {
        'parts': [
          {'text': systemPrompt}
        ]
      };
    }
    final requestBody = jsonEncode(requestData);
    debugPrint("NamelessAI - Sending Gemini Stream Request: $requestBody");

    final basePath = request.model.chatPath ??
        '/v1beta/models/${request.model.name}:generateContent';
    final path =
        basePath.replaceFirst(':generateContent', ':streamGenerateContent');

    final response = await _dio.post(
      path,
      data: requestBody,
      queryParameters: {'key': provider.apiKey, 'alt': 'sse'},
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Authorization': null, 'Accept': 'text/event-stream'},
      ),
      cancelToken: cancelToken,
    );

    String buffer = '';
    await for (final chunk in response.data!.stream!) {
      buffer += utf8.decode(chunk);
      int lineEndIndex;
      while ((lineEndIndex = buffer.indexOf('\n')) != -1) {
        final line = buffer.substring(0, lineEndIndex).trim();
        buffer = buffer.substring(lineEndIndex + 1);

        if (line.startsWith('data: ')) {
          final String jsonStr = line.substring(6).trim();
          if (jsonStr.isEmpty) continue;
          try {
            final Map<String, dynamic> json = jsonDecode(jsonStr);
            final candidates = json['candidates'] as List?;
            if (candidates != null && candidates.isNotEmpty) {
              final content = candidates.first['content'];
              final parts = content['parts'] as List;
              final text = parts.first['text'] as String?;
              if (text != null) {
                yield text;
              }
            }
          } catch (e) {
            debugPrint('Error parsing Gemini stream chunk: $e, data: $jsonStr');
          }
        }
      }
    }
  }

  Stream<dynamic> _getOpenAIChatCompletionStream(ChatCompletionRequest request,
      [CancelToken? cancelToken]) async* {
    try {
      final requestBody = jsonEncode(request.toJson());
      debugPrint("NamelessAI - Sending Stream Request: $requestBody");
      final path = request.model.chatPath ?? '/v1/chat/completions';
      final response = await _dio.post(
        path,
        data: requestBody,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
          },
        ),
        cancelToken: cancelToken,
      );

      String buffer = '';
      await for (final chunk in response.data!.stream!) {
        buffer += utf8.decode(chunk);

        int lineEndIndex;
        while ((lineEndIndex = buffer.indexOf('\n')) != -1) {
          final line = buffer.substring(0, lineEndIndex).trim();
          buffer = buffer.substring(lineEndIndex + 1);

          if (line.startsWith('data: ')) {
            final String jsonStr = line.substring(6).trim();
            if (jsonStr == '[DONE]') {
              return;
            }
            if (jsonStr.isEmpty) {
              continue;
            }
            try {
              final Map<String, dynamic> json = jsonDecode(jsonStr);

              if (json.containsKey('usage') && json['usage'] != null) {
                final usage = Usage.fromJson(json['usage']);
                yield usage;
              }

              if (json.containsKey('choices')) {
                final ChatCompletionStreamResponse streamResponse =
                    ChatCompletionStreamResponse.fromJson(json);

                if (streamResponse.choices.isNotEmpty) {
                  final String? content =
                      streamResponse.choices.first.delta.content;
                  if (content != null) {
                    yield content;
                  }
                }
              }
            } catch (e) {
              debugPrint('Error parsing stream chunk: $e, data: $jsonStr');
            }
          }
        }
      }

      if (buffer.isNotEmpty) {
        final line = buffer.trim();
        if (line.startsWith('data: ')) {
          final String jsonStr = line.substring(6).trim();
          if (jsonStr.isNotEmpty && jsonStr != '[DONE]') {
            try {
              final Map<String, dynamic> json = jsonDecode(jsonStr);

              if (json.containsKey('usage') && json['usage'] != null) {
                final usage = Usage.fromJson(json['usage']);
                yield usage;
              }

              if (json.containsKey('choices')) {
                final ChatCompletionStreamResponse streamResponse =
                    ChatCompletionStreamResponse.fromJson(json);

                if (streamResponse.choices.isNotEmpty) {
                  final String? content =
                      streamResponse.choices.first.delta.content;
                  if (content != null) {
                    yield content;
                  }
                }
              }
            } catch (e) {
              debugPrint(
                  'Error parsing final stream buffer: $e, data: $jsonStr');
            }
          }
        }
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ImageGenerationResponse> generateImage(ImageGenerationRequest request,
      [CancelToken? cancelToken]) async {
    try {
      final requestBody = jsonEncode(request.toJson());
      debugPrint("NamelessAI - Sending Image Request: $requestBody");
      final path = request.modelSettings.imaginePath;
      final endpoint =
          (path != null && path.isNotEmpty) ? path : '/v1/images/generations';
      final response = await _dio.post(
        endpoint,
        data: requestBody,
        cancelToken: cancelToken,
      );
      final rawResponseString = jsonEncode(response.data);
      debugPrint("NamelessAI - Received Image Response: $rawResponseString");
      return ImageGenerationResponse.fromJson(response.data,
          rawResponse: rawResponseString);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MidjourneyImagineResponse> submitMidjourneyTask(
      MidjourneyImagineRequest request,
      [CancelToken? cancelToken]) async {
    try {
      final requestBody = jsonEncode(request.toJson());
      debugPrint("NamelessAI - Submitting Midjourney Task: $requestBody");
      final imaginePath = request.modelSettings.imaginePath;
      final endpoint = (imaginePath != null && imaginePath.isNotEmpty)
          ? imaginePath
          : '/mj/submit/imagine';

      final response = await _dio.post(
        endpoint,
        data: requestBody,
        cancelToken: cancelToken,
      );
      final rawResponseString = 
          response.data is String ? response.data : jsonEncode(response.data);
      debugPrint(
          "NamelessAI - Received Midjourney Task Response: $rawResponseString");

      final data = response.data;
      final jsonData = data is String ? jsonDecode(data) : data;

      return MidjourneyImagineResponse.fromJson(jsonData,
          rawResponse: rawResponseString);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MidjourneyFetchResponse> fetchMidjourneyTask(
      String taskId, Model model,
      [CancelToken? cancelToken]) async {
    try {
      final fetchPath = model.fetchPath;
      final baseEndpoint = (fetchPath != null && fetchPath.isNotEmpty)
          ? fetchPath
          : '/mj/task/{taskId}/fetch';

      final path = baseEndpoint.replaceAll('{taskId}', taskId);
      debugPrint("NamelessAI - Fetching Midjourney Task: $path");
      final response = await _dio.get(
        path,
        cancelToken: cancelToken,
      );
      final rawResponseString = jsonEncode(response.data);
      debugPrint(
          "NamelessAI - Received Midjourney Fetch Response: $rawResponseString");
      return MidjourneyFetchResponse.fromJson(response.data,
          rawResponse: rawResponseString);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<VideoCreationResponse> createVideoTask(VideoCreationRequest request,
      [CancelToken? cancelToken]) async {
    try {
      final requestBody = jsonEncode(request.toJson());
      debugPrint("NamelessAI - Creating Video Task: $requestBody");
      final path = request.modelSettings.createVideoPath ?? '/v1/video/create';
      final response = await _dio.post(
        path,
        data: requestBody,
        cancelToken: cancelToken,
      );
      final rawResponseString = jsonEncode(response.data);
      debugPrint(
          "NamelessAI - Received Video Task Response: $rawResponseString");
      return VideoCreationResponse.fromJson(response.data,
          rawResponse: rawResponseString);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<VideoQueryResponse> queryVideoTask(String taskId, Model model,
      [CancelToken? cancelToken]) async {
    try {
      final path = model.queryVideoPath ?? '/v1/video/query';
      debugPrint("NamelessAI - Querying Video Task: $path, id: $taskId");
      final response = await _dio.get(
        path,
        queryParameters: {'id': taskId},
        cancelToken: cancelToken,
      );
      final rawResponseString = jsonEncode(response.data);
      debugPrint(
          "NamelessAI - Received Video Query Response: $rawResponseString");
      return VideoQueryResponse.fromJson(response.data,
          rawResponse: rawResponseString);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
