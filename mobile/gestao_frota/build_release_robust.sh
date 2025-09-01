#!/bin/bash

echo "🚀 Iniciando build de release robusto para OficinApp..."

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean

# Limpar cache do Gradle
echo "🧹 Limpando cache do Gradle..."
cd android
./gradlew clean
cd ..

# Limpar cache do Kotlin
echo "🧹 Limpando cache do Kotlin..."
rm -rf ~/.kotlin/daemon
rm -rf build/
rm -rf .dart_tool/

# Obter dependências
echo "📦 Obtendo dependências..."
flutter pub get

# Verificar se há problemas
echo "🔍 Verificando código..."
flutter analyze

# Build para Android com configurações otimizadas
echo "📱 Gerando APK de release..."
flutter build apk --release --no-tree-shake-icons

# Verificar se o build foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "✅ APK gerado com sucesso!"
    echo "📁 Localização: build/app/outputs/flutter-apk/app-release.apk"
    echo "📏 Tamanho do APK:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    
    # Verificar se o APK é válido
    echo "🔍 Verificando APK..."
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo "✅ APK válido encontrado!"
        
        # Mostrar informações do APK
        echo "📋 Informações do APK:"
        aapt dump badging build/app/outputs/flutter-apk/app-release.apk | head -5
    else
        echo "❌ APK não encontrado!"
        exit 1
    fi
else
    echo "❌ Erro ao gerar APK"
    exit 1
fi

echo "🎉 Build robusto concluído!" 