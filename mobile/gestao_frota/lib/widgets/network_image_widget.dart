import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import '../services/storage_service.dart';

class NetworkImageWidget extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<NetworkImageWidget> createState() => _NetworkImageWidgetState();
}

class _NetworkImageWidgetState extends State<NetworkImageWidget> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(NetworkImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageBytes = null;
    });

    try {
      // Verificar se é um caminho local
      if (StorageService.isLocalPath(widget.imagePath)) {
        // Verificar se o arquivo existe
        final file = File(widget.imagePath);
        if (await file.exists()) {
          // Carregar arquivo local
          _imageBytes = await file.readAsBytes();
        } else {
          _hasError = true;
        }
      } else if (StorageService.isSupabaseUrl(widget.imagePath)) {
        // Fazer download da URL do Supabase
        final bytes = await StorageService.downloadPhoto(widget.imagePath);
        if (bytes != null) {
          _imageBytes = bytes;
        } else {
          _hasError = true;
        }
      } else {
        // Tentar carregar como URL de rede
        // Aqui você pode implementar carregamento de outras URLs se necessário
        _hasError = true;
      }
    } catch (e) {
      print('NetworkImageWidget: Erro ao carregar imagem: $e');
      _hasError = true;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_isLoading) {
      imageWidget = widget.placeholder ?? 
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
    } else if (_hasError || _imageBytes == null) {
      imageWidget = widget.errorWidget ?? 
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.error,
                color: Colors.grey,
                size: 48,
              ),
            ),
          );
    } else {
      imageWidget = Image.memory(
        _imageBytes!,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? 
              Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
              );
        },
      );
    }

    // Aplicar bordas arredondadas se especificado
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    // Aplicar dimensões se especificadas
    if (widget.width != null || widget.height != null) {
      imageWidget = SizedBox(
        width: widget.width,
        height: widget.height,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
} 