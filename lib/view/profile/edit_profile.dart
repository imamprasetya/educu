import 'dart:convert';
import 'dart:io';
import 'package:educu_project/constant/app_color.dart';
import 'package:educu_project/models/user_model.dart';
import 'package:educu_project/database/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  String? photoBase64;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name ?? "";
    emailController.text = widget.user.email ?? "";
    photoBase64 = widget.user.photoBase64;
  }

  // Pick image dari gallery
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        setState(() {
          selectedImage = file;
          photoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick image: $e")),
        );
      }
    }
  }



  // Hapus foto
  void _removePhoto() {
    setState(() {
      selectedImage = null;
      photoBase64 = null;
    });
  }

  // Simpan perubahan ke Firebase
  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final updatedUser = widget.user.copyWith(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        photoBase64: photoBase64,
        clearPhoto: photoBase64 == null,
      );

      await DBHelper.updateUser(widget.user.id!, updatedUser.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Build avatar widget
  Widget _buildAvatar() {
    ImageProvider? imageProvider;

    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
    } else if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(photoBase64!));
      } catch (_) {
        imageProvider = null;
      }
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFF6C7AE0),
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.gradien2,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColor.gradien1,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // FOTO PROFILE
          Center(
            child: Column(
              children: [
                _buildAvatar(),
                const SizedBox(height: 10),
                if (photoBase64 != null || selectedImage != null)
                  TextButton.icon(
                    onPressed: _removePhoto,
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    label: const Text(
                      "Remove Photo",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // NAME
          Text(
            "Full Name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: TextStyle(color: AppColor.textPrimary(context)),
            decoration: InputDecoration(
              hintText: "Enter your name",
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppColor.iconColor(context),
              ),
              filled: true,
              fillColor: AppColor.inputFill(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // EMAIL (read-only karena Firebase Auth)
          Text(
            "Email",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            style: TextStyle(color: AppColor.textPrimary(context)),
            decoration: InputDecoration(
              hintText: "Email",
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColor.iconColor(context),
              ),
              filled: true,
              fillColor: AppColor.isDark(context)
                  ? const Color(0xFF1E1E3A)
                  : Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 35),

          // BUTTON SIMPAN
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.gradien1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: isLoading ? null : _saveProfile,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
