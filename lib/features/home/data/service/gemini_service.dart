import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:receta_ya/features/home/domain/model/gemini_recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY no está configurada en el archivo .env');
    }
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<GeminiRecipe> generateRecipe(String ingredients) async {
    final prompt =
        '''
Eres un chef experto. El usuario te proporciona los siguientes ingredientes: $ingredients

Crea una receta deliciosa y detallada usando estos ingredientes. 

IMPORTANTE: Responde ÚNICAMENTE con un objeto JSON válido, sin texto adicional antes o después. No uses markdown. El formato debe ser exactamente:

{
  "name": "Nombre de la receta",
  "description": "Descripción breve de la receta (máximo 200 caracteres)",
  "ingredients": [
    {"name": "ingrediente1", "quantity": 100, "unit": "gramos"},
    {"name": "ingrediente2", "quantity": 2, "unit": "unidades"}
  ],
  "instructions": "Paso 1: ... Paso 2: ... Paso 3: ...",
  "servings": 4,
  "prepTimeMinutes": 30,
  "difficulty": "Media",
  "caloriesPerServing": 350,
  "proteinPerServing": 25,
  "carbsPerServing": 40,
  "fatPerServing": 12
}

Reglas CRÍTICAS:
- Responde SOLO el JSON, nada más
- La descripción debe ser atractiva y no superar 200 caracteres
- NUNCA uses "al gusto" o texto en quantity - SIEMPRE debe ser un número (ejemplo: 1, 0.5, 200)
- Si no sabes la cantidad exacta, usa una aproximación numérica razonable
- Los ingredientes deben incluir cantidades específicas en números
- Las instrucciones deben ser claras y numeradas
- difficulty debe ser EXACTAMENTE: "Fácil", "Media" o "Difícil"
- servings debe ser un número entre 1 y 8
- prepTimeMinutes debe ser realista (número en minutos)
- caloriesPerServing, proteinPerServing, carbsPerServing, fatPerServing deben ser números calculados aproximados basados en los ingredientes
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      print('=== GEMINI RAW RESPONSE ===');
      print(responseText);
      print('=== END RESPONSE ===');

      String jsonText = responseText.trim();

      jsonText = jsonText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final startIndex = jsonText.indexOf('{');
      final endIndex = jsonText.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        jsonText = jsonText.substring(startIndex, endIndex + 1);
      }

      final Map<String, dynamic> json = jsonDecode(jsonText);

      final ingredientsList = (json['ingredients'] as List).map((i) {
        double quantity;
        try {
          if (i['quantity'] is num) {
            quantity = (i['quantity'] as num).toDouble();
          } else if (i['quantity'] is String) {
            // Intentar parsear si es string
            quantity = double.tryParse(i['quantity']) ?? 1.0;
          } else {
            quantity = 1.0;
          }
        } catch (e) {
          print('Error parseando cantidad para ${i['name']}: ${i['quantity']}');
          quantity = 1.0;
        }

        return GeminiIngredient(
          name: i['name'].toString(),
          quantity: quantity,
          unit: i['unit'].toString(),
        );
      }).toList();

      return GeminiRecipe(
        name: json['name'].toString(),
        description: json['description'].toString(),
        ingredients: ingredientsList,
        instructions: json['instructions'].toString(),
        servings: (json['servings'] as num).toInt(),
        prepTimeMinutes: (json['prepTimeMinutes'] as num).toInt(),
        difficulty: json['difficulty'].toString(),
        caloriesPerServing: json['caloriesPerServing'] != null
            ? (json['caloriesPerServing'] as num).toDouble()
            : 0.0,
        proteinPerServing: json['proteinPerServing'] != null
            ? (json['proteinPerServing'] as num).toDouble()
            : 0.0,
        carbsPerServing: json['carbsPerServing'] != null
            ? (json['carbsPerServing'] as num).toDouble()
            : 0.0,
        fatPerServing: json['fatPerServing'] != null
            ? (json['fatPerServing'] as num).toDouble()
            : 0.0,
      );
    } catch (e) {
      print('=== ERROR EN GEMINI SERVICE ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('=== END ERROR ===');
      throw Exception('Error al generar receta: ${e.toString()}');
    }
  }
}
