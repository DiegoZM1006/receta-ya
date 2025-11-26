import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receta_ya/features/profile/domain/usecases/update_onboarding_data_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;

  // onboarding data
  String cookingSkill = '';
  List<String> cookingGoals = [];
  int typicalServings = 1;
  String cookingTimePreference = '';

  final UpdateOnboardingDataUseCase _updateOnboardingDataUseCase =
      UpdateOnboardingDataUseCase();

  void _next() {
    if (step < 3) {
      setState(() => step++);
    } else {
      _submitOnboarding();
    }
  }

  void _back() {
    if (step > 0) setState(() => step--);
  }

  Future<void> _submitOnboarding() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await _updateOnboardingDataUseCase.execute(
        user.id,
        cookingSkill: cookingSkill,
        cookingGoals: cookingGoals,
        typicalServings: typicalServings,
        cookingTimePreference: cookingTimePreference,
      );

      // Navigate to home with bottom navigation after successful onboarding
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      print('Error saving onboarding data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar tus preferencias')),
      );
    }
  }

  Widget _buildStepContent() {
    switch (step) {
      case 0:
        return _skillStep();
      case 1:
        return _goalsStep();
      case 2:
        return _servingsStep();
      case 3:
        return _timeStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _skillStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Qué tan bueno eres cocinando?',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _skillOption(
          'Intermedio',
          'Tienes práctica, improvisas con ingredientes',
          'intermedio',
        ),
        const SizedBox(height: 8),
        _skillOption('Bueno', 'Te defiendes en la cocina', 'bueno'),
        const SizedBox(height: 8),
        _skillOption(
          'Excelente',
          'Dominas la cocina y creas recetas propias',
          'excelente',
        ),
      ],
    );
  }

  Widget _skillOption(String title, String subtitle, String value) {
    final selected = cookingSkill == value;
    return GestureDetector(
      onTap: () => setState(() => cookingSkill = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF386BF6) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: Color(0xFF386BF6)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalsStep() {
    final options = [
      'Comida rápida',
      'Fitness goals',
      'Rápido y fácil',
      'Ahorrar tiempo',
      'Sorprender',
      'Alimentación sana',
      'Alto en proteína',
      'Compartir en familia',
      'Probar recetas',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Qué buscas al cocinar?',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) => _chipGoal(o)).toList(),
        ),
      ],
    );
  }

  Widget _chipGoal(String label) {
    final selected = cookingGoals.contains(label);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected)
          cookingGoals.remove(label);
        else
          cookingGoals.add(label);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF386BF6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _servingsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '¿Normalmente para cuántas personas cocinas?',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => setState(() => typicalServings++),
                icon: const Icon(Icons.add),
              ),
              Text(
                '$typicalServings',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  if (typicalServings > 1) typicalServings--;
                }),
                icon: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeStep() {
    final options = {
      '< 30 minutos': 'lt30',
      '30 - 60 minutos': '30_60',
      '+ 1 hora': 'gt60',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cuánto tiempo sueles dedicar a cocinar en un día normal?',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...options.entries
            .map(
              (e) => GestureDetector(
                onTap: () => setState(() => cookingTimePreference = e.value),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cookingTimePreference == e.value
                          ? const Color(0xFF386BF6)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: GoogleFonts.poppins(fontSize: 16)),
                      if (cookingTimePreference == e.value)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF386BF6),
                        ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F4FD), Color(0xFFF4EDFD)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              children: [
                Text(
                  'Recetas Ya',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${step + 1}/4',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(child: _buildStepContent()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        child: Text('Atras', style: GoogleFonts.poppins()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF386BF6),
                        ),
                        child: Text(
                          step < 3 ? 'Siguiente' : 'Finalizar',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
