library;

export 'src/client/gemini_client.dart';
export 'src/core/error.dart';

export 'src/firebase_ai/api.dart'
    show
        BlockReason,
        Candidate,
        CountTokensResponse,
        FinishReason,
        GenerateContentResponse,
        GenerationConfig,
        HarmBlockThreshold,
        HarmCategory,
        SafetySetting;
        
export 'src/firebase_ai/content.dart'
    show
        Content,
        FunctionCall,
        FunctionResponse,
        InlineDataPart,
        Part,
        TextPart,
        UnknownPart;

export 'src/firebase_ai/schema.dart' 
    show 
        Schema, 
        SchemaType;

export 'src/firebase_ai/tool.dart'
    show
        FunctionCallingConfig,
        FunctionCallingMode,
        FunctionDeclaration,
        Tool,
        ToolConfig;

export 'src/firebase_ai/developer/api.dart'
    show
        DeveloperSerialization;