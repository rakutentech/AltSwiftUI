import Danger

// MARK: - Check routine
let danger = Danger()

// SwiftLint format check.
SwiftLint.lint(.modifiedAndCreatedFiles(directory: nil), inline: true, configFile: ".swiftlint-danger.yml")
