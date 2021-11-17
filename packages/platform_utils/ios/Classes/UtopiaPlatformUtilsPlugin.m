#import "UtopiaPlatformUtilsPlugin.h"
#if __has_include(<utopia_platform_utils/utopia_platform_utils-Swift.h>)
#import <utopia_platform_utils/utopia_platform_utils-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "utopia_platform_utils-Swift.h"
#endif

@implementation UtopiaPlatformUtilsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUtopiaPlatformUtilsPlugin registerWithRegistrar:registrar];
}
@end
