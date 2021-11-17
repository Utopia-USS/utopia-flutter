package com.utopiaultimate.flutter.utopia_platform_utils.delegate

import kotlin.properties.ReadOnlyProperty
import kotlin.reflect.KProperty

public class GenericReadOnlyDelegate<T>(public val get: () -> T) : ReadOnlyProperty<Any, T> {
    public override fun getValue(thisRef: Any, property: KProperty<*>): T = get()
}