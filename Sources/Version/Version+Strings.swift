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

// MARK: - CustomStringConvertible

extension Version: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        formattedStringRepresentation(.full)
    }

    public var debugDescription: String {
        "Version(major: \(major), minor: \(minor), patch: \(patch)"
        + (prereleaseIdentifiers.isEmpty ? "" : ", preReleaseIdentifiers: \(prereleaseIdentifiers)")
        + (metadataIdentifiers.isEmpty ? "" : ", metadataIdentifiers: \(metadataIdentifiers)")
        + ")"
    }
}

// MARK: - Formatted

extension Version {

    /// Version string formatting options for different display contexts.
    public enum Format {
        /// Short format: `"1.2.3"`
        /// Contains only major, minor, and patch numbers.
        case short

        /// Full SemVer format: `"1.2.3-beta+001"`
        /// Includes pre-release identifiers (`-`) and build metadata (`+`).
        case full

        /// Pretty format: `"v1.2.3-beta+001"`
        /// Adds a leading `v` prefix, commonly used for Git tags and changelogs.
        case pretty
    }

    /// Returns the version string in the specified format.
    ///
    /// - Parameters:
    ///   - format: The desired output format.
    /// - Returns: Formatted version string matching the specified style.
    /// - Example:
    ///   ```swift
    ///   let version = Version(1, 2, 3, preRelease: ["beta"], metadata: ["001"])
    ///   version.formattedStringRepresentation(.short)   // "1.2.3"
    ///   version.formattedStringRepresentation(.full)    // "1.2.3-beta+001"
    ///   version.formattedStringRepresentation(.pretty)  // "v1.2.3-beta+001"
    ///   ```
    public func formattedStringRepresentation(_ format: Format) -> String {
        switch format {
        case .short:
            shortFormat()
        case .full:
            fullFormat()
        case .pretty:
            prettyFormat()
        }
    }

    private func shortFormat() -> String {
        "\(major).\(minor).\(patch)"
    }

    private func fullFormat() -> String {
        "\(major).\(minor).\(patch)"
        + (prereleaseIdentifiers.isEmpty ? "" : "-\(prereleaseIdentifiers.joined(separator: "."))")
        + (metadataIdentifiers.isEmpty ? "" : "+\(metadataIdentifiers.joined(separator: "."))")
    }

    private func prettyFormat() -> String {
        "v\(major).\(minor).\(patch)"
        + (prereleaseIdentifiers.isEmpty ? "" : "-\(prereleaseIdentifiers.joined(separator: "."))")
        + (metadataIdentifiers.isEmpty ? "" : "+\(metadataIdentifiers.joined(separator: "."))")
    }
}
