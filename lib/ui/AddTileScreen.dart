// lib/ui/tiles/AddTileScreen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/cubit/tile_state.dart';
import 'package:royaltrader/models/tile_model.dart';
import 'package:royaltrader/widgets/dumb_widgets/app_text_field2_widget.dart';
import 'package:royaltrader/widgets/dumb_widgets/app_text_field_widget.dart';

class AddTileScreen extends StatefulWidget {
  const AddTileScreen({Key? key}) : super(key: key);

  @override
  State<AddTileScreen> createState() => _AddTileScreenState();
}

class _AddTileScreenState extends State<AddTileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _sizeController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _toneController = TextEditingController();
  final _stockController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _imagePath;

  @override
  void dispose() {
    _codeController.dispose();
    _sizeController.dispose();
    _companyNameController.dispose();
    _toneController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
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

  void _saveTile() {
    if (_formKey.currentState!.validate()) {
      final newTile = Tile(
        id: '', // ID will be generated in repository
        code: _codeController.text,
        size: _sizeController.text,
        companyName: _companyNameController.text,
        tone: _toneController.text,
        stock: int.parse(_stockController.text),
        date: _selectedDate,
        imagePath: _imagePath,
      );

      context.read<TileCubit>().addTile(newTile).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tile added successfully')),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Tile')),
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
                      child:
                          _imagePath != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_photo_alternate, size: 50),
                                  SizedBox(height: 10),
                                  Text('Add Image'),
                                ],
                              ),
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
                AppTextField2(
                  labelText: 'Company Name',
                  helpText: 'Enter company name',
                  isFloatLabel: false,
                  controller: _companyNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company name';
                    }
                    return null;
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
                  child: ElevatedButton(
                    onPressed: _saveTile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: BlocBuilder<TileCubit, TileState>(
                      builder: (context, state) {
                        return state.status == TileStatus.loading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('Save Tile');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
