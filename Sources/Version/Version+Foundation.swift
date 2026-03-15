#if canImport(Foundation)
import Foundation

// MARK: - Bundle
public extension Bundle {
   var version: Version? {
        guard let bundleVersion = infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        return Version(bundleVersion)
    }

    var minimalSystemVersion: Version? {
        guard let minimalSystemVersionString = infoDictionary?["CFBundleMinimumOSVersion"] as? String else {
            return nil
        }
        return Version(minimalSystemVersionString)
    }
}

public extension ProcessInfo {
    var operationSystemVersion: Version {
        let originalVersion: OperatingSystemVersion = operatingSystemVersion
        return Version(
            major: originalVersion.majorVersion,
            minor: originalVersion.minorVersion,
            patch: originalVersion.patchVersion
        )
    }

    func isOperatingSystemAtLeast(_ version: Version) -> Bool {
        operationSystemVersion >= version
    }
}
#endif
