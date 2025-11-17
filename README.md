
# Gemini Bridge

A pure Dart bridge to the Google Gemini API. Lightweight, powerful, and without any Flutter dependencies.

---

[English](#english) | [العربية](#العربية)

---

<a name="english"></a>

## 🇬🇧 English

[![pub version](https://img.shields.io/pub/v/gemini_bridge.svg)](https://pub.dev/packages/gemini_bridge)
[![license](https://img.shields.io/badge/license-Apache%202.0-red.svg)](LICENSE)

A flexible and lightweight Dart package that provides a direct interface to the Google Gemini API (via the Google AI Developer endpoint). It's designed for developers building pure Dart applications (server-side, CLI, backend) who need to integrate generative AI without the overhead of the Flutter framework.

### ✨ Features

-   **✅ Pure Dart:** No Flutter dependencies. Works anywhere Dart runs.
-   **🔑 Direct API Key Usage:** Initialize the client directly with a user-provided API key.
-   **💬 Unary & Streaming:** Supports both simple `generateContent` requests and real-time `generateContentStream` responses.
-   **🔩 Controlled Generation (JSON Mode):** Force the model to output valid JSON based on a provided schema.
-   **🛠️ Tool Use (Function Calling):** Define tools and functions that the model can call to interact with external systems.
-   **🛡️ Robust Error Handling:** Includes specific exceptions for API key issues and quota limits.

### 🏁 Getting Started

1.  **Add the dependency**

    Add this to your package's `pubspec.yaml` file:

    ```yaml
    dependencies:
      gemini_bridge: ^1.0.0 
    ```

    Or run this command in your terminal:
    ```bash
    dart pub add gemini_bridge
    ```

2.  **Import the package**

    ```dart
    import 'package:gemini_bridge/gemini_bridge.dart';
    ```

### 📝 Usage

First, get your API key from [Google AI Studio](https://aistudio.google.com/app/apikey) and initialize the client.

```dart
final client = GeminiClient(apiKey: 'YOUR_GEMINI_API_KEY');
```

---

#### 1. Basic Text Generation

```dart
try {
  final response = await client.generateContent(
    'Why is the sky blue? Give a short explanation.'
  );
  print(response.text);
} on GeminiBridgeException catch (e) {
  print('An error occurred: $e');
}
```

---

#### 2. Streaming Response

```dart
// The prompt must be an Iterable<Content>
final prompt = [Content.text('Tell me a short, futuristic story about a programmer.')];
final stream = client.generateContentStream(prompt);

await for (final chunk in stream) {
  stdout.write(chunk.text);
}
```

---

#### 3. Controlled Generation (JSON Output)

Force the model to output valid JSON.

```dart
// 1. Define the desired JSON structure using a Schema.
final recipeSchema = Schema.object(properties: {
  'recipeName': Schema.string(description: 'The name of the recipe.'),
  // ... other properties
});

// 2. Configure the generation to use the schema.
final generationConfig = GenerationConfig(
  responseMimeType: 'application/json',
  responseSchema: recipeSchema,
);

// 3. Send the request.
final response = await client.generateContentFromPrompt(
  [Content.text('Generate a simple recipe.')],
  generationConfig: generationConfig,
);

print(response.text);
```

---

#### 4. Tool Use (Function Calling)

Give the model tools (functions) it can call.

```dart
// 1. Define a function declaration for your tool.
final weatherFunction = FunctionDeclaration(
  'getCurrentWeather',
  'Get the current weather in a given location.',
  // ... parameters schema
);

final tool = Tool.functionDeclarations([weatherFunction]);

// 2. Send the initial prompt.
final response = await client.generateContentFromPrompt(
  [Content.text("What is the weather like in Boston?")],
  tools: [tool],
);

// 3. Handle the FunctionCall request from the model and send the result back.
final functionCalls = response.functionCalls;
if (functionCalls.isNotEmpty) {
  final call = functionCalls.first;
  final weatherResult = { "temperature": "72", "unit": "F", "description": "Sunny" };
    
  final resultPrompt = [
    ...initialPrompt, 
    Content.model(functionCalls), 
    Content.functionResponse(call.name, weatherResult), 
  ];

  final finalResponse = await client.generateContentFromPrompt(resultPrompt);
  print('Final Gemini Answer: ${finalResponse.text}');
}
```

---

<a name="العربية"></a>

## 🇸🇦 العربية

[![pub version](https://img.shields.io/pub/v/gemini_bridge.svg)](https://pub.dev/packages/gemini_bridge)
[![license](https://img.shields.io/badge/license-Apache%202.0-red.svg)](LICENSE)

حزمة Dart خفيفة ومرنة توفر واجهة مباشرة لواجهة برمجة تطبيقات Google Gemini (عبر نقطة Google AI Developer Endpoint). تم تصميمها للمطورين الذين يبنون تطبيقات Dart نقية (للخوادم، أو واجهة الأوامر، أو الواجهات الخلفية) ويحتاجون إلى دمج الذكاء الاصطناعي التوليدي دون الحاجة إلى إطار عمل Flutter.

### ✨ الميزات

-   **✅ Dart نقي:** لا توجد أي اعتماديات على Flutter. تعمل في أي مكان يمكن تشغيل Dart فيه.
-   **🔑 استخدام مباشر لمفتاح API:** قم بتهيئة العميل مباشرةً باستخدام مفتاح API الذي يوفره المستخدم.
-   **💬 استجابات فردية ومتدفقة:** تدعم كلاً من طلبات `generateContent` البسيطة واستجابات `generateContentStream` في الوقت الفعلي.
-   **🔩 توليد مُتحكَم به (وضع JSON):** إجبار النموذج على إخراج كائن JSON صالح بناءً على مخطط (schema) محدد.
-   **🛠️ استخدام الأدوات (استدعاء الدوال):** تعريف أدوات ودوال يمكن للنموذج استدعاؤها للتفاعل مع الأنظمة الخارجية.
-   **🛡️ معالجة قوية للأخطاء:** تتضمن استثناءات محددة لمشاكل مفتاح API وحدود الحصص.

### 🏁 البدء

1.  **أضف الاعتمادية**

    أضف هذا إلى ملف `pubspec.yaml` الخاص بحزمتك:

    ```yaml
    dependencies:
      gemini_bridge: ^1.0.0 
    ```

    أو قم بتشغيل هذا الأمر في الطرفية:
    ```bash
    dart pub add gemini_bridge
    ```

2.  **استورد الحزمة**

    ```dart
    import 'package:gemini_bridge/gemini_bridge.dart';
    ```

### 📝 الاستخدام

أولاً، احصل على مفتاح API الخاص بك من [Google AI Studio](https://aistudio.google.com/app/apikey) وقم بتهيئة العميل.

```dart
final client = GeminiClient(apiKey: 'YOUR_GEMINI_API_KEY');
```

---

#### 1. توليد نص بسيط

```dart
try {
  final response = await client.generateContent(
    'لماذا السماء زرقاء؟ اشرح باختصار.'
  );
  print(response.text);
} on GeminiBridgeException catch (e) {
  print('حدث خطأ: $e');
}
```

---

#### 2. استجابة متدفقة (Streaming)

```dart
final prompt = [Content.text('اخبرني قصة مستقبلية قصيرة عن مبرمج.')];
final stream = client.generateContentStream(prompt);

await for (final chunk in stream) {
  stdout.write(chunk.text);
}
```

---

#### 3. توليد مُتحكَم به (مخرجات JSON)

إجبار النموذج على إخراج كائن JSON صالح.

```dart
// 1. حدد بنية JSON المطلوبة باستخدام Schema.
final recipeSchema = Schema.object(properties: {
  'recipeName': Schema.string(description: 'اسم الوصفة.'),
  // ... خصائص أخرى
});

// 2. قم بتكوين عملية التوليد لاستخدام المخطط.
final generationConfig = GenerationConfig(
  responseMimeType: 'application/json',
  responseSchema: recipeSchema,
);

// 3. أرسل الطلب.
final response = await client.generateContentFromPrompt(
  [Content.text('أنشئ وصفة بسيطة.')],
  generationConfig: generationConfig,
);

print(response.text);
```

---

#### 4. استخدام الأدوات (استدعاء الدوال)

أعطِ النموذج أدوات يمكنه استخدامها للإجابة على الأسئلة.

```dart
// 1. حدد تعريف دالة لأداتك.
final weatherFunction = FunctionDeclaration(
  'getCurrentWeather',
  'الحصول على الطقس الحالي في موقع معين.',
  // ... معاملات المخطط
);

final tool = Tool.functionDeclarations([weatherFunction]);

// 2. أرسل الموجه الأولي.
final response = await client.generateContentFromPrompt(
  [Content.text("ما هو الطقس في بوسطن؟")],
  tools: [tool],
);

// 3. قم بالتعامل مع طلب FunctionCall من النموذج وأرسل النتيجة مرة أخرى.
final functionCalls = response.functionCalls;
if (functionCalls.isNotEmpty) {
  final call = functionCalls.first;
  final weatherResult = { "temperature": "22", "unit": "C", "description": "مشمس" };
    
  final resultPrompt = [
    ...initialPrompt, 
    Content.model(functionCalls), 
    Content.functionResponse(call.name, weatherResult), 
  ];

  final finalResponse = await client.generateContentFromPrompt(resultPrompt);
  print('إجابة Gemini النهائية: ${finalResponse.text}');
}
```

---

## 🛑 Important Note / ملاحظة هامة

This project, **`gemini_bridge`**, reuses data structures, serialization logic, and error handling components from the official **`firebase_ai`** package (published by Google and licensed under Apache License 2.0).

While Apache 2.0 permits modification and redistribution, this package is an **independent, community effort** and is **not affiliated with or officially endorsed by Google or the Firebase team**.

**Why this matters:**

*   **Maintenance:** This package's future maintenance and feature parity with the latest Gemini models depend on community contributions.
*   **API Compatibility:** Future changes in the underlying Google AI Developer API might require updates here that may not be instantaneous.
*   **License Compliance:** We strictly adhere to the Apache License 2.0 terms, ensuring all necessary copyright and license notices are preserved in the source code.

**⚠️ Disclaimer:** Use this package at your own discretion. If you require official support, continuous updates guaranteed by Google, and integration with Firebase services (such as App Check), please use the official **`firebase_ai`** package.

---

هذا المشروع، **`gemini_bridge`**، يعيد استخدام هياكل البيانات، ومنطق التحويل (Serialization)، ومكونات معالجة الأخطاء من الحزمة الرسمية **`firebase_ai`** (المنشورة بواسطة Google ومرخصة بموجب ترخيص Apache License 2.0).

على الرغم من أن ترخيص Apache 2.0 يسمح بالتعديل وإعادة التوزيع، فإن هذه الحزمة تُعد **جهدًا مجتمعيًا مستقلاً** و**ليست تابعة أو معتمدة رسميًا من قبل Google أو فريق Firebase**.

**لماذا هذه الملاحظة مهمة:**

*   **الصيانة:** تعتمد صيانة هذه الحزمة ومواكبتها للميزات الجديدة في نماذج Gemini على المساهمات المجتمعية.
*   **توافق API:** قد تتطلب التغييرات المستقبلية في واجهة Google AI Developer API الأساسية تحديثات فورية هنا.
*   **الالتزام بالترخيص:** نحن نلتزم بشدة بشروط ترخيص Apache License 2.0، مما يضمن الحفاظ على جميع إشعارات حقوق النشر والترخيص الضرورية في الكود المصدري.

**⚠️ إخلاء مسؤولية:** استخدامك لهذه الحزمة هو على مسؤوليتك الخاصة. إذا كنت بحاجة إلى دعم رسمي، وتحديثات مستمرة مضمونة من Google، وتكامل مع خدمات Firebase (مثل App Check)، يرجى استخدام حزمة **`firebase_ai`** الرسمية.