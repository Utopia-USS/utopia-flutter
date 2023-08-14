import 'dart:io';

import 'package:utopia_save_file/src/impl/android_impl.dart';
import 'package:utopia_save_file/src/impl/impl.dart';
import 'package:utopia_save_file/src/impl/ios_impl.dart';

typedef SaveFileTargetImpl = SaveFileNativeImpl;

abstract interface class SaveFileNativeImpl implements SaveFileImpl {
  static final instance = Platform.isIOS ? SaveFileIosImpl.instance : SaveFileAndroidImpl.instance;
}
