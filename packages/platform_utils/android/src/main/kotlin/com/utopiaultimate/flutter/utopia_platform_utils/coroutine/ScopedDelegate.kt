package com.utopiaultimate.flutter.utopia_platform_utils.coroutine

import com.utopiaultimate.flutter.utopia_platform_utils.delegate.delegate
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.awaitCancellation
import kotlinx.coroutines.launch
import kotlin.properties.ReadOnlyProperty
import kotlin.reflect.KProperty

public fun <T> CoroutineScope.scopedLazy(provider: () -> T): ReadOnlyProperty<Any, T> =
    scopedDelegate { lazy(provider).delegate }

public fun <T> CoroutineScope.scopedDelegate(
    delegateProvider: () -> ReadOnlyProperty<Any, T>,
): ReadOnlyProperty<Any, T> = ScopedDelegate(this, delegateProvider)

private class ScopedDelegate<T>(
    private val scope: CoroutineScope,
    private val delegateProvider: () -> ReadOnlyProperty<Any, T>,
) : ReadOnlyProperty<Any, T> {
    private var delegate: ReadOnlyProperty<Any, T>? = null

    override fun getValue(thisRef: Any, property: KProperty<*>): T {
        if (delegate == null) {
            delegate = delegateProvider()
            scope.launch {
                try {
                    awaitCancellation()
                } finally {
                    delegate = null
                }
            }
        }
        return delegate!!.getValue(thisRef, property)
    }
}