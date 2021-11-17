package com.utopiaultimate.flutter.utopia_platform_utils.flutter.coroutine

import com.utopiaultimate.flutter.utopia_platform_utils.flutter.runForResult
import io.flutter.Log
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext

@Suppress("EXPERIMENTAL_API_USAGE_FUTURE_ERROR")
@OptIn(ExperimentalCoroutinesApi::class)
public fun <T> CoroutineScope.launchForResult(
        result: MethodChannel.Result,
        start: CoroutineStart = CoroutineStart.DEFAULT,
        context: CoroutineContext = EmptyCoroutineContext,
        block: suspend CoroutineScope.() -> T
) {
    val newContext = this.newCoroutineContext(context)
    val coroutine = MethodChannelResultCoroutine(newContext, result)
    coroutine.start(start, coroutine, block)
}

@OptIn(InternalCoroutinesApi::class)
private class MethodChannelResultCoroutine(context: CoroutineContext, private val result: MethodChannel.Result) :
        AbstractCoroutine<Any?>(context, initParentJob = true, active = true) {

    override fun onCompleted(value: Any?) = runForResult(result) { value }

    override fun onCancelled(cause: Throwable, handled: Boolean) {
        Log.e("unknown", "Error in launchForResult", cause)
        result.error("1000", cause.message, null)
    }
}