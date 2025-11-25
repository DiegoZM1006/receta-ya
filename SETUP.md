# Receta Ya - Configuración del Proyecto

## Configuración de Variables de Entorno

Este proyecto utiliza variables de entorno para proteger información sensible como API keys.

### Pasos para configurar:

1. **Copia el archivo de ejemplo:**
   ```bash
   cp .env.example .env
   ```

2. **Edita el archivo `.env` y agrega tu API key de Gemini:**
   ```
   GEMINI_API_KEY=tu_api_key_real_aqui
   ```

3. **Obtén tu API key de Gemini:**
   - Ve a [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Genera una nueva API key
   - Copia y pega la key en tu archivo `.env`

### ⚠️ IMPORTANTE

- **NUNCA** subas el archivo `.env` a GitHub
- El archivo `.env` ya está incluido en `.gitignore`
- Comparte solo el archivo `.env.example` (sin la key real)
- Cada desarrollador debe crear su propio archivo `.env` local

### Instalación de dependencias

```bash
flutter pub get
```

### Ejecutar la aplicación

```bash
flutter run
```

## Estructura del Proyecto

El proyecto sigue Clean Architecture:

```
lib/
├── core/                  # Widgets y constantes compartidos
├── features/              # Características de la app
│   ├── auth/             # Autenticación
│   ├── home/             # Pantalla principal y chat
│   ├── recipes/          # Gestión de recetas
│   └── ...
└── main.dart
```

## Base de Datos

El proyecto usa Supabase. Asegúrate de tener las siguientes tablas:

- `recipes` - Recetas guardadas
- `ingredients` - Ingredientes
- `recipe_ingredients` - Relación muchos a muchos
- `chat_messages` - Historial del chat

## Tecnologías

- Flutter 3.8.1+
- Supabase (Backend)
- Google Gemini AI (Generación de recetas)
- flutter_bloc (State Management)
