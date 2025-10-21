/// Representation of a version following the Semantic Versioning 2.0.0 specification.
///
/// `Version` encapsulates the following components:
/// - `major` — major version (incompatible API changes)
/// - `minor` — minor version (new functionality in a backward-compatible manner)
/// - `patch` — patch version (backward-compatible bug fixes)
/// - `prereleaseIdentifiers` — array of pre-release identifiers (e.g. `["alpha", "1"]`)
/// - `metadataIdentifiers` — array of build metadata identifiers (e.g. `["001", "sha.5114f85"]`)
///
/// Example:
/// ```swift
/// let version = Version(major: 5, minor: 15, patch: 35, prereleaseIdentifiers: ["alpha"], metadataIdentifiers: ["001"])
/// print(version) // "5.15.35-alpha+001"
///
/// let version: Version = "1.11.31"
/// print(version) // "1.11.31"
/// ```
public struct Version {

    /// The major version according to the semantic versioning standard.
    public let major: UInt

    /// The minor version according to the semantic versioning standard.
    public let minor: UInt

    /// The patch version according to the semantic versioning standard.
    public let patch: UInt

    /// The pre-release identifiers (e.g. `["alpha"]`, `["beta", "1"]`).
    ///
    /// Examples:
    /// - `1.0.0-alpha` → `["alpha"]`
    /// - `1.0.0-alpha.1` → `["alpha", "1"]`
    public let prereleaseIdentifiers: [String]

    /// The build metadata identifiers (e.g. `["001"]`, `["exp", "sha.5114f85"]`).
    ///
    /// Examples:
    /// - `1.0.0+20130313144700` → `["20130313144700"]`
    /// - `1.0.0-beta+exp.sha.5114f85` → `["exp", "sha.5114f85"]`
    public let metadataIdentifiers: [String]

    /// Returns the normalized string representation of the version.
    /// Example: `"1.2.3-beta+001"`
    public var stringRepresentation: String {
        "\(major).\(minor).\(patch)"
        + (prereleaseIdentifiers.isEmpty ? "" : "-\(prereleaseIdentifiers.joined(separator: "."))")
        + (metadataIdentifiers.isEmpty ? "" : "+\(metadataIdentifiers.joined(separator: "."))")
    }

    /// Creates a `Version` instance from explicit components.
    public init(
        major: UInt,
        minor: UInt,
        patch: UInt,
        prereleaseIdentifiers: [String] = [],
        metadataIdentifiers: [String] = []
    ) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prereleaseIdentifiers = prereleaseIdentifiers
        self.metadataIdentifiers = metadataIdentifiers
    }
}

// MARK: - ExpressibleByStringLiteral
extension Version: ExpressibleByStringLiteral {

    /// Creates a `Version` instance from a string literal.
    ///
    /// Example:
    /// ```swift
    /// let v: Version = "1.2.3-beta+exp.sha.5114f85"
    /// ```
    public init(stringLiteral value: StringLiteralType) {

        let prereleaseStart = value.firstIndex(of: "-")
        let metadataStart = value.firstIndex(of: "+")
        let startWithV = value.hasPrefix("v")

        let startOfMainPart = startWithV ? value.index(value.startIndex, offsetBy: 1) : value.startIndex
        let endOfMainPart = prereleaseStart ?? metadataStart ?? value.endIndex
        let mainPart = value[startOfMainPart..<endOfMainPart]

        if let metadataStart {
            let metadataIndex = value.index(after: metadataStart)
            self.metadataIdentifiers = value[metadataIndex...]
                .split(separator: ".")
                .map(String.init)
        } else {
            self.metadataIdentifiers = []
        }

        if let prereleaseStart {
            let prereleaseEnd = metadataStart ?? value.endIndex
            let prereleaseIndex = value.index(after: prereleaseStart)
            self.prereleaseIdentifiers = value[prereleaseIndex..<prereleaseEnd]
                .split(separator: ".")
                .map(String.init)
        } else {
            self.prereleaseIdentifiers = []
        }

        let numbers = mainPart.split(separator: ".").compactMap({ UInt($0) })
        switch numbers.count {
        case 1: (major, minor, patch) = (numbers[0], 0, 0)
        case 2: (major, minor, patch) = (numbers[0], numbers[1], 0)
        case 3: (major, minor, patch) = (numbers[0], numbers[1], numbers[2])
        default: (major, minor, patch) = (0, 0, 0)
        }
    }
}

// MARK: - LosslessStringConvertible
extension Version: LosslessStringConvertible {
    public init?(_ description: String) {

        guard !description.isEmpty else { return nil }

        let prereleaseStart = description.firstIndex(of: "-")
        let metadataStart = description.firstIndex(of: "+")
        let startWithV = description.hasPrefix("v")

        let startOfMainPart = startWithV ? description.index(description.startIndex, offsetBy: 1) : description.startIndex
        let endOfMainPart = prereleaseStart ?? metadataStart ?? description.endIndex
        let mainPart = description[startOfMainPart..<endOfMainPart]

        if let metadataStart {
            let metadataIndex = description.index(after: metadataStart)
            self.metadataIdentifiers = description[metadataIndex...]
                .split(separator: ".")
                .map(String.init)
        } else {
            self.metadataIdentifiers = []
        }

        if let prereleaseStart {
            let prereleaseEnd = metadataStart ?? description.endIndex
            let prereleaseIndex = description.index(after: prereleaseStart)
            self.prereleaseIdentifiers = description[prereleaseIndex..<prereleaseEnd]
                .split(separator: ".")
                .map(String.init)
        } else {
            self.prereleaseIdentifiers = []
        }

        let numbers = mainPart.split(separator: ".").compactMap({ UInt($0) })
        switch numbers.count {
        case 1: (major, minor, patch) = (numbers[0], 0, 0)
        case 2: (major, minor, patch) = (numbers[0], numbers[1], 0)
        case 3: (major, minor, patch) = (numbers[0], numbers[1], numbers[2])
        default: return nil
        }
    }
}

// MARK: - Comparable
extension Version: Comparable {
    
    public static func < (lhs: Version, rhs: Version) -> Bool {
        lhs.major < rhs.major
        || lhs.minor < rhs.minor
        || lhs.patch < rhs.patch
        || comparePrereleases(
            lhs: lhs.prereleaseIdentifiers,
            rhs: rhs.prereleaseIdentifiers
        )
    }

    public static func ==(lhs: Version, rhs: Version) -> Bool {
        lhs.major == rhs.major
        && lhs.minor == rhs.minor
        && lhs.patch == rhs.patch
        && equalPrereleases(
            lhs: lhs.prereleaseIdentifiers,
            rhs: rhs.prereleaseIdentifiers
        )
    }

    /// Compare prereleases part
    ///
    /// **Comparison rules:**
    ///
    /// Precedence for two pre-release versions MUST be determined by comparing each dot separated identifier from left to right until a difference is found as follows:
    /// 1. Identifiers consisting of only digits are compared numerically.
    /// 2. Identifiers with letters or hyphens are compared lexically in ASCII sort order.
    /// 3. Numeric identifiers always have lower precedence than non-numeric identifiers.
    /// 4. A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal.
    private static func comparePrereleases(lhs: [String], rhs: [String]) -> Bool {
        if lhs.count != rhs.count {
            if lhs.count == 0 {
                return false
            } else if rhs.count == 0 {
                return true
            }
            return lhs.count < rhs.count
        }
        for (lhsItem, rhsItem) in zip(lhs, rhs) {
            if let lhsDigit = UInt(lhsItem), let rhsDigit = UInt(rhsItem) {
                if lhsDigit < rhsDigit {
                    return true
                }
            } else {
                if lhsItem < rhsItem {
                    return true
                }
            }
        }
        return false
    }

    private static func equalPrereleases(lhs: [String], rhs: [String]) -> Bool {
        if lhs.count != rhs.count {
            return false
        }
        return lhs.elementsEqual(rhs)
    }
}

// MARK: - CustomStringConvertible
extension Version: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        stringRepresentation
    }

    public var debugDescription: String {
        "Version: major \(major), minor \(minor), patch \(patch)"
        + (prereleaseIdentifiers.isEmpty ? "" : ", preReleaseIdentifiers: \(prereleaseIdentifiers)")
        + (metadataIdentifiers.isEmpty ? "" : ", metadataIdentifiers: \(metadataIdentifiers)")
    }
}

// MARK: - Codable
extension Version: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(stringLiteral: string)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringRepresentation)
    }
}

// MARK: - Sendable
#if swift(>=5.5)
extension Version: Sendable {}
#endif

#if canImport(Foundation)
import Foundation

// MARK: - Bundle
extension Bundle {
    public var version: Version? {
        guard let bundleVersion = infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        return Version(bundleVersion)
    }

    public var minimalSystemVersion: Version? {
        guard let minimalSystemVersionString = infoDictionary?["CFBundleMinimumOSVersion"] as? String else {
            return nil
        }
        return Version(minimalSystemVersionString)
    }
}
#endif

// MARK: - Semantic Comparison Utilities
extension Version {

    /// Determines whether this version is semantically compatible with another version.
    ///
    /// According to semantic versioning, two versions are considered compatible if they share the same major version number.
    /// This means that there are no breaking API changes between them, and minor or patch differences are backward compatible.
    ///
    /// - Parameter other: The version to compare with this version.
    /// - Returns: `true` if both versions have the same major version; otherwise, `false`.
    public func isCompatible(_ other: Version) -> Bool {
        self.major == other.major
    }

    /// Determines whether this version introduces breaking changes compared to another version.
    ///
    /// According to semantic versioning, a breaking change typically corresponds to a change in the major version number.
    ///
    /// - Parameter other: The version to compare against.
    /// - Returns: `true` if the major versions differ and thus represent a breaking change; otherwise, `false`.
    public func hasBreakingChanges(_ other: Version) -> Bool {
        !isCompatible(other)
    }

    /// Computes the semantic difference between this version and another version.
    ///
    /// This method returns a new `Version` whose components represent the absolute
    /// differences between corresponding components of the two versions:
    /// - `major`, `minor`, and `patch` are the absolute numeric differences of the respective
    ///   components.
    /// - `prereleaseIdentifiers` and `metadataIdentifiers` are the symmetric differences of the
    ///   two versions’ identifier arrays (i.e., identifiers present in exactly one of the versions).
    ///
    /// Notes:
    /// - The returned version is not intended to be a valid semantic version for distribution;
    ///   it is a structural “diff” useful for inspection, comparison, or reporting.
    /// - Symmetric difference of identifiers does not preserve ordering and removes duplicates,
    ///   since it is computed via sets.
    ///
    /// - Parameter other: The version to compare against this version.
    /// - Returns: A `Version` whose fields describe how the two versions differ.
    public func diff(_ other: Version) -> Version {
        Version(
            major: UInt(abs(Int(self.major) - Int(other.major))),
            minor: UInt(abs(Int(self.minor) - Int(other.minor))),
            patch: UInt(abs(Int(self.patch) - Int(other.patch))),
            prereleaseIdentifiers: Array(Set(self.prereleaseIdentifiers).symmetricDifference(other.prereleaseIdentifiers)),
            metadataIdentifiers: Array(Set(self.metadataIdentifiers).symmetricDifference(other.metadataIdentifiers))
        )
    }
}
