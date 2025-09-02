import Testing
import Foundation
@testable import Version

@Test func initFromStringLiteralTest() async throws {
    #expect(Version(stringLiteral: "10").description == "10.0.0")
    #expect(Version(stringLiteral: "10.1").description == "10.1.0")
    #expect(Version(stringLiteral: "0.1").description == "0.1.0")
    #expect(Version(stringLiteral: "0.1.5").description == "0.1.5")
    #expect(Version(stringLiteral: "0.0.5").description == "0.0.5")
    #expect(Version(stringLiteral: "10.1.5").description == "10.1.5")
    #expect(Version(stringLiteral: "10.1.5-alpha.1").description == "10.1.5-alpha.1")
    #expect(Version(stringLiteral: "10.1.5-alpha.1+m1").description == "10.1.5-alpha.1+m1")
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

    #expect(Version(stringLiteral: "9.0.0") > Version(stringLiteral: "8.0.0"))
    #expect(Version(stringLiteral: "9.1.0") > Version(stringLiteral: "9.0.0"))
    #expect(Version(stringLiteral: "9.1.1") > Version(stringLiteral: "9.1.0"))
    #expect(Version(stringLiteral: "9.10.5") > Version(stringLiteral: "9.5.10"))
    #expect(Version(stringLiteral: "10.1.5-beta") > Version(stringLiteral: "10.1.5-alpha"))
    #expect(Version(stringLiteral: "10.1.5-1.alpha") > Version(stringLiteral: "10.1.5-alpha"))
    #expect(Version(stringLiteral: "1.0.0") > Version(stringLiteral: "1.0.0-alpha"))
    #expect(Version(stringLiteral: "10.1.5-alpha.1") > Version(stringLiteral: "10.1.5-alpha"))
}

@Test func equationTwoVersionsTest() async throws {

    #expect(Version(stringLiteral: "10.0.0") == Version(stringLiteral: "10.0.0"))
    #expect(Version(stringLiteral: "10") == Version(stringLiteral: "10.0.0"))
    #expect(Version(stringLiteral: "10.1") == Version(stringLiteral: "10.1"))
    #expect(Version(stringLiteral: "10.1") == Version(stringLiteral: "10.1.0"))
    #expect(Version(stringLiteral: "10.1.5") == Version(stringLiteral: "10.1.5"))
    #expect(Version(stringLiteral: "10.1.5-alpha") == Version(stringLiteral: "10.1.5-alpha"))
    #expect(Version(stringLiteral: "10.1.5-alpha.1") == Version(stringLiteral: "10.1.5-alpha.1"))
}

@Test func noValidInit() async throws {
    let version: Version = "Hello"
    #expect(version == Version(stringLiteral: "0.0.0"))
}

