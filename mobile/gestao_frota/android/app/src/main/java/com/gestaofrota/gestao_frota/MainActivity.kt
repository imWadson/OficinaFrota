package com.oficinapp.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.os.Bundle
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.util.Log

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Configurações de rede para resolver problemas de hostname
        try {
            // Verificar conectividade
            val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val network = connectivityManager.activeNetwork
            val capabilities = connectivityManager.getNetworkCapabilities(network)
            
            if (capabilities != null) {
                Log.d("MainActivity", "Rede ativa: ${capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)}")
                Log.d("MainActivity", "Dados móveis: ${capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)}")
            } else {
                Log.w("MainActivity", "Nenhuma rede ativa encontrada")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Erro ao verificar conectividade: ${e.message}")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Configurações adicionais para o Flutter Engine
        try {
            // Configurar timeout de rede
            System.setProperty("http.keepAlive", "false")
            System.setProperty("http.maxConnections", "5")
            
            Log.d("MainActivity", "Flutter Engine configurado com sucesso")
        } catch (e: Exception) {
            Log.e("MainActivity", "Erro ao configurar Flutter Engine: ${e.message}")
        }
    }
} 