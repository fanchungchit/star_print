package com.ellie_erp.star_print

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.starmicronics.stario10.InterfaceType
import com.starmicronics.stario10.StarConnectionSettings
import com.starmicronics.stario10.StarDeviceDiscoveryManager
import com.starmicronics.stario10.StarDeviceDiscoveryManagerFactory
import com.starmicronics.stario10.StarPrinter
import com.starmicronics.stario10.starxpandcommand.DocumentBuilder
import com.starmicronics.stario10.starxpandcommand.PrinterBuilder
import com.starmicronics.stario10.starxpandcommand.StarXpandCommandBuilder
import com.starmicronics.stario10.starxpandcommand.printer.CutType
import com.starmicronics.stario10.starxpandcommand.printer.ImageParameter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/** StarPrintPlugin */
class StarPrintPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : Context

  private var _manager: StarDeviceDiscoveryManager? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "star_print")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "discover" -> {
        try {
          this._manager?.stopDiscovery()

          val interfaceTypes = mutableListOf(
            InterfaceType.Lan,
            InterfaceType.Bluetooth,
            InterfaceType.Usb,
          )

          this._manager = StarDeviceDiscoveryManagerFactory.create(
            interfaceTypes,
            context,
          )
          _manager?.discoveryTime = 10000
          val printers = mutableListOf<StarPrinter>()
          _manager?.callback = object : StarDeviceDiscoveryManager.Callback {
            override fun onPrinterFound(printer: StarPrinter) {
              printers.add(printer)
            }

            override fun onDiscoveryFinished() {
                result.success(printers.map {
                  mapOf(
                    "address" to it.connectionSettings.identifier,
                    "model" to it.information?.model?.name,
                    "emulation" to it.information?.emulation?.name,
                    "interfaceType" to it.connectionSettings.interfaceType.name,
                  )
                 })
            }
          }

          _manager?.startDiscovery()
        } catch (e: Exception) {
          result.error("Discover", "Error: $e", null)
        }
      }
      "printImage" -> {
        val interfaceType = when (call.argument<String>("interfaceType")) {
          "lan" -> InterfaceType.Lan
          "bluetooth" -> InterfaceType.Bluetooth
          "usb" -> InterfaceType.Usb
          else -> return result.error("Print", "Error: interfaceType is invalid", null)
        }
        val address = call.argument<String>("address")!!
        val bytes = call.argument<ByteArray>("bytes")!!
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        val width = call.argument<Int>("width") ?: 576
        val copies = call.argument<Int>("copies") ?: 1

        printBitmap(interfaceType, address, bitmap, copies, width)

        result.success(null)
      }
      "printPath" -> {
        val interfaceType = when (call.argument<String>("interfaceType")) {
          "lan" -> InterfaceType.Lan
          "bluetooth" -> InterfaceType.Bluetooth
          "usb" -> InterfaceType.Usb
          else -> return result.error("Print", "Error: interfaceType is invalid", null)
        }
        val address = call.argument<String>("address")!!
        val path = call.argument<String>("path")!!
        val bitmap = BitmapFactory.decodeFile(path)
        val width = call.argument<Int>("width") ?: 576
        val copies = call.argument<Int>("copies") ?: 1

        printBitmap(interfaceType, address, bitmap, copies, width)

        result.success(null)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun printBitmap(
    interfaceType: InterfaceType,
    address: String,
    bitmap: Bitmap,
    copies: Int,
    width: Int,
  ) {
    val settings = StarConnectionSettings(interfaceType, address)
    val printer = StarPrinter(settings, context)

    val job = SupervisorJob()
    val scope = CoroutineScope(Dispatchers.Default + job)

    scope.launch {
      try {
        val builder = StarXpandCommandBuilder()
        for (i in 0 until copies) {
          builder.addDocument(
            DocumentBuilder()
              .addPrinter(
                PrinterBuilder()
                  .actionPrintImage(ImageParameter(bitmap, width))
                  .actionCut(CutType.Partial)
              )
          )
        }
        val commands = builder.getCommands()

        printer.openAsync().await()
        printer.printAsync(commands).await()
      } catch (e: Exception) {
        Log.e("Print", "Error: $e")
      } finally {
        printer.closeAsync().await()
      }
    }
  }
}
