package com.utopiaultimate.flutter.utopia_save_file

import android.app.Activity
import android.content.Intent
import android.net.Uri
import com.utopiaultimate.flutter.utopia_save_file.dto.SaveFileFromUrlDto
import com.utopiaultimate.flutter.utopia_save_file.util.RestartableCoroutineScope
import com.utopiaultimate.flutter.utopia_save_file.util.launchForResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.channels.BroadcastChannel
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.withContext
import java.io.BufferedInputStream
import java.net.HttpURLConnection
import java.net.URL

class UtopiaSaveFilePluginImpl : RestartableCoroutineScope(Dispatchers.Main), FlutterPlugin, MethodCallHandler,
  ActivityAware {
  private lateinit var channel: MethodChannel
  private var activityBinding: ActivityPluginBinding? = null
  private var activityResultEvents = BroadcastChannel<Uri?>(capacity = 1)

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    initialize()
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "utopia_save_file")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    cancel()
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
    binding.addActivityResultListener(this::onActivityResult)
  }

  override fun onDetachedFromActivity() {
    activityBinding?.removeActivityResultListener(this::onActivityResult)
    activityBinding = null
  }

  override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "saveFileFromUrl") {
      launchForResult(result) {
        val dto = SaveFileFromUrlDto(call.arguments())
        val mime = withContext(Dispatchers.IO) { obtainMime(dto.url) }
        val uri = createFile(dto.name, mime)
        if(uri != null) withContext(Dispatchers.IO) { download(source = dto.url, destination = uri.toString()) }
        uri != null
      }
    } else {
      result.notImplemented()
    }
  }

  private fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent) = when (requestCode) {
    RequestCode -> {
      when (resultCode) {
        Activity.RESULT_OK -> activityResultEvents.offer(data.data)
        else -> activityResultEvents.offer(null)
      }
      true
    }
    else -> false
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
    activityBinding!!.activity.startActivityForResult(intent, RequestCode)
    return activityResultEvents.asFlow().first()
  }

  @Suppress("BlockingMethodInNonBlockingContext")
  private fun download(source: String, destination: String) {
    val sourceUrl = URL(source)
    val destinationUri = Uri.parse(destination)
    activityBinding?.activity?.contentResolver?.openOutputStream(destinationUri)!!.use { outputStream ->
      BufferedInputStream(sourceUrl.openStream()).use { inputStream ->
        inputStream.copyTo(outputStream)
      }
    }
  }

  companion object {
    private const val RequestCode = 4934
  }
}
