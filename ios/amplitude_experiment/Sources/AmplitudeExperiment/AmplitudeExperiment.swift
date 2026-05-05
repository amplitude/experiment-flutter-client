// Re-export target so SPM consumers can `import AmplitudeExperiment` and
// match the CocoaPods module name. The upstream iOS SDK ships an SPM
// product/target named `Experiment`; CocoaPods ships the same code as
// `AmplitudeExperiment`. This shim bridges that naming gap so plugin
// sources compile unchanged under both package managers.

@_exported import Experiment
