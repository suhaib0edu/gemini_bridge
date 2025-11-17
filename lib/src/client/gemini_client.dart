import 'dart:async';
import 'dart:convert';


import 'package:http/http.dart' as http;

import '../../gemini_bridge.dart';
import 'constants.dart';

final class GeminiClient {
  GeminiClient({required String apiKey, http.Client? httpClient})
    : _apiKey = apiKey,
      _httpClient = httpClient ?? http.Client(),
      _serializationStrategy = DeveloperSerialization(),
      _baseUri = Uri.parse('$geminiApiBaseUrl/$geminiApiVersion/models');

  final String _apiKey;
  final http.Client _httpClient;
  final DeveloperSerialization _serializationStrategy;
  final Uri _baseUri;

  Future<GenerateContentResponse> generateContent(
    String text, {
    String modelId = 'gemini-flash-latest',
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) {
    return generateContentFromPrompt(
      [Content.text(text)],
      modelId: modelId,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
      tools: tools,
      toolConfig: toolConfig,
    );
  }

  Future<GenerateContentResponse> generateContentFromPrompt(
    Iterable<Content> prompt, {
    String modelId = 'gemini-flash-latest',
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) async {
    final uri = _buildUri(modelId, 'generateContent');
    final headers = _buildHeaders();
    final body = _buildContentRequest(
      prompt,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
      tools: tools,
      toolConfig: toolConfig,
    );

    final response = await _httpClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final error = jsonResponse['error'] as Map<String, dynamic>?;
      if (error != null) {
        throw parseGeminiError(error);
      }
      throw GeminiServerException(
        'Unknown server error: ${response.statusCode} ${response.body}',
      );
    }

    return _serializationStrategy.parseGenerateContentResponse(jsonResponse);
  }

  Stream<GenerateContentResponse> generateContentStream(
    Iterable<Content> prompt, {
    String modelId = 'gemini-flash-latest',
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) async* {
    final uri = _buildUri(modelId, 'streamGenerateContent', sse: true);
    final headers = _buildHeaders();
    final body = _buildContentRequest(
      prompt,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
      tools: tools,
      toolConfig: toolConfig,
    );

    final request = http.Request('POST', uri)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await _httpClient.send(request);

    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
      final error = jsonResponse['error'] as Map<String, dynamic>?;
      if (error != null) {
        throw parseGeminiError(error);
      }
      throw GeminiServerException(
        'Unknown server error: ${response.statusCode} $responseBody',
      );
    }

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      const dataPrefix = 'data: ';
      if (line.startsWith(dataPrefix)) {
        final jsonText = line.substring(dataPrefix.length);
        final jsonObject = jsonDecode(jsonText);
        yield _serializationStrategy.parseGenerateContentResponse(jsonObject);
      }
    }
  }

  Uri _buildUri(String modelId, String task, {bool sse = false}) {
    final path = '${_baseUri.path}/$modelId:$task';
    final queryParameters = {'key': _apiKey};
    if (sse) {
      queryParameters['alt'] = 'sse';
    }
    return _baseUri.replace(path: path, queryParameters: queryParameters);
  }

  Map<String, String> _buildHeaders() {
    return {'Content-Type': 'application/json'};
  }

  Map<String, Object?> _buildContentRequest(
    Iterable<Content> contents, {
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) {
    return {
      'contents': contents.map((c) => c.toJson()).toList(),
      if (safetySettings != null && safetySettings.isNotEmpty)
        'safetySettings': safetySettings.map((s) => s.toJson()).toList(),
      if (generationConfig != null)
        'generationConfig': generationConfig.toJson(),
      if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
      if (toolConfig != null) 'toolConfig': toolConfig.toJson(),
    };
  }
}
