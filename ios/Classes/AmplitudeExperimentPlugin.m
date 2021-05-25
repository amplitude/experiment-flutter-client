#import "AmplitudeExperimentPlugin.h"
#if __has_include(<amplitude_experiment/amplitude_experiment-Swift.h>)
#import <amplitude_experiment/amplitude_experiment-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "amplitude_experiment-Swift.h"
#endif

@implementation AmplitudeExperimentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAmplitudeExperimentPlugin registerWithRegistrar:registrar];
}
@end
