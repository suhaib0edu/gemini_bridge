
import 'dart:convert';
import 'dart:io';

import 'package:gemini_bridge/gemini_bridge.dart';

void main() async {
  final apiKey = 'YOUR_GEMINI_API_KEY';

  final client = GeminiClient(apiKey: apiKey);
  final separator = '\n${'=' * 50}\n';

  // --- الحالة 1: توليد نص بسيط ---
  print('--- 1. توليد نص بسيط ---');
  try {
    final response = await client.generateContent('لماذا السماء زرقاء؟ اشرح باختصار.');
    print('المستخدم: لماذا السماء زرقاء؟ اشرح باختصار.');
    print('Gemini: ${response.text}');
  } on GeminiBridgeException catch (e) {
    print('حدث خطأ: $e');
  }
  print(separator);

  // --- الحالة 2: استجابة متدفقة ---
  print('--- 2. استجابة متدفقة (Streaming) ---');
  try {
    final prompt = [Content.text('اخبرني قصة مستقبلية قصيرة عن مبرمج.')];
    final stream = client.generateContentStream(prompt);

    print('المستخدم: اخبرني قصة مستقبلية قصيرة عن مبرمج.');
    stdout.write('Gemini (متدفق): ');
    await for (final chunk in stream) {
      stdout.write(chunk.text);
    }
    print('');
  } on GeminiBridgeException catch (e) {
    print('حدث خطأ أثناء البث المتدفق: $e');
  }
  print(separator);

  // --- الحالة 3: مخرجات JSON محددة ---
  print('--- 3. توليد مُتحكَم به (مخرجات JSON) ---');
  try {
    final recipeSchema = Schema.object(properties: {
      'recipeName': Schema.string(description: 'اسم الوصفة.'),
      'ingredients': Schema.array(
        description: 'قائمة بالمكونات.',
        items: Schema.object(properties: {
          'name': Schema.string(description: 'اسم المكون'),
          'quantity': Schema.number(description: 'الكمية'),
          'unit': Schema.string(description: 'الوحدة، مثل: جرام، مل، كوب'),
        }),
      ),
      'totalCalories': Schema.integer(description: 'إجمالي السعرات الحرارية.'),
    });

    final generationConfig = GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: recipeSchema,
    );

    final prompt = [Content.text('أنشئ وصفة بسيطة للفطائر الكلاسيكية (pancake) مع السعرات الحرارية.')];
    print('المستخدم: أنشئ وصفة بسيطة للفطائر الكلاسيكية (pancake) مع السعرات الحرارية.');
    
    final response = await client.generateContentFromPrompt(
      prompt,
      generationConfig: generationConfig,
    );

    print('Gemini (JSON):');
    final prettyJson = JsonEncoder.withIndent('  ').convert(jsonDecode(response.text!));
    print(prettyJson);

  } on GeminiBridgeException catch (e) {
    print('حدث خطأ في توليد JSON: $e');
  }
  print(separator);


  // --- الحالة 4: استخدام الأدوات (استدعاء الدوال) ---
  print('--- 4. استخدام الأدوات (استدعاء الدوال) ---');
  try {
    final weatherFunction = FunctionDeclaration(
      'getCurrentWeather',
      'الحصول على الطقس الحالي في موقع معين.',
      parameters: {
        'location_info': Schema.object(properties: {
          'location': Schema.string(description: 'المدينة والدولة، مثل: الرياض، السعودية'),
        }),
      },
    );

    final tool = Tool.functionDeclarations([weatherFunction]);

    final initialPrompt = [Content.text("ما هو الطقس في الرياض؟")];
    print('المستخدم: ما هو الطقس في الرياض؟');

    final response = await client.generateContentFromPrompt(
      initialPrompt,
      tools: [tool],
    );

    final functionCalls = response.functionCalls;

    if (functionCalls.isNotEmpty) {
      final call = functionCalls.first;
      if (call.name == 'getCurrentWeather') {
        final location = (call.args['location_info'] as Map<String, dynamic>)['location'];
        print('Gemini يطلب استدعاء دالة: ${call.name} للموقع: $location');

        final weatherResult = {"temperature": "35", "unit": "C", "description": "حار ومشمس"};
        print('نتيجة الدالة المحلية: $weatherResult');

        final resultPrompt = [
          ...initialPrompt,
          Content.model(functionCalls),
          Content.functionResponse(call.name, weatherResult),
        ];

        print('إرسال النتيجة مرة أخرى إلى Gemini...');
        final finalResponse = await client.generateContentFromPrompt(resultPrompt);
        print('إجابة Gemini النهائية: ${finalResponse.text}');
      }
    } else {
      print('لم يطلب النموذج استدعاء أي دالة وأجاب مباشرة: ${response.text}');
    }

  } on GeminiBridgeException catch (e) {
    print('حدث خطأ في استخدام الأدوات: $e');
  }
}