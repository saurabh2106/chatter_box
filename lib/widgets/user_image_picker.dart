import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});

  final void Function(File pickedImage) onPickedImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedImageFile;

  void pickImage() async {
    final pickImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickImage != null) {
      setState(() {
        pickedImageFile = File(pickImage.path);
      });
      widget.onPickedImage(pickedImageFile!);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 40,
          foregroundImage:
              pickedImageFile != null ? FileImage(pickedImageFile!) : null,
        ),
        TextButton.icon(
          icon: const Icon(Icons.image),
          onPressed: pickImage,
          label: Text(
            'Add Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        )
      ],
    );
  }
}
