package com.utopiaultimate.flutter.utopia_platform_utils.delegate

import kotlin.properties.ReadOnlyProperty

public val <T> Lazy<T>.delegate: ReadOnlyProperty<Any, T> get() = GenericReadOnlyDelegate(get = { value })
