package com.example.agilu

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "agilu/actualizacion")
            .setMethodCallHandler { llamada, resultado ->
                when (llamada.method) {
                    "version" -> resultado.success(version())
                    "carpeta" -> resultado.success(carpeta().absolutePath)
                    "puedeInstalar" -> resultado.success(puedeInstalar())
                    "permitirInstalar" -> {
                        permitirInstalar()
                        resultado.success(null)
                    }
                    "instalar" -> {
                        val ruta = llamada.argument<String>("ruta")
                        if (ruta == null) {
                            resultado.error("sin_ruta", "Falta el archivo.", null)
                        } else {
                            instalar(File(ruta))
                            resultado.success(null)
                        }
                    }
                    else -> resultado.notImplemented()
                }
            }
    }

    private fun version(): Map<String, Any?> {
        val info = packageManager.getPackageInfo(packageName, 0)
        val codigo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }
        return mapOf("nombre" to info.versionName, "codigo" to codigo)
    }

    private fun carpeta(): File = File(cacheDir, "actualizaciones").apply { mkdirs() }

    private fun puedeInstalar(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.O || packageManager.canRequestPackageInstalls()

    private fun permitirInstalar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startActivity(
                Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName"))
            )
        }
    }

    // Solo instala archivos de la carpeta de actualizaciones de la app.
    private fun instalar(apk: File) {
        val base = carpeta().canonicalPath + File.separator
        require(apk.canonicalPath.startsWith(base)) { "Archivo fuera de la carpeta de actualizaciones" }
        val uri = FileProvider.getUriForFile(this, "$packageName.actualizaciones", apk)
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }
}
