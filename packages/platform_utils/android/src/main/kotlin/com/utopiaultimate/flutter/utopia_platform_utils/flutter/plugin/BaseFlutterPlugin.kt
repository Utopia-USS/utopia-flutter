package com.utopiaultimate.flutter.utopia_platform_utils.flutter.plugin

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.CallSuper
import com.utopiaultimate.flutter.utopia_platform_utils.coroutine.RestartableCoroutineScope
import com.utopiaultimate.flutter.utopia_platform_utils.flutter.ActivityResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.launch

public abstract class BaseFlutterPlugin private constructor(
    private val scope: RestartableCoroutineScope,
) : CoroutineScope by scope, FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener {
    private var bindingInternal: FlutterPluginBinding? = null
    protected val binding: FlutterPluginBinding get() = bindingInternal!!
    protected val context: Context get() = binding.applicationContext

    private var activityBindingInternal: ActivityPluginBinding? = null
    protected val activityBinding: ActivityPluginBinding get() = activityBindingInternal!!
    protected val activity: Activity get() = activityBinding.activity

    private val activityScopeInternal = RestartableCoroutineScope(Dispatchers.Main)
    protected val activityScope: CoroutineScope get() = activityScopeInternal

    private val activityResultEventsInternal = MutableSharedFlow<ActivityResult>()
    protected val activityResultEvents: Flow<ActivityResult> get() = activityResultEventsInternal
    protected open val activityRequestCodes: List<Int> = emptyList()

    public constructor() : this(RestartableCoroutineScope(Dispatchers.Main))

    @CallSuper
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        bindingInternal = binding
        scope.openScope()
    }

    @CallSuper
    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        scope.closeScope()
        bindingInternal = null
    }

    @CallSuper
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBindingInternal = binding
        binding.addActivityResultListener(this)
        activityScopeInternal.openScope()
    }

    @CallSuper
    override fun onDetachedFromActivity() {
        activityScopeInternal.closeScope()
        activityBinding.removeActivityResultListener(this)
        activityBindingInternal = null
    }

    final override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    final override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    final override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean =
        when (requestCode) {
            in activityRequestCodes -> {
                launch { activityResultEventsInternal.emit(ActivityResult(requestCode, resultCode, data)) }
                true
            }
            else -> false
        }
}