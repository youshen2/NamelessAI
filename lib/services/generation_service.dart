import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nameless_ai/api/api_service.dart';
import 'package:nameless_ai/api/models.dart' as api_models;
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/chat_message.dart';
import 'package:nameless_ai/data/models/chat_session.dart';
import 'package:nameless_ai/data/models/model.dart';
import 'package:nameless_ai/data/models/model_type.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:tiktoken/tiktoken.dart';

class GenerationService {
  final APIProvider provider;
  final Model model;
  final ChatSession session;
  final String assistantMessageId;
  final List<ChatMessage> messagesForApi;
  final CancelToken cancelToken;
  final VoidCallback onUpdate;
  final ChatMessage messageToUpdate;
  final AppLocalizations localizations;

  GenerationService({
    required this.provider,
    required this.model,
    required this.session,
    required this.assistantMessageId,
    required this.messagesForApi,
    required this.cancelToken,
    required this.onUpdate,
    required this.messageToUpdate,
    required this.localizations,
  });

  int _calculatePromptTokens(
      Tiktoken encoding, List<Map<String, String>> messages) {
    int numTokens = 0;
    for (final message in messages) {
      numTokens += 4;
      message.forEach((key, value) {
        numTokens += encoding.encode(value).length;
      });
    }
    numTokens += 2;
    return numTokens;
  }

  Future<void> execute() async {
    final stopwatch = Stopwatch()..start();
    int? firstChunkTimeMs;
    api_models.Usage? usage;
    int? estimatedPromptTokens;

    try {
      if (model.modelType == ModelType.image) {
        await _generateImage();
      } else if (model.modelType == ModelType.video) {
        await _submitVideoTask();
      } else {
        try {
          final encoding = getEncoding('cl100k_base');
          estimatedPromptTokens = _calculatePromptTokens(
              encoding, _formatMessages(messagesForApi, session.systemPrompt));
        } catch (e) {
          debugPrint("NamelessAI - Tiktoken encoding failed: $e");
          estimatedPromptTokens = null;
        }

        final result = await _generateText(stopwatch);
        firstChunkTimeMs = result.firstChunkTimeMs;
        usage = result.usage;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint(
            "NamelessAI - Generation for session ${session.id} was cancelled via token.");
        if ((messageToUpdate.content).isEmpty) {
          messageToUpdate.content = localizations.cancelled;
          messageToUpdate.isError = true;
        }
      } else {
        String errorMessage;
        if (e.response != null) {
          final statusCode = e.response!.statusCode ?? 0;
          final statusMessage = e.response!.statusMessage ?? '';
          errorMessage = localizations.httpError(statusCode, statusMessage);

          switch (statusCode) {
            case 401:
              errorMessage += '\n\n${localizations.error401}';
              break;
            case 404:
              errorMessage += '\n\n${localizations.error404}';
              break;
            case 429:
              errorMessage += '\n\n${localizations.error429}';
              break;
          }

          if (e.response!.data != null) {
            messageToUpdate.rawResponseJson = e.response!.data.toString();
            try {
              final prettyJson =
                  const JsonEncoder.withIndent('  ').convert(e.response!.data);
              errorMessage += '\n\n```json\n$prettyJson\n```';
            } catch (_) {
              errorMessage += '\n\n```\n${e.response!.data.toString()}\n```';
            }
          }
        } else {
          errorMessage = localizations.requestError;
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
              errorMessage += '\n\n${localizations.errorTimeout}';
              break;
            case DioExceptionType.connectionError:
              errorMessage += '\n\n${localizations.errorConnection}';
              break;
            default:
              errorMessage +=
                  '\n\n${e.message ?? localizations.errorUnknownNetwork}';
              break;
          }
        }
        messageToUpdate.content = errorMessage;
        messageToUpdate.isError = true;
      }
    } catch (e) {
      messageToUpdate.content =
          "${localizations.unknownErrorOccurred}\n\n```\n${e.toString()}\n```";
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
        messageToUpdate.isTokenCountEstimated = false;
      } else if (model.modelType == ModelType.language &&
          estimatedPromptTokens != null) {
        try {
          final encoding = getEncoding('cl100k_base');
          messageToUpdate.promptTokens = estimatedPromptTokens;
          messageToUpdate.completionTokens =
              encoding.encode(messageToUpdate.content).length;
          messageToUpdate.isTokenCountEstimated = true;
        } catch (e) {
          debugPrint(
              "NamelessAI - Tiktoken encoding failed for completion: $e");
        }
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
      final interval = AppDatabase.appConfigBox
          .get('asyncTaskRefreshInterval', defaultValue: 10) as int;
      if (interval > 0) {
        messageToUpdate.nextRefreshTime =
            DateTime.now().add(Duration(seconds: interval));
      }
    } else {
      throw Exception(
          "Midjourney task submission failed: ${response.description} (Code: ${response.code})");
    }
  }

  Future<void> _submitVideoTask() async {
    final apiService = ApiService(provider);
    final userPrompt = messagesForApi.last.content;

    final request = api_models.VideoCreationRequest(
      prompt: userPrompt,
      modelSettings: model,
    );
    final response = await apiService.createVideoTask(request, cancelToken);
    messageToUpdate.rawResponseJson = response.rawResponse;

    messageToUpdate.taskId = response.id;
    messageToUpdate.enhancedPrompt = response.enhancedPrompt;
    messageToUpdate.asyncTaskStatus = AsyncTaskStatus.submitted;
    messageToUpdate.content = 'Task Submitted: ${response.status}';
    messageToUpdate.isLoading = false;
    final interval = AppDatabase.appConfigBox
        .get('asyncTaskRefreshInterval', defaultValue: 10) as int;
    if (interval > 0) {
      messageToUpdate.nextRefreshTime =
          DateTime.now().add(Duration(seconds: interval));
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
