import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/api/api_service.dart';
import 'package:nameless_ai/api/models.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/models/model.dart';

class ChatService {
  final APIProvider provider;
  final Model model;

  ChatService({required this.provider, required this.model});

  List<Map<String, String>> _formatMessages(
      List<ChatMessage> messages, String? systemPrompt) {
    final List<Map<String, String>> formatted = [];
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      formatted.add({'role': 'system', 'content': systemPrompt});
    }
    for (var msg in messages) {
      formatted.add({'role': msg.role, 'content': msg.content});
    }
    return formatted;
  }

  Future<ChatCompletionResponse> getCompletion(List<ChatMessage> messages,
      String? systemPrompt, double temperature, double topP,
      [CancelToken? cancelToken]) async {
    final apiService = ApiService(provider);
    final request = ChatCompletionRequest(
      model: model.name,
      messages: _formatMessages(messages, systemPrompt),
      maxTokens: model.maxTokens,
      stream: false,
      temperature: temperature,
      topP: topP,
    );

    try {
      final response = await apiService.getChatCompletion(request, cancelToken);
      return response;
    } catch (e) {
      debugPrint('Error in getCompletion: $e');
      rethrow;
    }
  }

  Stream<dynamic> getCompletionStream(List<ChatMessage> messages,
      String? systemPrompt, double temperature, double topP,
      [CancelToken? cancelToken]) {
    final apiService = ApiService(provider);
    final request = ChatCompletionRequest(
      model: model.name,
      messages: _formatMessages(messages, systemPrompt),
      maxTokens: model.maxTokens,
      stream: true,
      temperature: temperature,
      topP: topP,
    );

    return apiService.getChatCompletionStream(request, cancelToken);
  }
}
