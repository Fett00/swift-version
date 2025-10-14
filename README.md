# 📦 Version

[![Swift](https://img.shields.io/badge/Swift-5.10-orange?style=flat&logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/Fett00/swift-version)](https://github.com/Fett00/swift-version/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FFett00%2Fswift-version%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Fett00/swift-version)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FFett00%2Fswift-version%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Fett00/swift-version)

`swift-version` is a lightweight Swift library for handling versions that comply with the [Semantic Versioning 2.0.0](https://semver.org/) specification.

---

## ✨ Features
- Full support for `major.minor.patch`
- Pre-release identifiers (`alpha`, `beta`, `rc`, etc.)
- Build metadata (`+build.001`)
- Correct comparison according to SemVer precedence rules
- **`Codable`** support (easy encoding/decoding to JSON)
- **`ExpressibleByStringLiteral`** support (create versions directly from string literals)
- `CustomStringConvertible` & `CustomDebugStringConvertible` for easy debugging
- `Comparable` & `Equatable` conformances

---

## 🚀 Installation

### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/Fett00/swift-version.git", from: "1.0.0")
]
````

---

## 🛠 Usage Examples

### Initialization

```swift
import Version

let v1 = Version(major: 1, minor: 0, patch: 0)
let v2 = Version(major: 1, minor: 2, patch: 3, prereleaseIdentifiers: ["beta"])

print(v1 < v2) // true
print(v2)      // "1.2.3-beta"
```

### ExpressibleByStringLiteral

```swift
let version: Version = "1.4.0-beta.2+exp.sha.5114f85"

print(version.major)                 // 1
print(version.minor)                 // 4
print(version.patch)                 // 0
print(version.prereleaseIdentifiers) // ["beta", "2"]
print(version.metadataIdentifiers)   // ["exp", "sha", "5114f85"]
```

### Codable

```swift
import Foundation

let version: Version = "2.0.0-beta+001"

// Encode to JSON
let data = try JSONEncoder().encode(version)
print(String(data: data, encoding: .utf8)!) // "2.0.0-beta+001"

// Decode from JSON
let decoded = try JSONDecoder().decode(Version.self, from: data)
print(decoded == version) // true
```

### Debugging

```swift
let version: Version = "1.0.0-alpha+exp.42"
print(version)         // "1.0.0-alpha+exp.42"
print(version.debugDescription)
// "Version: major 1, minor 0, patch 0, preReleaseIdentifiers: ["alpha"], metadataIdentifiers: ["exp", "42"]"
```

### Sorting Versions

```swift
import Version

let versions: [Version] = [
    "1.0.0",
    "1.0.0-alpha",
    "1.0.0-beta.2",
    "1.0.0-beta.11",
    "2.0.0",
    "1.9.9"
]

// Sorting uses semantic version precedence rules
let sorted = versions.sorted()
print(sorted.map { $0.stringRepresentation })
```

**Output:**

```
["1.0.0-alpha", "1.0.0-beta.2", "1.0.0-beta.11", "1.0.0", "1.9.9", "2.0.0"]
```

> This example demonstrates that `Version` instances are compared according to the Semantic Versioning specification, including proper handling of pre-release identifiers and numeric comparison.

---

## 📊 Comparison Rules

The library implements the SemVer precedence rules exactly as described in the spec:

| Example A      | Example B       | Result | Reason                                                          |
| -------------- | --------------- | ------ | --------------------------------------------------------------- |
| `1.0.0-alpha`  | `1.0.0`         | `<`    | Pre-release versions have lower precedence than normal versions |
| `1.0.0-alpha`  | `1.0.0-beta`    | `<`    | Alphabetical order of pre-release identifiers                   |
| `1.0.0-beta.2` | `1.0.0-beta.11` | `<`    | Numeric identifiers are compared numerically                    |
| `1.0.0-rc.1`   | `1.0.0`         | `<`    | Pre-release is lower precedence                                 |
| `2.0.0`        | `1.9.9`         | `>`    | Higher major version wins                                       |

---

## 📚 When to use

* Dependency management systems
* Version checks in app updaters
* Database/schema migration tools
* Build/release pipelines

---

## 🛣 Roadmap / Coming Soon

I am continuously improving `Version`. Upcoming features include:

### Version Ranges

Check whether a version falls within a range:

```swift
let range = VersionRange("1.0.0"..<"2.0.0")
range.contains("1.5.3") // true
```

### Operator Overloads

Easily bump versions:

```swift
var v: Version = "1.2.3"
v += .minor
print(v) // "1.3.0"
```

### Semantic Comparison Utilities

Convenient methods to check compatibility or breaking changes:

```swift
v1.isCompatible(with: v2)
v1.hasBreakingChange(comparedTo: v2)
```

### Enhanced String Parsing

Support for more flexible version formats:

* `"v1.2.3"`
* `"1.2.3-rc.1+build.456"`

### Pre-release & Metadata Helpers

Add or modify pre-release and build metadata:

```swift
v.addPrerelease("beta.1")
v.addMetadata("exp.sha.5114f85")
```

### Pretty Printing / Version Formatting

Flexible formatting for logs or UI:

```swift
version.formatted(pretty: true) // "v1.2.3-beta+001"
version.short                   // "1.2.3"
```

### Environment & System Extensions

Convenient helpers to get app and system versions directly

> These features are coming soon to make `Version` even more powerful and convenient for Swift developers.

---

## 🤝 Contributing

Contributions, issues and feature requests are welcome!
Feel free to open a PR or create an issue.

---

## 📄 License

MIT — see the [LICENSE](LICENSE) file.
