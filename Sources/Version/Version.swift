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

// MARK: - Sendable

#if swift(>=5.5)
extension Version: Sendable {}
#endif

// MARK: - Hashable

extension Version: Hashable {}
