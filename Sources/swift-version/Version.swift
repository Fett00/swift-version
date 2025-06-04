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

    public var stringRepresentation: String {
        "\(major).\(minor).\(patch)"
    }

    public var shortStringRepresentation: String {
        "\(major)" + (minor > 0 ? ".\(minor)" : "") + (patch > 0 ? ".\(patch)" : "")
    }

    public init(stringLiteral value: StringLiteralType) {
        let numbers = value.split(separator: ".").compactMap({ UInt($0) })
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

    public init(major: UInt, minor: UInt, patch: UInt) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

extension Version: Comparable {

    public static func < (lhs: Version, rhs: Version) -> Bool {
        lhs.major < rhs.major && lhs.minor < rhs.minor && lhs.patch < rhs.patch
    }

    public static func ==(lhs: Version, rhs: Version) -> Bool {
        lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}

extension Version: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        stringRepresentation
    }

    public var debugDescription: String {
        "Version: major \(major), minor \(minor), patch \(patch)"
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
