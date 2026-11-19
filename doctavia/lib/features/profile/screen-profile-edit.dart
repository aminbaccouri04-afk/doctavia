import 'dart:io';
import 'package:flutter/material.dart';
import 'package:doctavia/core/providers/provider-content.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctavia/core/providers/provider-auth.dart';
import 'package:doctavia/core/providers/provider-family.dart';
import 'package:doctavia/core/providers/provider-doctor.dart';
import 'package:doctavia/core/widgets/widget-doctavia-input.dart';
import 'package:doctavia/core/widgets/widget-doctavia-button.dart';
import 'package:doctavia/core/theme/theme.dart';

class ScreenProfileEdit extends StatefulWidget {
  const ScreenProfileEdit({super.key});

  @override
  State<ScreenProfileEdit> createState() => _ScreenProfileEditState();
}

class _ScreenProfileEditState extends State<ScreenProfileEdit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    String initialName = '';
    String initialPhone = '';

    if (auth.userRole == 'doctor') {
      final docProfile = context.read<DoctorProvider>().myProfile;
      initialName = docProfile?.fullName ?? '';
    } else {
      final profiles = context.read<FamilyProvider>().profiles;
      try {
        final self = profiles.firstWhere(
          (p) => p.relationship.toLowerCase() == 'self',
        );
        initialName = self.fullName;
      } catch (_) {
        initialName = user?.email.split('@')[0] ?? '';
      }
    }

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(
      text: initialPhone.isEmpty ? '+213 550 123 456' : initialPhone,
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppContent.get('profile.screen.editProfile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : null,
                        child: _imageFile == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              )
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
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              WidgetDoctaviaInput(
                controller: _nameController,
                label: AppContent.get('profile.labels.fullName'),
              ),
              const SizedBox(height: 20),
              WidgetDoctaviaInput(
                controller: _emailController,
                label: AppContent.get('profile.labels.email'),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              WidgetDoctaviaInput(
                controller: _phoneController,
                label: AppContent.get('common.labels.phoneNumber'),
              ),
              const SizedBox(height: 20),
              WidgetDoctaviaInput(
                controller: TextEditingController(text: 'Algiers, Algeria'),
                label: AppContent.get('common.labels.location'),
              ),
              const SizedBox(height: 40),
              WidgetDoctaviaButton(
                text: AppContent.get('common.buttons.save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppContent.get('profile.screen.profileUpdated'))),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

