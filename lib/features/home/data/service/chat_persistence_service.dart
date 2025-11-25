import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receta_ya/features/home/domain/model/chat_message.dart';

class ChatPersistenceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveMessage(ChatMessage message) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('No hay usuario autenticado');
        return;
      }

      await _supabase.from('chat_messages').insert({
        'user_id': userId,
        'message_text': message.text,
        'is_user_message': message.isUser,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('Mensaje guardado en BD');
    } catch (e) {
      print('Error al guardar mensaje: $e');
    }
  }

  Future<List<ChatMessage>> loadMessages() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('No hay usuario autenticado');
        return [];
      }

      final response = await _supabase
          .from('chat_messages')
          .select('message_text, is_user_message, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      return (response as List)
          .map(
            (msg) => ChatMessage(
              text: msg['message_text'].toString(),
              isUser: msg['is_user_message'] as bool,
            ),
          )
          .toList();
    } catch (e) {
      print('Error al cargar mensajes: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('No hay usuario autenticado');
        return;
      }

      await _supabase.from('chat_messages').delete().eq('user_id', userId);

      print('Historial de chat eliminado');
    } catch (e) {
      print('Error al eliminar historial: $e');
    }
  }
}
