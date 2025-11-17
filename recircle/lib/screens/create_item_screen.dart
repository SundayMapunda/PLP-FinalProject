import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class CreateItemScreen extends HookWidget {
  const CreateItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final locationController = useTextEditingController();
    final selectedCategory = useState('TOOLS');
    final selectedType = useState('BORROW');
    final selectedImage = useState<File?>(null);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    // Categories for dropdown
    final categories = {
      'TOOLS': 'Tools & Garden',
      'BOOKS': 'Books & Media',
      'KIDS': 'Kids & Baby',
      'HOME': 'Home & Kitchen',
      'ELECTRONICS': 'Electronics',
      'SPORTS': 'Sports & Outdoors',
      'OTHER': 'Other',
    };

    // Pick image from gallery
    Future<void> pickImage() async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (image != null) {
          selectedImage.value = File(image.path);
        }
      } catch (e) {
        errorMessage.value = 'Failed to pick image: $e';
      }
    }

    // Take photo with camera
    Future<void> takePhoto() async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );

        if (image != null) {
          selectedImage.value = File(image.path);
        }
      } catch (e) {
        errorMessage.value = 'Failed to take photo: $e';
      }
    }

    // Submit the new item
    Future<void> submitItem() async {
      if (titleController.text.isEmpty) {
        errorMessage.value = 'Please enter a title';
        return;
      }

      if (descriptionController.text.isEmpty) {
        errorMessage.value = 'Please enter a description';
        return;
      }

      if (locationController.text.isEmpty) {
        errorMessage.value = 'Please enter a location';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      try {
        // Prepare item data
        final itemData = {
          'title': titleController.text,
          'description': descriptionController.text,
          'category': selectedCategory.value,
          'item_type': selectedType.value,
          'location': locationController.text,
        };

        // Convert image to bytes if selected
        List<int>? imageBytes;
        if (selectedImage.value != null) {
          imageBytes = await selectedImage.value!.readAsBytes();
        }

        // Submit to API
        await ApiService().createItem(itemData, imageBytes);

        // Success - return to home screen
        // if (mounted) {
        Navigator.pop(context, true); // Pass true to indicate success
        // }
      } catch (e) {
        errorMessage.value = 'Failed to create item: $e';
        print('Create item error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Item'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isLoading.value ? null : submitItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker Section
            const Text(
              'Item Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: selectedImage.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          selectedImage.value!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: pickImage,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: takePhoto,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Item Details Form
            const Text(
              'Item Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Item Title*',
                border: OutlineInputBorder(),
                hintText: 'e.g., Electric Drill, Harry Potter Books',
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description*',
                border: OutlineInputBorder(),
                hintText: 'Describe the item condition, usage, etc.',
              ),
            ),
            const SizedBox(height: 16),

            // Category and Type
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCategory.value,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory.value = value;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedType.value,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'BORROW',
                        child: Text('For Borrowing'),
                      ),
                      DropdownMenuItem(
                        value: 'GIVE',
                        child: Text('For Giving'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        selectedType.value = value;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location*',
                border: OutlineInputBorder(),
                hintText: 'e.g., Downtown, North District',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (errorMessage.value != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage.value!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Submit Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : submitItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Share Item', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
