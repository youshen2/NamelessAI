import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/api/models.dart';
import 'package:nameless_ai/data/models/api_provider.dart';

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
              final ChatCompletionStreamResponse streamResponse =
                  ChatCompletionStreamResponse.fromJson(json);

              if (streamResponse.choices.isNotEmpty) {
                final String? content =
                    streamResponse.choices.first.delta.content;
                if (content != null) {
                  yield content;
                }
              }

              if (streamResponse.usage != null) {
                yield streamResponse.usage;
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
