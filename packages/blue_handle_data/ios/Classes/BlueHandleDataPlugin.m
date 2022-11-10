#import "BlueHandleDataPlugin.h"
#if __has_include(<blue_handle_data/blue_handle_data-Swift.h>)
#import <blue_handle_data/blue_handle_data-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "blue_handle_data-Swift.h"
#endif

@implementation BlueHandleDataPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBlueHandleDataPlugin registerWithRegistrar:registrar];
}
@end
