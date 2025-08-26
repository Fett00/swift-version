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
        lhs.major < rhs.major && lhs.minor < rhs.minor && lhs.patch < rhs.patch
        // TODO: add metadata and prerelease to comparsion
    }

    public static func ==(lhs: Version, rhs: Version) -> Bool {
        lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
        // TODO: add metadata and prerelease to equation
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
