package com.utopiaultimate.flutter.utopia_save_file

import android.content.Intent
import android.net.Uri
import com.utopiaultimate.flutter.utopia_platform_utils.flutter.coroutine.launchForResult
import com.utopiaultimate.flutter.utopia_platform_utils.flutter.plugin.BaseFlutterPlugin
import com.utopiaultimate.flutter.utopia_save_file.dto.SaveFileFromBytesDto
import com.utopiaultimate.flutter.utopia_save_file.dto.SaveFileFromUrlDto
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.withContext
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.net.HttpURLConnection
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
      "saveFileFromUrl" -> activityScope.launchForResult(result) {
        val dto = SaveFileFromUrlDto(call.arguments()!!)
        val mime = withContext(Dispatchers.IO) { obtainMime(dto.url) }
        val uri = createFile(dto.name, mime)
        if (uri != null) withContext(Dispatchers.IO) { download(source = dto.url, destination = uri) }
        uri != null
      }
      "saveFileFromBytes" -> activityScope.launchForResult(result) {
        val dto = SaveFileFromBytesDto(call.arguments()!!)
        val uri = createFile(dto.name, dto.mime)
        if (uri != null) withContext(Dispatchers.IO) {
          save(source = ByteArrayInputStream(dto.bytes), destination = uri)
        }
        uri != null
      }
      else -> result.notImplemented()
    }
  }

  private fun obtainMime(url: String) = with(URL(url).openConnection() as HttpURLConnection) {
    try {
      requestMethod = "HEAD"
      connect()
      contentType
    } finally {
      disconnect()
    }
  }

  private suspend fun createFile(name: String, mimeType: String): Uri? {
    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply { type = mimeType; putExtra(Intent.EXTRA_TITLE, name) }
    activity.startActivityForResult(intent, RequestCode)
    return activityResultEvents.first().data?.data
  }

  private fun download(source: String, destination: Uri) {
    val sourceUrl = URL(source)
    sourceUrl.openStream().use { sourceStream -> save(sourceStream, destination) }
  }

  private fun save(source: InputStream, destination: Uri) {
    activity.contentResolver.openOutputStream(destination)!!
      .use { outputStream -> source.copyTo(outputStream) }
  }

  companion object {
    private const val RequestCode = 4934
  }
}
