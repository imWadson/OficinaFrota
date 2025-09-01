#!/bin/bash

echo "🚀 Iniciando build de release para OficinApp..."

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean

# Obter dependências
echo "📦 Obtendo dependências..."
flutter pub get

# Verificar se há problemas
echo "🔍 Verificando código..."
flutter analyze

# Build para Android
echo "📱 Gerando APK de release..."
flutter build apk --release

# Verificar se o build foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "✅ APK gerado com sucesso!"
    echo "📁 Localização: build/app/outputs/flutter-apk/app-release.apk"
    echo "📏 Tamanho do APK:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
else
    echo "❌ Erro ao gerar APK"
    exit 1
fi

echo "🎉 Build concluído!" 