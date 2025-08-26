import Testing
import Foundation
@testable import swift_version

@Test func majorOnlyTest() async throws {
    let version = Version(stringLiteral: "10")
    #expect(version.major == 10)
}

@Test func majorAndMinorTest() async throws {
    let version = Version(stringLiteral: "10.1")
    #expect(version.major == 10 && version.minor == 1)
}

@Test func majorAndMinor2Test() async throws {
    let version = Version(stringLiteral: "0.1")
    #expect(version.major == 0 && version.minor == 1)
}

@Test func majorMinorAndPatchTest() async throws {
    let version = Version(stringLiteral: "0.1.5")
    #expect(version.major == 0 && version.minor == 1 && version.patch == 5)
}

@Test func majorMinorAndPatch2Test() async throws {
    let version = Version(stringLiteral: "0.0.5")
    #expect(version.major == 0 && version.minor == 0 && version.patch == 5)
}

@Test func majorMinorAndPatch3Test() async throws {
    let version = Version(stringLiteral: "10.1.5")
    #expect(version.major == 10 && version.minor == 1 && version.patch == 5)
}

@Test func majorMinorPatchAndPrereleaseTest() async throws {
    let version = Version(stringLiteral: "10.1.5-alpha.1")
    #expect(version.major == 10 && version.minor == 1 && version.patch == 5 && version.prereleaseIdentifiers == ["alpha", "1"])
}

@Test func majorMinorPatchPrereleaseAndMetadataTest() async throws {
    let version = Version(stringLiteral: "10.1.5-alpha.1+m1")
    #expect(version.major == 10 && version.minor == 1 && version.patch == 5 && version.prereleaseIdentifiers == ["alpha", "1"] && version.metadataIdentifiers == ["m1"])
}

@Test func encodeToJsonTest() async throws {
    struct TestVersion: Encodable {
        let version: Version
    }

    let model = TestVersion(version: "2.12.35")
    let stringData = String(data: try JSONEncoder().encode(model), encoding: .utf8)
    #expect(stringData == "{\"version\":\"2.12.35\"}")
}

@Test func decodeFromJsonTest() async throws {

    struct TestVersion: Decodable {
        let version: Version
    }

    let rawJson =
    """
    {"version": "2.12.35"}
    """
    let data = rawJson.data(using: .utf8)
    #expect(try JSONDecoder().decode(TestVersion.self, from: data!).version == .init(stringLiteral: "2.12.35"))
}

@Test func compareTwoVersionsTest() async throws {
    var version1 = Version(stringLiteral: "9.0.0")
    var version2 = Version(stringLiteral: "8.0.0")
    #expect(version1 > version2)

    version1 = Version(stringLiteral: "9.1.0")
    version2 = Version(stringLiteral: "9.0.0")
    #expect(version1 > version2)

    version1 = Version(stringLiteral: "9.1.1")
    version2 = Version(stringLiteral: "9.1.0")
    #expect(version1 > version2)

    version1 = Version(stringLiteral: "9.10.5")
    version2 = Version(stringLiteral: "9.5.10")
    #expect(version1 > version2)

    version1 = Version(stringLiteral: "10.1.5-beta")
    version2 = Version(stringLiteral: "10.1.5-alpha")
    #expect(version1 > version2)

    version1 = Version(stringLiteral: "10.1.5-1.alpha")
    version2 = Version(stringLiteral: "10.1.5-alpha")
    #expect(version1 > version2)


    version1 = Version(stringLiteral: "1.0.0")
    version2 = Version(stringLiteral: "1.0.0-alpha")
    #expect(version1 > version2)

    version1 = Version(stringLiteral: "10.1.5-alpha.1")
    version2 = Version(stringLiteral: "10.1.5-alpha")
    #expect(version1 > version2)
}

@Test func equationTwoVersionsTest() async throws {
    var version1 = Version(stringLiteral: "10.0.0")
    var version2 = Version(stringLiteral: "10.0.0")
    #expect(version1 == version2)

    version1 = Version(stringLiteral: "10")
    version2 = Version(stringLiteral: "10.0.0")
    #expect(version1 == version2)

    version1 = Version(stringLiteral: "10.1")
    version2 = Version(stringLiteral: "10.1")
    #expect(version1 == version2)

    version1 = Version(stringLiteral: "10.1")
    version2 = Version(stringLiteral: "10.1.0")
    #expect(version1 == version2)

    version1 = Version(stringLiteral: "10.1.5")
    version2 = Version(stringLiteral: "10.1.5")
    #expect(version1 == version2)

    version1 = Version(stringLiteral: "10.1.5-alpha")
    version2 = Version(stringLiteral: "10.1.5-alpha")
    #expect(version1 == version2)

    version1 = Version(stringLiteral: "10.1.5-alpha.1")
    version2 = Version(stringLiteral: "10.1.5-alpha.1")
    #expect(version1 == version2)
}
