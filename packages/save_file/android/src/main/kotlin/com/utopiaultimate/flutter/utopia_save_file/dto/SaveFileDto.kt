package com.utopiaultimate.flutter.utopia_save_file.dto

sealed class SaveFileDto(map: Map<String, Any>) {
  val name: String by map
  val mime: String by map

  class FromFile(map: Map<String, Any>) : SaveFileDto(map) {
    val path: String by map
  }

  class FromUrl(map: Map<String, Any>) : SaveFileDto(map) {
    val url: String by map
  }

  class FromBytes(map: Map<String, Any>) : SaveFileDto(map) {
    val bytes: ByteArray by map
  }
}