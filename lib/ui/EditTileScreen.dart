// lib/ui/tiles/EditTileScreen.dart
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/cubit/tile_state.dart';
import 'package:royaltrader/models/tile_model.dart';
import 'package:royaltrader/widgets/dumb_widgets/app_text_field2_widget.dart';
import 'package:royaltrader/widgets/dumb_widgets/app_text_field_widget.dart';
import 'package:royaltrader/widgets/dumb_widgets/company_dropdown.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uuid/uuid.dart';

class EditTileScreen extends StatefulWidget {
  final Tile tile;

  const EditTileScreen({Key? key, required this.tile}) : super(key: key);

  @override
  State<EditTileScreen> createState() => _EditTileScreenState();
}

class _EditTileScreenState extends State<EditTileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _sizeController;
  late final TextEditingController _toneController;
  late final TextEditingController _stockController;
  String? _selectedCompany;

  late DateTime _selectedDate;
  String? _imageUrl;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.tile.code);
    _sizeController = TextEditingController(text: widget.tile.size);
    _selectedCompany = widget.tile.companyName;
    _toneController = TextEditingController(text: widget.tile.tone);
    _stockController = TextEditingController(
      text: widget.tile.stock.toString(),
    );
    _selectedDate = widget.tile.date;
    _imageUrl = widget.tile.imageUrl;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _sizeController.dispose();
    _toneController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newImageFile = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      print("Uploading image...");
      String fileName = Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref().child(
        'tiles_images/$fileName.jpg',
      );

      final uploadTask = await storageRef.putFile(imageFile);

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print(downloadUrl);

      print("Upload successful! URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateTile() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl = _imageUrl;

      if (_newImageFile != null) {
        imageUrl = await _uploadImageToFirebase(_newImageFile!);
        print(imageUrl);
      }

      final updatedTile = widget.tile.copyWith(
        code: _codeController.text,
        size: _sizeController.text,
        companyName: _selectedCompany ?? widget.tile.companyName,
        tone: _toneController.text,
        stock: int.parse(_stockController.text),
        date: _selectedDate,
        imageUrl: imageUrl,
      );

      context.read<TileCubit>().updateTile(updatedTile).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tile updated successfully')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Tile')),
      body: BlocListener<TileCubit, TileState>(
        listener: (context, state) {
          if (state.status == TileStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _displayImage(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField2(
                  labelText: 'Code',
                  helpText: 'Enter tile code',
                  isFloatLabel: false,
                  controller: _codeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tile code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownField(
                  value: _selectedCompany,
                  onChanged: (value) {
                    setState(() {
                      _selectedCompany = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                AppTextField2(
                  labelText: 'Size',
                  helpText: 'Enter tile size',
                  isFloatLabel: false,
                  controller: _sizeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tile size';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField2(
                  labelText: 'Tone',
                  helpText: 'Enter tile tone',
                  isFloatLabel: false,
                  controller: _toneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tile tone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField2(
                  labelText: 'Stock',
                  helpText: 'Enter stock quantity',
                  isFloatLabel: false,
                  keyboardType: TextInputType.number,
                  controller: _stockController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stock quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<TileCubit, TileState>(
                    builder: (context, state) {
                      final isLoading = state.status == TileStatus.loading;
                      return Skeletonizer(
                        enabled: isLoading,
                        // Optional configuration for skeletonizer effect
                        effect: ShimmerEffect(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _updateTile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(isLoading ? 'Saving...' : 'Save Tile'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _displayImage() {
    if (_newImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _newImageFile!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _displayErrorImage();
          },
        ),
      );
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _displayErrorImage();
          },
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_photo_alternate, size: 50),
          SizedBox(height: 10),
          Text('Add Image'),
        ],
      );
    }
  }

  Widget _displayErrorImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.broken_image, size: 50),
        SizedBox(height: 10),
        Text('Image not found'),
      ],
    );
  }
}
