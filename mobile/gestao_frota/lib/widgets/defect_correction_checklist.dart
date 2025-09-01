import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/defect_correction.dart';
import '../services/data_service.dart';
import '../providers/auth_provider.dart';
import '../constants/app_theme.dart';

class DefectCorrectionChecklist extends StatefulWidget {
  final int orderId;
  final List<String> defects;
  final Function(bool allCorrected) onAllDefectsCorrected;

  const DefectCorrectionChecklist({
    super.key,
    required this.orderId,
    required this.defects,
    required this.onAllDefectsCorrected,
  });

  @override
  State<DefectCorrectionChecklist> createState() =>
      _DefectCorrectionChecklistState();
}

class _DefectCorrectionChecklistState extends State<DefectCorrectionChecklist> {
  List<DefectCorrection> _corrections = [];
  Map<int, bool> _checkedDefects = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCorrections();
  }

  Future<void> _loadCorrections() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final corrections = await DataService.getDefectCorrections(
        widget.orderId,
      );
      setState(() {
        _corrections = corrections;
        // Marcar defeitos corrigidos como checked
        for (final correction in corrections) {
          _checkedDefects[correction.defectId] = true;
        }
      });
      _checkAllDefectsCorrected();
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar correções: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDefect(int defectId, String defectDescription) async {
    final authProvider = context.read<AuthProvider>();
    final isCurrentlyChecked = _checkedDefects[defectId] ?? false;

    setState(() {
      _isLoading = true;
    });

    try {
      if (isCurrentlyChecked) {
        // Desmarcar como corrigido
        await DataService.unmarkDefectAsCorrected(widget.orderId, defectId);
        setState(() {
          _checkedDefects[defectId] = false;
        });
      } else {
        // Marcar como corrigido
        String? notes;

        // Mostrar dialog para adicionar notas (opcional)
        final shouldAddNotes = await _showNotesDialog();
        if (shouldAddNotes) {
          notes = await _showNotesInputDialog(defectDescription);
        }

        await DataService.markDefectAsCorrected(
          widget.orderId,
          defectId,
          authProvider.currentUser!.id,
          notes,
        );

        setState(() {
          _checkedDefects[defectId] = true;
        });
      }

      await _loadCorrections(); // Recarregar para atualizar dados
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar correção: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showNotesDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Adicionar Observações'),
            content: const Text(
              'Deseja adicionar observações sobre a correção deste defeito?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Não'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sim'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _showNotesInputDialog(String defectDescription) async {
    final notesController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Observações da Correção'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Defeito: $defectDescription'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(notesController.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _checkAllDefectsCorrected() {
    final allCorrected = widget.defects.every((defect) {
      final defectId = _getDefectId(defect);
      return defectId != null && (_checkedDefects[defectId] ?? false);
    });

    widget.onAllDefectsCorrected(allCorrected);
  }

  int? _getDefectId(String defectDescription) {
    // Buscar o ID do defeito baseado na descrição
    // Esta é uma implementação simplificada - em produção, você pode querer
    // armazenar os IDs dos defeitos de forma mais eficiente
    for (final correction in _corrections) {
      // Aqui você precisaria de uma forma de mapear descrição para ID
      // Por enquanto, vamos usar uma abordagem diferente
    }
    return null; // Implementação simplificada
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _corrections.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCorrections,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: AppTheme.borderRadiusMedium,
                  ),
                  child: Icon(
                    Icons.checklist,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Checklist de Correção',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Marque os defeitos que foram corrigidos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.defects.asMap().entries.map((entry) {
              final index = entry.key;
              final defect = entry.value;
              final isChecked = _checkedDefects[index] ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  title: Text(
                    defect,
                    style: TextStyle(
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  value: isChecked,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          _toggleDefect(index, defect);
                        },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  secondary: isChecked
                      ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                      : null,
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getProgressColor().withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusMedium,
                border: Border.all(color: _getProgressColor().withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getProgressIcon(),
                    color: _getProgressColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getProgressText(),
                      style: TextStyle(
                        color: _getProgressColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor() {
    final totalDefects = widget.defects.length;
    final correctedDefects = _checkedDefects.values
        .where((checked) => checked)
        .length;

    if (correctedDefects == 0) return Colors.orange;
    if (correctedDefects < totalDefects) return Colors.blue;
    return Colors.green;
  }

  IconData _getProgressIcon() {
    final totalDefects = widget.defects.length;
    final correctedDefects = _checkedDefects.values
        .where((checked) => checked)
        .length;

    if (correctedDefects == 0) return Icons.warning;
    if (correctedDefects < totalDefects) return Icons.pending;
    return Icons.check_circle;
  }

  String _getProgressText() {
    final totalDefects = widget.defects.length;
    final correctedDefects = _checkedDefects.values
        .where((checked) => checked)
        .length;

    if (correctedDefects == 0) {
      return 'Nenhum defeito corrigido ainda';
    } else if (correctedDefects < totalDefects) {
      return '$correctedDefects de $totalDefects defeitos corrigidos';
    } else {
      return 'Todos os defeitos foram corrigidos! ✅';
    }
  }
}
