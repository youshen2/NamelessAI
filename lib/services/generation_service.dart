import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/api/api_service.dart';
import 'package:nameless_ai/api/models.dart' as api_models;
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';

class GenerationService {
  final APIProvider provider;
  final Model model;
  final ChatSession session;
  final String assistantMessageId;
  final List<ChatMessage> messagesForApi;
  final CancelToken cancelToken;
  final VoidCallback onUpdate;
  final ChatMessage messageToUpdate;

  GenerationService({
    required this.provider,
    required this.model,
    required this.session,
    required this.assistantMessageId,
    required this.messagesForApi,
    required this.cancelToken,
    required this.onUpdate,
    required this.messageToUpdate,
  });

  Future<void> execute() async {
    final stopwatch = Stopwatch()..start();
    int? firstChunkTimeMs;
    api_models.Usage? usage;

    try {
      if (model.modelType == ModelType.image) {
        await _generateImage();
      } else {
        final result = await _generateText(stopwatch);
        firstChunkTimeMs = result.firstChunkTimeMs;
        usage = result.usage;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint(
            "NamelessAI - Generation for session ${session.id} was cancelled via token.");
        if ((messageToUpdate.content).isEmpty) {
          messageToUpdate.content = "[Cancelled]";
          messageToUpdate.isError = true;
        }
      } else {
        String errorMessage = "请求错误";
        if (e.response?.data != null) {
          try {
            messageToUpdate.rawResponseJson = e.response!.data.toString();
            final prettyJson =
                const JsonEncoder.withIndent('  ').convert(e.response!.data);
            errorMessage += '\n\n```json\n$prettyJson\n```';
          } catch (_) {
            errorMessage += '\n\n```\n${e.response!.data.toString()}\n```';
          }
        } else {
          errorMessage +=
              '\n\n${e.message ?? 'Code: ${e.response?.statusCode}'}';
        }
        messageToUpdate.content = errorMessage;
        messageToUpdate.isError = true;
      }
    } catch (e) {
      messageToUpdate.content = "发生未知错误\n\n```\n${e.toString()}\n```";
      messageToUpdate.isError = true;
    } finally {
      stopwatch.stop();
      if (messageToUpdate.asyncTaskStatus == AsyncTaskStatus.none) {
        messageToUpdate.isLoading = false;
      }
      messageToUpdate.completionTimeMs = stopwatch.elapsedMilliseconds;
      messageToUpdate.firstChunkTimeMs = firstChunkTimeMs;
      messageToUpdate.outputCharacters = (messageToUpdate.content).length;
      if (usage != null) {
        messageToUpdate.promptTokens = usage.promptTokens;
        messageToUpdate.completionTokens = usage.completionTokens;
      }

      if (messageToUpdate.thinkingContent != null &&
          messageToUpdate.thinkingStartTime != null &&
          messageToUpdate.thinkingDurationMs == null) {
        messageToUpdate.thinkingDurationMs = DateTime.now()
            .difference(messageToUpdate.thinkingStartTime!)
            .inMilliseconds;
      }
      messageToUpdate.thinkingStartTime = null;

      onUpdate();
    }
  }

  Future<({int? firstChunkTimeMs, api_models.Usage? usage})> _generateText(
      Stopwatch stopwatch) async {
    final apiService = ApiService(provider);
    int? firstChunkTimeMs;
    api_models.Usage? usage;
    String fullResponseBuffer = '';
    const thinkStartTag = '<think>';
    const thinkEndTag = '</think>';
    bool isThinkingResponse = false;
    bool isFirstChunk = true;
    bool thinkingDone = false;

    final useStreaming = session.useStreaming ?? model.isStreamable;

    if (useStreaming) {
      final request = api_models.ChatCompletionRequest(
        model: model,
        messages: _formatMessages(messagesForApi, session.systemPrompt),
        maxTokens: model.maxTokens,
        stream: true,
        temperature: session.temperature,
        topP: session.topP,
      );
      final stream = apiService.getChatCompletionStream(request, cancelToken);

      await for (final item in stream) {
        if (cancelToken.isCancelled) break;

        if (item is String) {
          if (firstChunkTimeMs == null) {
            firstChunkTimeMs = stopwatch.elapsedMilliseconds;
            messageToUpdate.thinkingStartTime = DateTime.now();
          }

          if (isFirstChunk) {
            isFirstChunk = false;
            if (item.trim().startsWith(thinkStartTag)) {
              isThinkingResponse = true;
            }
          }

          if (isThinkingResponse) {
            fullResponseBuffer += item;
            if (!thinkingDone && fullResponseBuffer.contains(thinkEndTag)) {
              thinkingDone = true;
              final parts = fullResponseBuffer.split(thinkEndTag);
              messageToUpdate.thinkingContent =
                  parts[0].substring(thinkStartTag.length);
              messageToUpdate.content = parts.length > 1 ? parts[1] : '';
              if (messageToUpdate.thinkingStartTime != null) {
                messageToUpdate.thinkingDurationMs = DateTime.now()
                    .difference(messageToUpdate.thinkingStartTime!)
                    .inMilliseconds;
              }
            } else if (thinkingDone) {
              messageToUpdate.content = (messageToUpdate.content) + item;
            } else {
              messageToUpdate.thinkingContent =
                  fullResponseBuffer.substring(thinkStartTag.length);
            }
          } else {
            messageToUpdate.content = (messageToUpdate.content) + item;
          }
          onUpdate();
        } else if (item is api_models.Usage) {
          usage = item;
        }
      }
    } else {
      final request = api_models.ChatCompletionRequest(
        model: model,
        messages: _formatMessages(messagesForApi, session.systemPrompt),
        maxTokens: model.maxTokens,
        stream: false,
        temperature: session.temperature,
        topP: session.topP,
      );
      final response = await apiService.getChatCompletion(request, cancelToken);
      messageToUpdate.rawResponseJson = response.rawResponse;
      final responseMessage = response.choices.first.message;
      fullResponseBuffer = responseMessage.content;
      usage = response.usage;

      if (responseMessage.reasoningContent != null &&
          responseMessage.reasoningContent!.isNotEmpty) {
        thinkingDone = true;
        messageToUpdate.thinkingContent = responseMessage.reasoningContent;
        messageToUpdate.content = fullResponseBuffer;
        messageToUpdate.thinkingDurationMs = stopwatch.elapsedMilliseconds;
      } else if (fullResponseBuffer.trim().startsWith(thinkStartTag) &&
          fullResponseBuffer.contains(thinkEndTag)) {
        thinkingDone = true;
        final parts = fullResponseBuffer.split(thinkEndTag);
        messageToUpdate.thinkingContent =
            parts[0].substring(thinkStartTag.length);
        messageToUpdate.content = parts.length > 1 ? parts[1] : '';
        messageToUpdate.thinkingDurationMs = stopwatch.elapsedMilliseconds;
      } else {
        messageToUpdate.content = fullResponseBuffer;
      }
    }

    if (isThinkingResponse &&
        !thinkingDone &&
        messageToUpdate.thinkingContent != null) {
      messageToUpdate.content = messageToUpdate.thinkingContent!;
      messageToUpdate.thinkingContent = null;
      messageToUpdate.thinkingDurationMs = null;
    }

    return (firstChunkTimeMs: firstChunkTimeMs, usage: usage);
  }

  Future<void> _generateImage() async {
    if (model.imageGenerationMode == ImageGenerationMode.instant) {
      await _generateInstantImage();
    } else {
      await _submitAsyncImageTask();
    }
  }

  Future<void> _generateInstantImage() async {
    final apiService = ApiService(provider);
    final userPrompt = messagesForApi.last.content;

    final request = api_models.ImageGenerationRequest(
      prompt: userPrompt,
      modelSettings: model,
      size: session.imageSize ?? '1024x1024',
      quality: session.imageQuality,
      style: session.imageStyle,
    );
    final response = await apiService.generateImage(request, cancelToken);
    messageToUpdate.rawResponseJson = response.rawResponse;

    if (response.data.isNotEmpty && response.data.first.url != null) {
      messageToUpdate.content = response.data.first.url!;
    } else {
      throw Exception("Image generation failed: No image URL in response.");
    }
  }

  Future<void> _submitAsyncImageTask() async {
    if (model.compatibilityMode == CompatibilityMode.midjourneyProxy) {
      await _submitMidjourneyTask();
    } else {
      throw Exception("Unsupported asynchronous image model type.");
    }
  }

  Future<void> _submitMidjourneyTask() async {
    final apiService = ApiService(provider);
    final userPrompt = messagesForApi.last.content;

    final request = api_models.MidjourneyImagineRequest(
      prompt: userPrompt,
      modelSettings: model,
    );
    final response =
        await apiService.submitMidjourneyTask(request, cancelToken);
    messageToUpdate.rawResponseJson = response.rawResponse;

    if (response.code == 1 && response.result != null) {
      messageToUpdate.taskId = response.result;
      messageToUpdate.asyncTaskStatus = AsyncTaskStatus.submitted;
      messageToUpdate.content = 'Task Submitted: ${response.description}';
      messageToUpdate.isLoading = false;
    } else {
      throw Exception(
          "Midjourney task submission failed: ${response.description} (Code: ${response.code})");
    }
  }

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
}
