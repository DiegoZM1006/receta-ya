import 'package:flutter/material.dart';
import 'package:receta_ya/core/constants/app_colors.dart';
import 'package:receta_ya/features/home/domain/model/chat_message.dart';
import 'package:receta_ya/features/home/domain/usecases/generate_recipe_usecase.dart';
import 'package:receta_ya/features/home/domain/model/gemini_recipe.dart';
import 'package:receta_ya/features/home/data/service/chat_persistence_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final GenerateRecipeUseCase _generateRecipeUseCase = GenerateRecipeUseCase();
  final ChatPersistenceService _chatPersistence = ChatPersistenceService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final savedMessages = await _chatPersistence.loadMessages();

    setState(() {
      if (savedMessages.isEmpty) {
        _messages.add(
          ChatMessage(
            text:
                '¡Hola! Soy tu asistente de cocina. Dime qué ingredientes tienes y te crearé una receta deliciosa.',
            isUser: false,
          ),
        );
      } else {
        _messages.addAll(savedMessages);
      }
    });

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMessage = ChatMessage(text: text, isUser: true);

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    // Guardar mensaje del usuario
    await _chatPersistence.saveMessage(userMessage);

    _messageController.clear();
    _scrollToBottom();

    try {
      final result = await _generateRecipeUseCase.execute(text);
      final recipe = result['recipe'] as GeminiRecipe;
      final recipeId = result['recipeId'] as String;

      final responseText = _formatRecipeResponse(recipe, recipeId);

      final botMessage = ChatMessage(text: responseText, isUser: false);

      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
      });

      // Guardar mensaje del bot
      await _chatPersistence.saveMessage(botMessage);

      _scrollToBottom();
    } catch (e) {
      String errorMessage = 'Lo siento, ocurrió un error al generar la receta.';

      if (e.toString().contains('API key')) {
        errorMessage =
            'Error: La API key de Gemini no está configurada correctamente.';
      } else if (e.toString().contains('JSON')) {
        errorMessage =
            'Error: No pude procesar la respuesta. Intenta con otros ingredientes.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage =
            'Error de conexión. Verifica tu internet e intenta de nuevo.';
      }

      final errorBotMessage = ChatMessage(text: errorMessage, isUser: false);

      setState(() {
        _messages.add(errorBotMessage);
        _isLoading = false;
      });

      // Guardar mensaje de error
      await _chatPersistence.saveMessage(errorBotMessage);

      _scrollToBottom();
    }
  }

  String _formatRecipeResponse(GeminiRecipe recipe, String recipeId) {
    final buffer = StringBuffer();
    buffer.writeln('¡He creado una receta para ti!\n');
    buffer.writeln('📝 ${recipe.name}');
    buffer.writeln('\n${recipe.description}\n');
    buffer.writeln('👥 Porciones: ${recipe.servings}');
    buffer.writeln('⏱️ Tiempo: ${recipe.prepTimeMinutes} minutos');
    buffer.writeln('📊 Dificultad: ${recipe.difficulty}');
    buffer.writeln('\n🔥 Información Nutricional (por porción):');
    buffer.writeln(
      '• Calorías: ${recipe.caloriesPerServing.toStringAsFixed(0)} kcal',
    );
    buffer.writeln(
      '• Proteínas: ${recipe.proteinPerServing.toStringAsFixed(1)}g',
    );
    buffer.writeln(
      '• Carbohidratos: ${recipe.carbsPerServing.toStringAsFixed(1)}g',
    );
    buffer.writeln('• Grasas: ${recipe.fatPerServing.toStringAsFixed(1)}g');
    buffer.writeln('\n🥘 Ingredientes:');
    for (var ingredient in recipe.ingredients) {
      buffer.writeln(
        '• ${ingredient.quantity} ${ingredient.unit} de ${ingredient.name}',
      );
    }
    buffer.writeln('\n📖 Instrucciones:');

    // Parsear y formatear los pasos
    final instructions = recipe.instructions;
    final steps = instructions.split(RegExp(r'Paso \d+:'));

    int stepNumber = 1;
    for (var step in steps) {
      final trimmedStep = step.trim();
      if (trimmedStep.isNotEmpty) {
        buffer.writeln('\nPaso $stepNumber:');
        buffer.writeln(trimmedStep);
        stepNumber++;
      }
    }

    return buffer.toString();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar historial'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar todo el historial del chat? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearChatHistory();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearChatHistory() async {
    await _chatPersistence.clearHistory();

    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
          text:
              '¡Hola! Soy tu asistente de cocina. Dime qué ingredientes tienes y te crearé una receta deliciosa.',
          isUser: false,
        ),
      );
    });

    // Guardar mensaje de bienvenida
    await _chatPersistence.saveMessage(_messages.first);

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chat de Recetas',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: _showClearHistoryDialog,
            tooltip: 'Limpiar historial',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Generando receta...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primary
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Escribe tus ingredientes...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
