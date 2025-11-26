import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receta_ya/domain/model/profile.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_bloc.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_event.dart';
import 'package:receta_ya/features/profile/ui/bloc/profile_state.dart';
import 'package:receta_ya/core/constants/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  final Profile profile;

  const EditProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: _EditProfileScreenContent(profile: profile),
    );
  }
}

class _EditProfileScreenContent extends StatefulWidget {
  final Profile profile;

  const _EditProfileScreenContent({Key? key, required this.profile}) : super(key: key);

  @override
  State<_EditProfileScreenContent> createState() => _EditProfileScreenContentState();
}

class _EditProfileScreenContentState extends State<_EditProfileScreenContent> {
  late TextEditingController _nameController;
  File? _selectedImage;
  String? _currentAvatarUrl;
  bool _isUploading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _currentAvatarUrl = widget.profile.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error al tomar foto: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = '${widget.profile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage
          .from('ProfileImages')
          .upload(fileName, _selectedImage!);

      final url = Supabase.instance.client.storage
          .from('ProfileImages')
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      _showError('Error al subir imagen: $e');
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteCurrentAvatar() async {
    if (_currentAvatarUrl == null) return;

    try {
      // Extract filename from URL
      final uri = Uri.parse(_currentAvatarUrl!);
      final fileName = uri.pathSegments.last;

      await Supabase.instance.client.storage
          .from('ProfileImages')
          .remove([fileName]);

      setState(() {
        _currentAvatarUrl = null;
      });
    } catch (e) {
      _showError('Error al eliminar imagen: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            if (_currentAvatarUrl != null || _selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto'),
                onTap: () async {
                  Navigator.pop(context);
                  if (_currentAvatarUrl != null) {
                    await _deleteCurrentAvatar();
                  }
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showError('Por favor ingresa tu nombre');
      return;
    }

    if (name.length < 2) {
      _showError('El nombre debe tener al menos 2 caracteres');
      return;
    }

    String? avatarUrl = _currentAvatarUrl;

    // Upload new image if selected
    if (_selectedImage != null) {
      // Delete old avatar if exists
      if (_currentAvatarUrl != null) {
        await _deleteCurrentAvatar();
      }
      avatarUrl = await _uploadImage();
      if (avatarUrl == null && _selectedImage != null) {
        _showError('No se pudo subir la imagen');
        return;
      }
    }

    context.read<ProfileBloc>().add(
      UpdateProfileInfo(
        userId: widget.profile.id,
        name: name,
        avatarUrl: avatarUrl,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            _showSuccess('Perfil actualizado correctamente');
            Navigator.pop(context, true); // Retornar true para indicar actualización exitosa
          } else if (state is ProfileError) {
            _showError(state.message);
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isLoading = state is ProfileUpdating || _isUploading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar section
                  GestureDetector(
                    onTap: isLoading ? null : _showImageSourceDialog,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_currentAvatarUrl != null
                                  ? NetworkImage(_currentAvatarUrl!)
                                  : null) as ImageProvider?,
                          child: (_selectedImage == null && _currentAvatarUrl == null)
                              ? const Icon(Icons.person, size: 80, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Name field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nombre',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        enabled: !isLoading,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu nombre',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Email field (read-only)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Correo Electrónico',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: TextEditingController(text: widget.profile.email),
                        enabled: false,
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: const Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'El correo electrónico no puede ser modificado',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Guardar Cambios',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
