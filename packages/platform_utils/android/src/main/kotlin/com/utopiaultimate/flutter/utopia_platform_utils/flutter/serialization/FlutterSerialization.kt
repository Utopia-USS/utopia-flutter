package com.utopiaultimate.flutter.utopia_platform_utils.flutter.serialization

import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.SerializationStrategy
import kotlinx.serialization.json.*

public typealias FlutterData = Any?

/**
 * Warning: Requires `kotlinx-serialization-json` dependency available
 */
public fun <T> Json.encodeToFlutter(serializer: SerializationStrategy<T>, value: T): FlutterData =
    encodeToJsonElement(serializer, value).toFlutter()

/**
 * Warning: Requires `kotlinx-serialization-json` dependency available
 */
public fun <T> Json.decodeFromFlutter(serializer: DeserializationStrategy<T>, value: FlutterData): T =
    decodeFromJsonElement(serializer, JsonElement.fromFlutter(value))

private fun JsonElement.Companion.fromFlutter(data: FlutterData): JsonElement = with(data) {
    when (this) {
        is Map<*, *> -> JsonObject(asSequence().map { (key, value) -> key as String to fromFlutter(value) }.toMap())
        is Iterable<*> -> JsonArray(map { fromFlutter(it) })
        is Number -> JsonPrimitive(this)
        is Boolean -> JsonPrimitive(this)
        is String -> JsonPrimitive(this)
        null -> JsonNull
        else -> error("Cannot convert value of type ${this.javaClass.simpleName} to JsonElement")
    }
}

private fun JsonElement.toFlutter(): FlutterData = when (this) {
    is JsonPrimitive -> longOrNull ?: doubleOrNull ?: booleanOrNull ?: contentOrNull
    is JsonArray -> map { it.toFlutter() }
    is JsonObject -> mapValues { (_, value) -> value.toFlutter() }
}