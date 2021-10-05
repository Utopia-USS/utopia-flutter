package com.utopiaultimate.flutter.utopia_save_file.util

import io.flutter.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import kotlinx.coroutines.*
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext

fun <T> CoroutineScope.launchForResult(
        result: MethodChannel.Result,
        start: CoroutineStart = CoroutineStart.DEFAULT,
        context: CoroutineContext = EmptyCoroutineContext,
        block: suspend CoroutineScope.() -> T
) {
    val newContext = this.newCoroutineContext(context)
    val coroutine = MethodChannelResultCoroutine(newContext, result)
    coroutine.start(start, coroutine, block)
}

@UseExperimental(InternalCoroutinesApi::class)
private class MethodChannelResultCoroutine(context: CoroutineContext, private val result: MethodChannel.Result) :
        AbstractCoroutine<Any?>(context, active = true) {

    override fun onCompleted(value: Any?) {
        result.success(value.takeUnless { it == Unit })
    }

    override fun onCancelled(cause: Throwable, handled: Boolean) {
        Log.e("unknown", "Error in methodChannelResult", cause)
        result.error("1000", cause.message, null)
    }
}