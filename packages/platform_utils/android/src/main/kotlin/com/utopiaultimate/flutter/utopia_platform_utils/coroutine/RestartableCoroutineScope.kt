package com.utopiaultimate.flutter.utopia_platform_utils.coroutine

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlin.coroutines.CoroutineContext

public open class RestartableCoroutineScope(private val context: CoroutineContext) : CoroutineScope {
    private var job: Job? = null

    override val coroutineContext: CoroutineContext get() = context + checkNotNull(job) { "Scope not initialized" }

    public fun openScope() {
        job = SupervisorJob()
    }

    public fun closeScope() {
        (this as CoroutineScope).cancel()
        job = null
    }
}