import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/api/models.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
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
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ));

  Future<ChatCompletionResponse> getChatCompletion(
      ChatCompletionRequest request) async {
    try {
      debugPrint(
          "NamelessAI - Sending Request: ${jsonEncode(request.toJson())}");
      final response = await _dio.post(
        provider.chatCompletionPath,
        data: request.toJson(),
      );
      debugPrint(
          "NamelessAI - Received Response: ${jsonEncode(response.data)}");

      if (response.data is String) {
        // Handle non-compliant APIs that return a raw string
        return ChatCompletionResponse(
          id: 'non-compliant-${const Uuid().v4()}',
          object: 'chat.completion',
          created: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          model: request.model,
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
        );
      }

      return ChatCompletionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get chat completion: ${e.message}');
    }
  }

  Stream<dynamic> getChatCompletionStream(
      ChatCompletionRequest request) async* {
    try {
      debugPrint(
          "NamelessAI - Sending Stream Request: ${jsonEncode(request.toJson())}");
      final response = await _dio.post(
        provider.chatCompletionPath,
        data: request.toJson(),
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
          },
        ),
      );

      await for (final chunk in response.data!.stream!) {
        final String data = utf8.decode(chunk);
        final List<String> lines = data.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final String jsonStr = line.substring(6).trim();
            if (jsonStr == '[DONE]') {
              break;
            }
            try {
              final Map<String, dynamic> json = jsonDecode(jsonStr);

              // Handle chunks that might only contain usage data from some providers
              if (json.containsKey('usage') && json['usage'] != null) {
                final usage = Usage.fromJson(json['usage']);
                yield usage;
              }

              // Handle regular stream chunks with choices
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
    } on DioException catch (e) {
      throw Exception('Failed to get chat completion stream: ${e.message}');
    }
  }
}
