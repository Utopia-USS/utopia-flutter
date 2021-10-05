package com.utopiaultimate.flutter.utopia_save_file

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware

class UtopiaSaveFilePlugin(private val impl: UtopiaSaveFilePluginImpl = UtopiaSaveFilePluginImpl()) :
  FlutterPlugin by impl, ActivityAware by impl