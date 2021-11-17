package com.utopiaultimate.flutter.utopia_save_file.dto

class SaveFileFromBytesDto(map: Map<String, Any>) {
  val bytes: ByteArray by map
  val name: String by map
  val mime: String by map
}