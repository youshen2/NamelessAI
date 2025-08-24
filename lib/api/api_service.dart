import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/api/models.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:uuid/uuid.dart';

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

  Future<ChatCompletionResponse> getChatCompletion(
      ChatCompletionRequest request,
      [CancelToken? cancelToken]) async {
    try {
      debugPrint(
          "NamelessAI - Sending Request: ${jsonEncode(request.toJson())}");
      final path = request.model.chatPath?.isNotEmpty == true
          ? request.model.chatPath!
          : provider.chatCompletionPath;
      final response = await _dio.post(
        path,
        data: request.toJson(),
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
    } on DioException {
      rethrow;
    }
  }

  Stream<dynamic> getChatCompletionStream(ChatCompletionRequest request,
      [CancelToken? cancelToken]) async* {
    try {
      debugPrint(
          "NamelessAI - Sending Stream Request: ${jsonEncode(request.toJson())}");
      final path = request.model.chatPath?.isNotEmpty == true
          ? request.model.chatPath!
          : provider.chatCompletionPath;
      final response = await _dio.post(
        path,
        data: request.toJson(),
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
    } on DioException {
      rethrow;
    }
  }

  Future<ImageGenerationResponse> generateImage(ImageGenerationRequest request,
      [CancelToken? cancelToken]) async {
    try {
      debugPrint(
          "NamelessAI - Sending Image Request: ${jsonEncode(request.toJson())}");
      final path = request.modelSettings.imaginePath;
      final endpoint =
          (path != null && path.isNotEmpty) ? path : '/v1/images/generations';
      final response = await _dio.post(
        endpoint,
        data: request.toJson(),
        cancelToken: cancelToken,
      );
      final rawResponseString = jsonEncode(response.data);
      debugPrint("NamelessAI - Received Image Response: $rawResponseString");
      return ImageGenerationResponse.fromJson(response.data,
          rawResponse: rawResponseString);
    } on DioException {
      rethrow;
    }
  }

  Future<MidjourneyImagineResponse> submitMidjourneyTask(
      MidjourneyImagineRequest request,
      [CancelToken? cancelToken]) async {
    try {
      debugPrint(
          "NamelessAI - Submitting Midjourney Task: ${jsonEncode(request.toJson())}");
      final imaginePath = request.modelSettings.imaginePath;
      final endpoint = (imaginePath != null && imaginePath.isNotEmpty)
          ? imaginePath
          : '/mj/submit/imagine';

      final response = await _dio.post(
        endpoint,
        data: request.toJson(),
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
    } on DioException {
      rethrow;
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
    } on DioException {
      rethrow;
    }
  }
}
