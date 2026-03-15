public extension Version {

    /// Creates a `Version` instance from explicit components.
    ///
    /// > Warning: Passing a value that can’t be represented in this type as unsigned integer results in a runtime error.
    init<T: BinaryInteger>(
        major: T,
        minor: T,
        patch: T,
        prereleaseIdentifiers: [String] = [],
        metadataIdentifiers: [String] = []
    ) {
        self.init(
            major: UInt(major),
            minor: UInt(minor),
            patch: UInt(patch),
            prereleaseIdentifiers: prereleaseIdentifiers,
            metadataIdentifiers: metadataIdentifiers
        )
    }
}
