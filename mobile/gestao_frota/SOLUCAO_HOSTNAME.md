# 🔧 Solução para Erro de Hostname no APK de Release

## 📋 Problema
O aplicativo funciona normalmente em debug, mas apresenta erro de hostname quando gerado como APK de release.

## 🎯 Causas Comuns
1. **Configurações de rede** não aplicadas em release
2. **ProGuard** ofuscando classes do Supabase
3. **Permissões de internet** não configuradas
4. **Configurações de segurança de rede** ausentes
5. **Certificados SSL** não reconhecidos em release

## ✅ Soluções Implementadas

### 1. Permissões de Internet (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 2. Configuração de Segurança de Rede
- Arquivo: `android/app/src/main/res/xml/network_security_config.xml`
- Permite conexões com domínios do Supabase
- Configura certificados SSL corretamente

### 3. Configurações do ProGuard
- Arquivo: `android/app/proguard-rules.pro`
- Preserva classes do Supabase da ofuscação
- Mantém funcionalidades de rede

### 4. Configurações do Build (build.gradle.kts)
- Habilita MultiDex
- Configura ProGuard para release
- Adiciona dependências de rede

### 5. MainActivity Atualizada
- Verifica conectividade na inicialização
- Configura timeouts de rede
- Logs para debug

## 🚀 Como Gerar o APK Corrigido

### Opção 1: Usando o Script (Recomendado)
```bash
# No terminal, na pasta do projeto
chmod +x build_release.sh
./build_release.sh
```

### Opção 2: Comando Manual
```bash
# Limpar builds anteriores
flutter clean

# Obter dependências
flutter pub get

# Gerar APK de release
flutter build apk --release
```

### Opção 3: Build com Debug Temporário
Se ainda houver problemas, tente:
```bash
flutter build apk --release --debug
```

## 🔍 Verificações Adicionais

### 1. Verificar Configurações do Supabase
- Confirme se a URL está correta
- Verifique se a chave anônima está válida
- Teste a conexão no console do Supabase

### 2. Testar em Diferentes Redes
- WiFi
- Dados móveis
- Redes corporativas (se aplicável)

### 3. Verificar Logs
```bash
# Instalar APK e ver logs
adb install build/app/outputs/flutter-apk/app-release.apk
adb logcat | grep -E "(MainActivity|SupabaseService|Flutter)"
```

## 🛠️ Soluções Alternativas

### Se o Problema Persistir:

1. **Desabilitar ProGuard Temporariamente**
```kotlin
// Em build.gradle.kts, comentar:
// isMinifyEnabled = true
// isShrinkResources = true
```

2. **Usar Configuração de Debug para Release**
```kotlin
// Em build.gradle.kts, adicionar:
debuggable = true
```

3. **Verificar Configurações de Rede do Dispositivo**
- Desativar VPN
- Verificar proxy
- Testar em modo avião

## 📱 Testando o APK

### 1. Instalação
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 2. Verificação de Permissões
```bash
adb shell pm list permissions -d -g | grep internet
```

### 3. Logs em Tempo Real
```bash
adb logcat -s MainActivity:S SupabaseService:S Flutter:S
```

## 🔧 Configurações Avançadas

### Para Produção:
1. Configurar assinatura digital
2. Otimizar tamanho do APK
3. Implementar crashlytics
4. Configurar CI/CD

### Para Debug:
1. Habilitar logs detalhados
2. Usar Charles Proxy para interceptar requisições
3. Testar com diferentes versões do Android

## 📞 Suporte

Se o problema persistir:
1. Verifique os logs completos
2. Teste em dispositivo físico diferente
3. Verifique versão do Flutter e dependências
4. Consulte a documentação do Supabase

## ✅ Checklist Final

- [ ] Permissões de internet adicionadas
- [ ] Configuração de segurança de rede criada
- [ ] ProGuard configurado
- [ ] Build.gradle atualizado
- [ ] MainActivity modificada
- [ ] APK gerado com sucesso
- [ ] Testado em dispositivo físico
- [ ] Funcionando em diferentes redes 