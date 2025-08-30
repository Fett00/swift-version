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
public struct Version: ExpressibleByStringLiteral {

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

    /// Creates a `Version` instance from a string literal.
    ///
    /// Example:
    /// ```swift
    /// let v: Version = "1.2.3-beta+exp.sha.5114f85"
    /// ```
    public init(stringLiteral value: StringLiteralType) {

        var editableValue = value

        let beforePrereleaseIndex = value.firstIndex(of: "-")
        let beforeMetadataIndex = value.firstIndex(of: "+")

        if let beforeMetadataIndex {
            let metadataIndex = editableValue.index(after: beforeMetadataIndex)
            let metadataRange = metadataIndex ..< editableValue.endIndex
            self.metadataIdentifiers = editableValue[metadataRange]
                .split(separator: ".")
                .compactMap({ String($0) })
            editableValue
                .removeSubrange(beforeMetadataIndex..<editableValue.endIndex) // replace. removing is too expansive
        } else {
            self.metadataIdentifiers = []
        }

        if let beforePrereleaseIndex {
            let prereleaseIndex = editableValue.index(after: beforePrereleaseIndex)
            let prereleaseRange = prereleaseIndex ..< editableValue.endIndex
            self.prereleaseIdentifiers = editableValue[prereleaseRange]
                .split(separator: ".")
                .compactMap({ String($0) })
            editableValue
                .removeSubrange(beforePrereleaseIndex..<editableValue.endIndex) // replace. removing is too expansive
        } else {
            self.prereleaseIdentifiers = []
        }

        let numbers = editableValue.split(separator: ".").compactMap({ UInt($0) })
        switch numbers.count {
        case 1:
            (major, minor, patch) = (numbers[0], 0, 0)
        case 2:
            (major, minor, patch) = (numbers[0], numbers[1], 0)
        case 3:
            (major, minor, patch) = (numbers[0], numbers[1], numbers[2])
        default:
            (major, minor, patch) = (0, 0, 0)
        }
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
