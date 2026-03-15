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

// MARK: - Other strings extionsions

extension Version {
    /// Returns the normalized string representation of the version.
    /// Example: `"1.2.3-beta+001"`
    public var stringRepresentation: String {
        "\(major).\(minor).\(patch)"
        + (prereleaseIdentifiers.isEmpty ? "" : "-\(prereleaseIdentifiers.joined(separator: "."))")
        + (metadataIdentifiers.isEmpty ? "" : "+\(metadataIdentifiers.joined(separator: "."))")
    }
}
