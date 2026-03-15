import Testing
import Foundation
@testable import Version

@Suite
struct BasicTests {

    @Test func initFromStringLiteralTest() async throws {
        #expect(Version(stringLiteral: "10").description == "10.0.0")
        #expect(Version(stringLiteral: "10.1").description == "10.1.0")
        #expect(Version(stringLiteral: "0.1").description == "0.1.0")
        #expect(Version(stringLiteral: "0.1.5").description == "0.1.5")
        #expect(Version(stringLiteral: "0.0.5").description == "0.0.5")
        #expect(Version(stringLiteral: "10.1.5").description == "10.1.5")
        #expect(Version(stringLiteral: "10.1.5-alpha.1").description == "10.1.5-alpha.1")
        #expect(Version(stringLiteral: "10.1.5-alpha.1+m1").description == "10.1.5-alpha.1+m1")

        #expect(Version(stringLiteral: "v0.1.5").description == "0.1.5")
        #expect(Version(stringLiteral: "v10.1.5").description == "10.1.5")
        #expect(Version(stringLiteral: "v10.1.5-alpha.1").description == "10.1.5-alpha.1")
        #expect(Version(stringLiteral: "v10.1.5-alpha.1+m1").description == "10.1.5-alpha.1+m1")

        #expect(Version(stringLiteral: "0.0.0").description == "0.0.0")
    }

    @Test func initFromStringDescriptionTest() async throws {
        #expect(Version("10").description == "10.0.0")
        #expect(Version("10.1").description == "10.1.0")
        #expect(Version("0.1").description == "0.1.0")
        #expect(Version("0.1.5").description == "0.1.5")
        #expect(Version("0.0.5").description == "0.0.5")
        #expect(Version("10.1.5").description == "10.1.5")
        #expect(Version("10.1.5-alpha.1").description == "10.1.5-alpha.1")
        #expect(Version("10.1.5-alpha.1+m1").description == "10.1.5-alpha.1+m1")

        #expect(Version("v0.1.5").description == "0.1.5")
        #expect(Version("v10.1.5").description == "10.1.5")
        #expect(Version("v10.1.5-alpha.1").description == "10.1.5-alpha.1")
        #expect(Version("v10.1.5-alpha.1+m1").description == "10.1.5-alpha.1+m1")
    }

    @Test func initFromBasicLiteralTest() async throws {
        #expect(Version(major: 10, minor: 0, patch: 0).description == "10.0.0")
        #expect(Version(major: 10, minor: 1, patch: 0).description == "10.1.0")
        #expect(Version(major: 0, minor: 1, patch: 0).description == "0.1.0")
        #expect(Version(major: 0, minor: 1, patch: 5).description == "0.1.5")
        #expect(Version(major: 0, minor: 0, patch: 5).description == "0.0.5")
        #expect(Version(major: 10, minor: 1, patch: 5).description == "10.1.5")
    }

    @Test func initFromBinaryIntegerTest() async throws {
        #expect(Version(major: Int(1), minor: Int(0), patch: Int(0)).description == "1.0.0")
        #expect(Version(major: Int(1), minor: Int(1), patch: Int(0)).description == "1.1.0")
        #expect(Version(major: Int(0), minor: Int(1), patch: Int(0)).description == "0.1.0")
        #expect(Version(major: Int(0), minor: Int(1), patch: Int(5)).description == "0.1.5")
        #expect(Version(major: Int(0), minor: Int(0), patch: Int(5)).description == "0.0.5")
        #expect(Version(major: Int(1), minor: Int(1), patch: Int(5)).description == "1.1.5")

        #expect(Version(major: Int8(1), minor: Int8(0), patch: Int8(0)).description == "1.0.0")
        #expect(Version(major: Int8(1), minor: Int8(1), patch: Int8(0)).description == "1.1.0")
        #expect(Version(major: Int8(0), minor: Int8(1), patch: Int8(0)).description == "0.1.0")
        #expect(Version(major: Int8(0), minor: Int8(1), patch: Int8(5)).description == "0.1.5")
        #expect(Version(major: Int8(0), minor: Int8(0), patch: Int8(5)).description == "0.0.5")
        #expect(Version(major: Int8(1), minor: Int8(1), patch: Int8(5)).description == "1.1.5")

        #expect(Version(major: UInt8(1), minor: UInt8(0), patch: UInt8(0)).description == "1.0.0")
        #expect(Version(major: UInt8(1), minor: UInt8(1), patch: UInt8(0)).description == "1.1.0")
        #expect(Version(major: UInt8(0), minor: UInt8(1), patch: UInt8(0)).description == "0.1.0")
        #expect(Version(major: UInt8(0), minor: UInt8(1), patch: UInt8(5)).description == "0.1.5")
        #expect(Version(major: UInt8(0), minor: UInt8(0), patch: UInt8(5)).description == "0.0.5")
        #expect(Version(major: UInt8(1), minor: UInt8(1), patch: UInt8(5)).description == "1.1.5")
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
        #expect(Version(stringLiteral: "1.0.0") > Version(stringLiteral: "1.0.0-alpha"))
        #expect(Version(stringLiteral: "10.1.5-alpha.1") > Version(stringLiteral: "10.1.5-alpha"))

        #expect(Version(stringLiteral: "1.0.0-alpha") < Version(stringLiteral: "1.0.0-alpha.1"))
        #expect(Version(stringLiteral: "1.0.0-alpha.1") < Version(stringLiteral: "1.0.0-alpha.beta"))
        #expect(Version(stringLiteral: "1.0.0-alpha.beta") < Version(stringLiteral: "1.0.0-beta"))
        #expect(Version(stringLiteral: "1.0.0-beta") < Version(stringLiteral: "1.0.0-beta.2"))
        #expect(Version(stringLiteral: "1.0.0-beta.2") < Version(stringLiteral: "1.0.0-beta.11"))
        #expect(Version(stringLiteral: "1.0.0-beta.11") < Version(stringLiteral: "1.0.0-rc.1"))
        #expect(Version(stringLiteral: "1.0.0-rc.1") < Version(stringLiteral: "1.0.0"))
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

    @Test func formattedStringTest() async throws {
        #expect(Version(stringLiteral: "10").formattedStringRepresentation(.full) == "10.0.0")
        #expect(Version(stringLiteral: "10.1").formattedStringRepresentation(.full) == "10.1.0")
        #expect(Version(stringLiteral: "0.1").formattedStringRepresentation(.full) == "0.1.0")
        #expect(Version(stringLiteral: "0.1.5").formattedStringRepresentation(.full) == "0.1.5")
        #expect(Version(stringLiteral: "0.0.5").formattedStringRepresentation(.full) == "0.0.5")
        #expect(Version(stringLiteral: "10.1.5").formattedStringRepresentation(.full) == "10.1.5")
        #expect(Version(stringLiteral: "10.1.5-alpha.1").formattedStringRepresentation(.full) == "10.1.5-alpha.1")
        #expect(Version(stringLiteral: "10.1.5-alpha.1+m1").formattedStringRepresentation(.full) == "10.1.5-alpha.1+m1")

        #expect(Version(stringLiteral: "10").formattedStringRepresentation(.short) == "10.0.0")
        #expect(Version(stringLiteral: "10.1").formattedStringRepresentation(.short) == "10.1.0")
        #expect(Version(stringLiteral: "0.1").formattedStringRepresentation(.short) == "0.1.0")
        #expect(Version(stringLiteral: "0.1.5").formattedStringRepresentation(.short) == "0.1.5")
        #expect(Version(stringLiteral: "0.0.5").formattedStringRepresentation(.short) == "0.0.5")
        #expect(Version(stringLiteral: "10.1.5").formattedStringRepresentation(.short) == "10.1.5")
        #expect(Version(stringLiteral: "10.1.5-alpha.1").formattedStringRepresentation(.short) == "10.1.5")
        #expect(Version(stringLiteral: "10.1.5-alpha.1+m1").formattedStringRepresentation(.short) == "10.1.5")

        #expect(Version(stringLiteral: "10").formattedStringRepresentation(.pretty) == "v10.0.0")
        #expect(Version(stringLiteral: "10.1").formattedStringRepresentation(.pretty) == "v10.1.0")
        #expect(Version(stringLiteral: "0.1").formattedStringRepresentation(.pretty) == "v0.1.0")
        #expect(Version(stringLiteral: "0.1.5").formattedStringRepresentation(.pretty) == "v0.1.5")
        #expect(Version(stringLiteral: "0.0.5").formattedStringRepresentation(.pretty) == "v0.0.5")
        #expect(Version(stringLiteral: "10.1.5").formattedStringRepresentation(.pretty) == "v10.1.5")
        #expect(Version(stringLiteral: "10.1.5-alpha.1").formattedStringRepresentation(.pretty) == "v10.1.5-alpha.1")
        #expect(Version(stringLiteral: "10.1.5-alpha.1+m1").formattedStringRepresentation(.pretty) == "v10.1.5-alpha.1+m1")
    }

    @Test func descriptionStringTest() async throws {
        #expect(String(describing: Version(stringLiteral: "10")) == "10.0.0")
        #expect(String(describing: Version(stringLiteral: "10.1")) == "10.1.0")
        #expect(String(describing: Version(stringLiteral: "0.1")) == "0.1.0")
        #expect(String(describing: Version(stringLiteral: "0.1.5")) == "0.1.5")
        #expect(String(describing: Version(stringLiteral: "0.0.5")) == "0.0.5")
        #expect(String(describing: Version(stringLiteral: "10.1.5")) == "10.1.5")
        #expect(String(describing: Version(stringLiteral: "10.1.5-alpha.1")) == "10.1.5-alpha.1")
        #expect(String(describing: Version(stringLiteral: "10.1.5-alpha.1+m1")) == "10.1.5-alpha.1+m1")

        #expect(Version(stringLiteral: "10.1.5").debugDescription == "Version(major: 10, minor: 1, patch: 5)")
        #expect(Version(stringLiteral: "10.1.5-alpha.1").debugDescription == "Version(major: 10, minor: 1, patch: 5, preReleaseIdentifiers: [\"alpha\", \"1\"])")
        #expect(Version(stringLiteral: "10.1.5-alpha.1+m1").debugDescription == "Version(major: 10, minor: 1, patch: 5, preReleaseIdentifiers: [\"alpha\", \"1\"], metadataIdentifiers: [\"m1\"])")
    }
}
