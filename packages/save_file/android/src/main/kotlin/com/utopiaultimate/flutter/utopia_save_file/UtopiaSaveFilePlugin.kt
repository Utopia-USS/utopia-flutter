package com.utopiaultimate.flutter.utopia_save_file

import android.content.Intent
import android.net.Uri
import com.utopiaultimate.flutter.utopia_platform_utils.flutter.coroutine.launchForResult
import com.utopiaultimate.flutter.utopia_platform_utils.flutter.plugin.BaseFlutterPlugin
import com.utopiaultimate.flutter.utopia_save_file.dto.SaveFileDto
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.withContext
import java.io.ByteArrayInputStream
import java.io.File
import java.io.InputStream
import java.net.URL

class UtopiaSaveFilePlugin : BaseFlutterPlugin(), MethodChannel.MethodCallHandler {
  private lateinit var channel: MethodChannel

  override val activityRequestCodes = listOf(RequestCode)

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    super.onAttachedToEngine(binding)
    channel = MethodChannel(binding.binaryMessenger, "utopia_save_file")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    super.onDetachedFromEngine(binding)
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "fromFile" -> activityScope.launchForResult(result) {
        val dto = SaveFileDto.FromFile(call.arguments()!!)
        saveFile(dto) { File(dto.path).inputStream() }
      }

      "fromUrl" -> activityScope.launchForResult(result) {
        val dto = SaveFileDto.FromUrl(call.arguments()!!)
        saveFile(dto) { URL(dto.url).openStream() }
      }

      "fromBytes" -> activityScope.launchForResult(result) {
        val dto = SaveFileDto.FromBytes(call.arguments()!!)
        saveFile(dto) { ByteArrayInputStream(dto.bytes) }
      }

      else -> result.notImplemented()
    }
  }

  private suspend fun saveFile(dto: SaveFileDto, block: () -> InputStream): Boolean {
    val uri = createFile(dto.name, dto.mime)
    if (uri != null) withContext(Dispatchers.IO) {
      activity.contentResolver.openOutputStream(uri)!!.use { dst -> block().use { it.copyTo(dst) } }
    }
    return uri != null
  }

  private suspend fun createFile(name: String, mimeType: String): Uri? {
    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply { type = mimeType; putExtra(Intent.EXTRA_TITLE, name) }
    activity.startActivityForResult(intent, RequestCode)
    return activityResultEvents.first().data?.data
  }

  companion object {
    private const val RequestCode = 4934
  }
}
