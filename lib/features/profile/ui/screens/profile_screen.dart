import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_bloc.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_event.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_state.dart';
import 'package:receta_ya/features/auth/domain/usecases/get_current_user_usecase.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ProfileBloc();
        _loadProfile(bloc);
        return bloc;
      },
      child: const ProfileView(),
    );
  }

  Future<void> _loadProfile(ProfileBloc bloc) async {
    final getCurrentUser = GetCurrentUserUseCase();
    final userId = await getCurrentUser.execute();
    if (userId != null) {
      bloc.add(LoadProfile(userId));
    }
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final getCurrentUser = GetCurrentUserUseCase();
                      final userId = await getCurrentUser.execute();
                      if (userId != null) {
                        context.read<ProfileBloc>().add(LoadProfile(userId));
                      }
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard('Información Personal', [
                    _buildInfoRow('Nombre', profile.name),
                    _buildInfoRow('Email', profile.email),
                    _buildInfoRow(
                      'Miembro desde',
                      _formatDate(profile.createdAt),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  // Puedes agregar más secciones aquí
                ],
              ),
            );
          }

          return const Center(
            child: Text('No hay información del perfil disponible'),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
