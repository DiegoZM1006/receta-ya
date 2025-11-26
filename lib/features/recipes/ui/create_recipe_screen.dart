import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receta_ya/core/constants/app_colors.dart';
import 'package:receta_ya/core/widgets/primary_button.dart';
import 'package:receta_ya/domain/model/recipe.dart';
import 'package:receta_ya/domain/model/ingredient.dart';
import 'package:receta_ya/features/recipes/presentation/cubit/admin_recipes_cubit.dart';
import 'package:receta_ya/features/recipes/ui/widgets/ingredient_list_widget.dart';
import 'package:receta_ya/features/recipes/ui/widgets/image_picker_widget.dart';
import 'package:receta_ya/features/meal_types/presentation/cubit/meal_types_cubit.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  String? _imageUrl;
  String? _difficulty;
  List<Ingredient> _ingredients = [];
  List<String> _selectedMealTypeIds = [];

  @override
  void initState() {
    super.initState();
    context.read<MealTypesCubit>().loadMealTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      if (_ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes agregar al menos un ingrediente'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedMealTypeIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes seleccionar al menos un tipo de comida'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final recipe = Recipe(
        id: '', // Se genera en el servidor
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        imageUrl: _imageUrl,
        caloriesPerPortion: _caloriesController.text.isEmpty
            ? null
            : double.parse(_caloriesController.text.trim()),
        proteinsPerPortion: _proteinsController.text.isEmpty
            ? null
            : int.parse(_proteinsController.text.trim()),
        carbsPerPortion: _carbsController.text.isEmpty
            ? null
            : int.parse(_carbsController.text.trim()),
        fatsPerPortion: _fatsController.text.isEmpty
            ? null
            : int.parse(_fatsController.text.trim()),
        prepTimeMinutes: _prepTimeController.text.isEmpty
            ? null
            : int.parse(_prepTimeController.text.trim()),
        baseServings: _servingsController.text.isEmpty
            ? null
            : int.parse(_servingsController.text.trim()),
        difficulty: _difficulty,
        ingredients: _ingredients,
      );

      context.read<AdminRecipesCubit>().createNewRecipe(recipe, _selectedMealTypeIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Receta'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AdminRecipesCubit, AdminRecipesState>(
        listener: (context, state) {
          if (state.status == AdminRecipesStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage ?? 'Receta creada'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Retornar true para indicar éxito
          } else if (state.status == AdminRecipesStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error al crear receta'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AdminRecipesCubit, AdminRecipesState>(
          builder: (context, adminState) {
            if (adminState.status == AdminRecipesStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la receta',
                      hintText: 'Ej: Pasta Carbonara',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Describe brevemente la receta',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ImagePickerWidget(
                    initialImageUrl: _imageUrl,
                    onImageUrlChanged: (url) {
                      setState(() {
                        _imageUrl = url;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Información nutricional (por porción)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _caloriesController,
                          decoration: const InputDecoration(
                            labelText: 'Calorías',
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _proteinsController,
                          decoration: const InputDecoration(
                            labelText: 'Proteínas (g)',
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _carbsController,
                          decoration: const InputDecoration(
                            labelText: 'Carbohidratos (g)',
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _fatsController,
                          decoration: const InputDecoration(
                            labelText: 'Grasas (g)',
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Detalles de preparación',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prepTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Tiempo (minutos)',
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _servingsController,
                          decoration: const InputDecoration(
                            labelText: 'Porciones',
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _difficulty,
                    decoration: const InputDecoration(
                      labelText: 'Dificultad',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Fácil', 'Media', 'Difícil']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _difficulty = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tipos de comida',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<MealTypesCubit, MealTypesState>(
                    builder: (context, mealTypesState) {
                      if (mealTypesState.status == MealTypesStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (mealTypesState.status == MealTypesStatus.failure) {
                        return const Text('Error al cargar tipos de comida');
                      }

                      final mealTypes = mealTypesState.mealTypes;

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mealTypes.map((mealType) {
                          final isSelected = _selectedMealTypeIds.contains(mealType.id);
                          return FilterChip(
                            label: Text(mealType.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedMealTypeIds.add(mealType.id);
                                } else {
                                  _selectedMealTypeIds.remove(mealType.id);
                                }
                              });
                            },
                            selectedColor: AppColors.primary.withOpacity(0.3),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  IngredientListWidget(
                    ingredients: _ingredients,
                    onIngredientsChanged: (ingredients) {
                      setState(() {
                        _ingredients = ingredients;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instrucciones',
                      hintText: 'Describe paso a paso cómo preparar la receta',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 8,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Crear Receta',
                    onPressed: _saveRecipe,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
