import 'package:flutter/material.dart';
import 'package:receta_ya/domain/model/ingredient.dart';
import 'package:receta_ya/core/constants/app_colors.dart';

class IngredientListWidget extends StatefulWidget {
  final List<Ingredient> ingredients;
  final Function(List<Ingredient>) onIngredientsChanged;

  const IngredientListWidget({
    super.key,
    required this.ingredients,
    required this.onIngredientsChanged,
  });

  @override
  State<IngredientListWidget> createState() => _IngredientListWidgetState();
}

class _IngredientListWidgetState extends State<IngredientListWidget> {
  late List<Ingredient> _ingredients;

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.ingredients);
  }

  void _addIngredient() {
    showDialog(
      context: context,
      builder: (context) => _IngredientDialog(
        onSave: (ingredient) {
          setState(() {
            _ingredients.add(ingredient);
            widget.onIngredientsChanged(_ingredients);
          });
        },
      ),
    );
  }

  void _editIngredient(int index) {
    showDialog(
      context: context,
      builder: (context) => _IngredientDialog(
        ingredient: _ingredients[index],
        onSave: (ingredient) {
          setState(() {
            _ingredients[index] = ingredient;
            widget.onIngredientsChanged(_ingredients);
          });
        },
      ),
    );
  }

  void _deleteIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      widget.onIngredientsChanged(_ingredients);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ingredientes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_ingredients.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No hay ingredientes agregados',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = _ingredients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(ingredient.name),
                  subtitle: Text('${ingredient.quantity} ${ingredient.unit}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _editIngredient(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteIngredient(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _IngredientDialog extends StatefulWidget {
  final Ingredient? ingredient;
  final Function(Ingredient) onSave;

  const _IngredientDialog({
    this.ingredient,
    required this.onSave,
  });

  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _caloriesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.ingredient?.quantity.toString() ?? '',
    );
    _unitController = TextEditingController(text: widget.ingredient?.unit ?? '');
    _caloriesController = TextEditingController(
      text: widget.ingredient?.caloriesPerUnit?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final ingredient = Ingredient(
        id: widget.ingredient?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text.trim()),
        unit: _unitController.text.trim(),
        caloriesPerUnit: _caloriesController.text.isEmpty
            ? null
            : double.parse(_caloriesController.text.trim()),
      );
      widget.onSave(ingredient);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ingredient == null ? 'Agregar Ingrediente' : 'Editar Ingrediente'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  if (double.tryParse(value!) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unidad (ej: gramos, tazas)'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calorías por unidad (opcional)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
