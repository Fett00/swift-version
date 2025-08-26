/// Describe version of something
///
/// Applyed Semantic Versioning 2.0.0
public struct Version: ExpressibleByStringLiteral {

    /// The major version according to the semantic versioning standard.
    public let major: UInt
    /// The minor version according to the semantic versioning standard.
    public let minor: UInt
    /// The patch version according to the semantic versioning standard.
    public let patch: UInt
    /// The pre-release identifier according to the semantic versioning standard, starting with appending a hyphen and a series of dot separated identifiers
    /// Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7, 1.0.0-x.7.z.92, 1.0.0-x-y-z.--.
    public let prereleaseIdentifiers: [String]
    /// The build metadata of this version according to the semantic versioning standard, starting with appending a plus sign and a series of dot separated identifiers
    /// Examples: 1.0.0-alpha+001, 1.0.0+20130313144700, 1.0.0-beta+exp.sha.5114f85, 1.0.0+21AF26D3----117B344092BD.
    public let metadataIdentifiers: [String]

    public var stringRepresentation: String {
        "\(major).\(minor).\(patch)"
        + (prereleaseIdentifiers.isEmpty ? "" : "\(prereleaseIdentifiers)")
        + (metadataIdentifiers.isEmpty ? "" : "\(metadataIdentifiers)")
    }

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
        zip(lhs, rhs).allSatisfy {
            if let lhsDigit = UInt($0), let rhsDigit = UInt($1) {
                return lhsDigit == rhsDigit
            } else {
                return $0 == $1
            }
        }
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
