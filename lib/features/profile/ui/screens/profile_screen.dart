import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receta_ya/core/constants/app_text_styles.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_bloc.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_event.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_state.dart';
import 'package:receta_ya/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:receta_ya/features/profile/ui/screens/edit_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: AppTextStyles.title.copyWith(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F4FD), Color(0xFFF4EDFD)],
          ),
        ),
        child: BlocBuilder<ProfileBloc, ProfileState>(
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
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
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
                    // Botón de editar perfil
                    Card(
                      elevation: 2,
                      color: Colors.blue[50],
                      child: ListTile(
                        leading: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 32,
                        ),
                        title: const Text(
                          'Editar Perfil',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Actualizar nombre y foto'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(profile: profile),
                            ),
                          );
                          // Recargar perfil si hubo actualización
                          if (result == true && context.mounted) {
                            context.read<ProfileBloc>().add(LoadProfile(profile.id));
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botón de administración si es admin
                    if (profile.isAdmin)
                      Card(
                        elevation: 2,
                        color: Colors.orange[50],
                        child: ListTile(
                          leading: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.orange,
                            size: 32,
                          ),
                          title: const Text(
                            'Panel de Administración',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Gestionar recetas'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.pushNamed(context, '/admin/recipes');
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Botón de cerrar sesión
                    Card(
                      elevation: 2,
                      color: Colors.red[50],
                      child: ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 32,
                        ),
                        title: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Salir de la aplicación'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),
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
