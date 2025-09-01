class AppConstants {
  // Tipos de Veículos
  static const List<String> vehicleTypes = [
    'Caminhão Munck',
    'Carro de Apoio',
    'Caminhão Pipa',
    'Van',
    'Moto',
    'Outro',
  ];

  // Defeitos Comuns
  static const List<String> commonDefects = [
    'Problema no Freio',
    'Luz de Injeção Acesa',
    'Pneu Furado',
    'Problema na Direção',
    'Vazamento de Óleo',
    'Problema na Transmissão',
    'Problema Elétrico',
    'Problema no Motor',
    'Problema na Suspensão',
    'Problema no Sistema de Ar',
    'Problema na Bateria',
    'Problema no Sistema de Combustível',
    'Problema no Sistema de Refrigeração',
    'Problema no Sistema de Escape',
    'Problema no Sistema de Ignição',
    'Outro',
  ];

  // Status das Ordens de Serviço
  static const Map<String, String> statusLabels = {
    'aguardando_aceite': 'Aguardando Aceite',
    'recebido': 'Recebido na Oficina',
    'rejeitado': 'Rejeitado',
    'analisando': 'Analisando Defeitos',
    'conserto_iniciado': 'Conserto Iniciado',
    'finalizado_conserto': 'Conserto Finalizado',
    'pronto_retirada': 'Pronto para Retirada',
    'concluido': 'Concluído',
  };

  // Cores dos Status
  static const Map<String, int> statusColors = {
    'aguardando_aceite': 0xFFFFA500, // Laranja
    'recebido': 0xFF2196F3, // Azul
    'rejeitado': 0xFFF44336, // Vermelho
    'analisando': 0xFF9C27B0, // Roxo
    'conserto_iniciado': 0xFFFF9800, // Laranja
    'finalizado_conserto': 0xFF4CAF50, // Verde
    'pronto_retirada': 0xFF4CAF50, // Verde
    'concluido': 0xFF607D8B, // Cinza
  };

  // Configurações da Aplicação
  static const String appName = 'OficinApp';
  static const String appVersion = '1.0.0';

  // Mensagens
  static const String photoRequiredMessage = 'Foto é obrigatória';
  static const String vehicleRequiredMessage = 'Veículo é obrigatório';
  static const String defectsRequiredMessage =
      'Pelo menos um defeito deve ser selecionado';

  // Validações
  static const int maxPhotoSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
}
