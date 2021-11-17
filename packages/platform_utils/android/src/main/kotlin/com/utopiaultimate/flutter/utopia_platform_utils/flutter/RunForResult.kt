package com.utopiaultimate.flutter.utopia_platform_utils.flutter

import io.flutter.Log
import io.flutter.plugin.common.MethodChannel

public inline fun runForResult(result: MethodChannel.Result, block: () -> Any?) {
    try {
        result.success(block().takeUnless { it == Unit })
    } catch (cause: Throwable) {
        Log.e("unknown", "Error in runForResult", cause)
        result.error("1001", cause.message, null)
    }
}