#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint experiment_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'amplitude_experiment'
  s.version          = '0.1.0-beta.1' # x-release-please-version
  s.summary          = 'The official Amplitude Experiment Flutter SDK'
  s.description      = <<-DESC
The official Amplitude Experiment Flutter SDK for evaluating feature flags and running experiments across iOS, Android, and Web.
                       DESC
  s.homepage         = 'https://github.com/amplitude/experiment-flutter-client'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Amplitude' => 'support@amplitude.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency 'AmplitudeExperiment', '1.19.0'

  s.resource_bundles = {'amplitude_experiment_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
