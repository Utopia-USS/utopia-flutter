import 'dart:io';

import 'package:utopia_save_file/src/impl/impl.dart';
import 'package:utopia_save_file/src/impl/ios_impl.dart';
import 'package:utopia_save_file/src/impl/method_channel_impl.dart';

typedef SaveFileTargetImpl = SaveFileNativeImpl;

abstract interface class SaveFileNativeImpl implements SaveFileImpl {
  static final instance = Platform.isIOS ? SaveFileIosImpl.instance : SaveFileMethodChannelImpl.instance;
}
