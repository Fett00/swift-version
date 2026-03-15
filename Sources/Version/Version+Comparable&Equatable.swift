// MARK: - Equatable

extension Version: Equatable {
    public static func ==(lhs: Version, rhs: Version) -> Bool {
        lhs.major == rhs.major
        && lhs.minor == rhs.minor
        && lhs.patch == rhs.patch
        && equalPrereleases(
            lhs: lhs.prereleaseIdentifiers,
            rhs: rhs.prereleaseIdentifiers
        )
    }

    private static func equalPrereleases(lhs: [String], rhs: [String]) -> Bool {
        if lhs.count != rhs.count {
            return false
        }
        return lhs.elementsEqual(rhs)
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
        // normal version > prerelease
        if lhs.isEmpty && !rhs.isEmpty { return false }
        if !lhs.isEmpty && rhs.isEmpty { return true }

        for (lhsItem, rhsItem) in zip(lhs, rhs) {
            let lhsNum = UInt(lhsItem)
            let rhsNum = UInt(rhsItem)

            if let l = lhsNum, let r = rhsNum {
                if l != r { return l < r }
            } else if lhsNum != nil {
                // numeric < alphanumeric
                return true
            } else if rhsNum != nil {
                return false
            } else {
                if lhsItem != rhsItem { return lhsItem < rhsItem }
            }
        }

        // if all equal so far → shorter set has lower priority
        return lhs.count < rhs.count
    }

}

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
