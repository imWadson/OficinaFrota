import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/service_order_provider.dart';
import '../models/service_order.dart';
import '../models/vehicle.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_bar_with_back.dart';
import '../constants/app_constants.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  String? _selectedVehicleType;
  final _licensePlateController = TextEditingController();
  final _modelController = TextEditingController();
  final _otherDefectsController = TextEditingController();

  Set<String> _selectedDefects = {};
  File? _photoFile;
  bool _isLoading = false;
  bool _isCustomVehicle = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _modelController.dispose();
    _otherDefectsController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await DataService.getVehicles();
      setState(() {
        _vehicles = vehicles;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar veículos: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _photoFile = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao capturar foto: $e')));
      }
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _photoFile = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao selecionar foto: $e')));
      }
    }
  }

  void _toggleDefect(String defect) {
    setState(() {
      if (_selectedDefects.contains(defect)) {
        _selectedDefects.remove(defect);
      } else {
        _selectedDefects.add(defect);
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.photoRequiredMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDefects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.defectsRequiredMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final orderProvider = context.read<ServiceOrderProvider>();

      // Criar ou obter veículo
      Vehicle vehicle;
      if (_isCustomVehicle) {
        // Criar novo veículo
        vehicle = Vehicle(
          id: '', // Será gerado pelo banco
          licensePlate: _licensePlateController.text.trim().toUpperCase(),
          type: _selectedVehicleType ?? 'Outro',
          model: _modelController.text.trim().isNotEmpty
              ? _modelController.text.trim()
              : null,
          createdAt: DateTime.now(),
        );
        // Criar o veículo e obter o ID gerado pelo banco
        vehicle = await DataService.createVehicle(vehicle);
      } else {
        vehicle = _selectedVehicle!;
      }

      // Preparar lista de defeitos
      List<String> defects = _selectedDefects.toList();
      if (_selectedDefects.contains('Outro') &&
          _otherDefectsController.text.trim().isNotEmpty) {
        defects.remove('Outro');
        defects.add(_otherDefectsController.text.trim());
      }

      // Fazer upload da foto para o Supabase Storage
      String photoUrl = _photoFile!.path; // Fallback para caminho local
      
      try {
        print('CreateOrderScreen: Fazendo upload da foto...');
        final uploadedUrl = await StorageService.uploadPhoto(
          _photoFile!,
          'dropoff',
          DateTime.now().millisecondsSinceEpoch.toString(),
        );
        
        if (uploadedUrl != null) {
          photoUrl = uploadedUrl;
          print('CreateOrderScreen: Upload bem-sucedido. URL: $photoUrl');
        } else {
          print('CreateOrderScreen: Upload falhou, usando caminho local');
        }
      } catch (e) {
        print('CreateOrderScreen: Erro no upload: $e');
      }

      // Criar ordem de serviço
      final order = ServiceOrder(
        id: 0, // Será gerado pelo banco
        vehicleId: vehicle.id,
        status: ServiceOrderStatus.aguardandoAceite,
        creatorUserId: authProvider.currentUser!.id,
        dropoffTimestamp: DateTime.now(),
        dropoffPhotoUrl: photoUrl,
        createdAt: DateTime.now(),
        vehicle: vehicle,
        creator: authProvider.userProfile,
        defects: defects,
      );

      print('CreateOrderScreen: Status da ordem criada: ${order.status}');
      print('CreateOrderScreen: JSON da ordem: ${order.toJson()}');

      final success = await orderProvider.createServiceOrder(order, defects);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ordem de serviço criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderProvider.error ?? 'Erro ao criar ordem de serviço',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erro ao criar ordem de serviço';
        if (e.toString().contains('duplicate key value')) {
          errorMessage = 'Veículo já existe no sistema';
        } else if (e.toString().contains(
          'invalid input syntax for type uuid',
        )) {
          errorMessage = 'Erro interno: ID do veículo inválido';
        } else {
          errorMessage = 'Erro: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithBack(title: 'Nova Ordem de Serviço'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seleção de veículo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Veículo',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Toggle entre veículo existente e novo
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => _isCustomVehicle = false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !_isCustomVehicle
                                    ? Colors.blue
                                    : Colors.grey[300],
                                foregroundColor: !_isCustomVehicle
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                              child: const Text('Veículo Existente'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => _isCustomVehicle = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isCustomVehicle
                                    ? Colors.blue
                                    : Colors.grey[300],
                                foregroundColor: _isCustomVehicle
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                              child: const Text('Novo Veículo'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (!_isCustomVehicle) ...[
                        // Dropdown para veículos existentes
                        DropdownButtonFormField<Vehicle>(
                          value: _selectedVehicle,
                          decoration: const InputDecoration(
                            labelText: 'Selecionar Veículo',
                            border: OutlineInputBorder(),
                          ),
                          items: _vehicles.map((vehicle) {
                            return DropdownMenuItem(
                              value: vehicle,
                              child: Text(vehicle.toString()),
                            );
                          }).toList(),
                          onChanged: (vehicle) {
                            setState(() {
                              _selectedVehicle = vehicle;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Selecione um veículo';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        // Campos para novo veículo
                        TextFormField(
                          controller: _licensePlateController,
                          decoration: const InputDecoration(
                            labelText: 'Placa',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Placa é obrigatória';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedVehicleType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo do Veículo',
                            border: OutlineInputBorder(),
                          ),
                          items: AppConstants.vehicleTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (type) {
                            setState(() {
                              _selectedVehicleType = type;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Selecione o tipo do veículo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Modelo (opcional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Checklist de defeitos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Defeitos',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.commonDefects.map((defect) {
                          final isSelected = _selectedDefects.contains(defect);
                          return FilterChip(
                            label: Text(defect),
                            selected: isSelected,
                            onSelected: (_) => _toggleDefect(defect),
                            selectedColor: Colors.blue[100],
                            checkmarkColor: Colors.blue,
                          );
                        }).toList(),
                      ),
                      if (_selectedDefects.contains('Outro')) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _otherDefectsController,
                          decoration: const InputDecoration(
                            labelText: 'Descreva o defeito',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Captura de foto
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foto do Veículo',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      if (_photoFile != null) ...[
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_photoFile!, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Tirar Foto'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickPhoto,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galeria'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão de envio
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Criar Ordem de Serviço'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
