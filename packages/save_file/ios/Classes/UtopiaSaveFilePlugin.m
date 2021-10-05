#import "UtopiaSaveFilePlugin.h"
#if __has_include(<utopia_save_file/save_file-Swift.h>)
#import <save_file/utopia_save_file-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "utopia_save_file-Swift.h"
#endif

@implementation UtopiaSaveFilePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUtopiaSaveFilePlugin registerWithRegistrar:registrar];
}
@end
