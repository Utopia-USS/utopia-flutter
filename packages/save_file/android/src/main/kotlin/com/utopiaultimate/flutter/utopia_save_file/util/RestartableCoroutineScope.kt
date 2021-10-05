package com.utopiaultimate.flutter.utopia_save_file.util

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlin.coroutines.CoroutineContext

open class RestartableCoroutineScope(private val context: CoroutineContext) : CoroutineScope {
    private var job: Job? = null

    override val coroutineContext get() = context + checkNotNull(job) { "Scope not initialized" }

    protected fun initialize() {
        job = Job()
    }

    protected fun cancel() {
        (this as CoroutineScope).cancel()
        job = null
    }
}