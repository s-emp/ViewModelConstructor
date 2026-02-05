# ViewModelConstructor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an SPM package that auto-generates visual component testing UI for UIKit design system components via Swift Macros.

**Architecture:** Three SPM targets — Core (protocols, data models, macro declaration), Macros (Swift Macro plugin for code generation), UI (SwiftUI three-column constructor interface). The macro generates `ViewModelConstructable` conformance with property metadata, the UI uses this metadata to build input controls dynamically.

**Tech Stack:** Swift 6.2, SwiftSyntax 602.x, SwiftUI (constructor UI), UIKit (components), NavigationSplitView (three-column layout)

**Design doc:** `docs/plans/2026-02-05-viewmodel-constructor-design.md`

---

### Task 1: Package Structure and Directory Setup

**Files:**
- Modify: `Package.swift`
- Create: `Sources/ViewModelConstructorCore/` (directory)
- Create: `Sources/ViewModelConstructorMacros/` (directory)
- Create: `Sources/ViewModelConstructorUI/` (directory)
- Delete: `Sources/ViewModelConstructor/ViewModelConstructor.swift`
- Delete: `Tests/ViewModelConstructorTests/ViewModelConstructorTests.swift`

**Step 1: Create directory structure**

```bash
rm -rf Sources/ViewModelConstructor
rm -rf Tests/ViewModelConstructorTests
mkdir -p Sources/ViewModelConstructorCore
mkdir -p Sources/ViewModelConstructorMacros
mkdir -p Sources/ViewModelConstructorUI
mkdir -p Tests/ViewModelConstructorMacroTests
mkdir -p Tests/ViewModelConstructorCoreTests
```

**Step 2: Write Package.swift**

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ViewModelConstructor",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ViewModelConstructorCore",
            targets: ["ViewModelConstructorCore"]
        ),
        .library(
            name: "ViewModelConstructorUI",
            targets: ["ViewModelConstructorUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
    ],
    targets: [
        .target(
            name: "ViewModelConstructorCore",
            dependencies: ["ViewModelConstructorMacros"]
        ),
        .macro(
            name: "ViewModelConstructorMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "ViewModelConstructorUI",
            dependencies: ["ViewModelConstructorCore"]
        ),
        .testTarget(
            name: "ViewModelConstructorMacroTests",
            dependencies: [
                "ViewModelConstructorMacros",
                "ViewModelConstructorCore",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "ViewModelConstructorCoreTests",
            dependencies: ["ViewModelConstructorCore"]
        ),
    ]
)
```

**Step 3: Create placeholder files so the package resolves**

`Sources/ViewModelConstructorCore/ViewModelConfigurable.swift`:
```swift
// ViewModelConstructorCore
```

`Sources/ViewModelConstructorMacros/ViewModelConstructorPlugin.swift`:
```swift
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ViewModelConstructorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = []
}
```

`Sources/ViewModelConstructorUI/ConstructorView.swift`:
```swift
// ViewModelConstructorUI
```

`Tests/ViewModelConstructorMacroTests/MacroTests.swift`:
```swift
import XCTest
```

`Tests/ViewModelConstructorCoreTests/CoreTests.swift`:
```swift
import XCTest
```

**Step 4: Verify package resolves and builds**

Run: `swift build`
Expected: BUILD SUCCEEDED (after resolving swift-syntax)

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: restructure package into Core, Macros, and UI targets"
```

---

### Task 2: Core — Protocols and Data Models

**Files:**
- Create: `Sources/ViewModelConstructorCore/ViewModelConfigurable.swift`
- Create: `Sources/ViewModelConstructorCore/ViewModelConstructable.swift`
- Create: `Sources/ViewModelConstructorCore/PropertyDescriptor.swift`
- Create: `Sources/ViewModelConstructorCore/TypeInfo.swift`
- Create: `Sources/ViewModelConstructorCore/BaseType.swift`
- Create: `Sources/ViewModelConstructorCore/ConstructorCategory.swift`
- Modify: `Tests/ViewModelConstructorCoreTests/CoreTests.swift`

**Step 1: Write tests for core types**

`Tests/ViewModelConstructorCoreTests/CoreTests.swift`:
```swift
import Testing
@testable import ViewModelConstructorCore

@Test func propertyDescriptorStoresMetadata() {
    let descriptor = PropertyDescriptor(
        name: "title",
        typeInfo: .string,
        isOptional: false
    )
    #expect(descriptor.name == "title")
    #expect(descriptor.isOptional == false)
}

@Test func typeInfoIdentifiesBaseTypes() {
    let stringType = TypeInfo.string
    let optionalString = TypeInfo.optional(wrapped: .string)
    let array = TypeInfo.array(element: .int)

    if case .string = stringType {} else {
        Issue.record("Expected .string")
    }
    if case .optional(let wrapped) = optionalString {
        if case .string = wrapped {} else {
            Issue.record("Expected wrapped .string")
        }
    } else {
        Issue.record("Expected .optional")
    }
    if case .array(let element) = array {
        if case .int = element {} else {
            Issue.record("Expected element .int")
        }
    } else {
        Issue.record("Expected .array")
    }
}

@Test func baseTypeCoversAllPrimitives() {
    let allCases: [BaseType] = [.string, .int, .double, .float, .bool, .date, .color]
    #expect(allCases.count == 7)
}
```

**Step 2: Run tests to verify they fail**

Run: `swift test --filter ViewModelConstructorCoreTests`
Expected: FAIL — types not defined yet

**Step 3: Implement core types**

`Sources/ViewModelConstructorCore/ViewModelConfigurable.swift`:
```swift
public protocol ViewModelConfigurable {
    associatedtype ViewModel

    func configure(with viewModel: ViewModel)
}
```

`Sources/ViewModelConstructorCore/ViewModelConstructable.swift`:
```swift
public protocol ViewModelConstructable {
    static func makeDefault() -> Self
    static var propertyDescriptors: [PropertyDescriptor] { get }
    var allPropertyValues: [String: any Sendable] { get }
    static func construct(from values: [String: any Sendable]) -> Self
}
```

`Sources/ViewModelConstructorCore/PropertyDescriptor.swift`:
```swift
public struct PropertyDescriptor: Sendable {
    public let name: String
    public let typeInfo: TypeInfo
    public let isOptional: Bool

    public init(name: String, typeInfo: TypeInfo, isOptional: Bool) {
        self.name = name
        self.typeInfo = typeInfo
        self.isOptional = isOptional
    }
}
```

`Sources/ViewModelConstructorCore/TypeInfo.swift`:
```swift
public enum TypeInfo: Sendable {
    case string
    case int
    case double
    case float
    case bool
    case date
    case color
    case enumType(type: Any.Type, cases: [String])
    case optional(wrapped: TypeInfo)
    case array(element: TypeInfo)
    case dictionary(key: TypeInfo, value: TypeInfo)
    case set(element: TypeInfo)
    case nested(type: any ViewModelConstructable.Type)
    case custom(type: Any.Type)
}
```

Note: `TypeInfo` stores `Any.Type` which is not `Sendable`. Add `@unchecked Sendable` conformance:
```swift
extension TypeInfo: @unchecked Sendable {}
```
Actually, replace the Sendable conformance line — make the enum declaration:
```swift
public enum TypeInfo: @unchecked Sendable {
```

`Sources/ViewModelConstructorCore/BaseType.swift`:
```swift
public enum BaseType: Sendable, CaseIterable {
    case string
    case int
    case double
    case float
    case bool
    case date
    case color
}
```

`Sources/ViewModelConstructorCore/ConstructorCategory.swift`:
```swift
public protocol ConstructorCategory: RawRepresentable, CaseIterable, Hashable, Sendable
    where RawValue == String {}
```

**Step 4: Run tests to verify they pass**

Run: `swift test --filter ViewModelConstructorCoreTests`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add Sources/ViewModelConstructorCore/ Tests/ViewModelConstructorCoreTests/
git commit -m "feat: add core protocols and data models"
```

---

### Task 3: Macro — Plugin Entry Point and Declaration

**Files:**
- Modify: `Sources/ViewModelConstructorMacros/ViewModelConstructorPlugin.swift`
- Create: `Sources/ViewModelConstructorMacros/ViewModelConstructorMacro.swift`
- Create: `Sources/ViewModelConstructorCore/MacroDeclaration.swift`
- Modify: `Tests/ViewModelConstructorMacroTests/MacroTests.swift`

**Step 1: Write a basic macro expansion test**

`Tests/ViewModelConstructorMacroTests/MacroTests.swift`:
```swift
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(ViewModelConstructorMacros)
import ViewModelConstructorMacros

let testMacros: [String: Macro.Type] = [
    "ViewModelConstructor": ViewModelConstructorMacro.self,
]
#endif

final class MacroTests: XCTestCase {

    func testMacroOnStructCompiles() throws {
        #if canImport(ViewModelConstructorMacros)
        assertMacroExpansion(
            """
            @ViewModelConstructor
            struct TestViewModel {
                let title: String

                init() {
                    self.title = "Hello"
                }
            }
            """,
            expandedSource: """
            struct TestViewModel {
                let title: String

                init() {
                    self.title = "Hello"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros not available")
        #endif
    }
}
```

Note: The `expandedSource` will be updated as we add generated code. For now we just verify the macro doesn't crash.

**Step 2: Run tests to verify they fail**

Run: `swift test --filter ViewModelConstructorMacroTests`
Expected: FAIL — `ViewModelConstructorMacro` not defined

**Step 3: Implement macro stub and declaration**

`Sources/ViewModelConstructorMacros/ViewModelConstructorMacro.swift`:
```swift
import SwiftSyntax
import SwiftSyntaxMacros

public struct ViewModelConstructorMacro {}

extension ViewModelConstructorMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}

extension ViewModelConstructorMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        return []
    }
}
```

`Sources/ViewModelConstructorMacros/ViewModelConstructorPlugin.swift`:
```swift
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ViewModelConstructorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ViewModelConstructorMacro.self,
    ]
}
```

`Sources/ViewModelConstructorCore/MacroDeclaration.swift`:
```swift
@attached(member, names: arbitrary)
@attached(extension, conformances: ViewModelConstructable)
public macro ViewModelConstructor() = #externalMacro(
    module: "ViewModelConstructorMacros",
    type: "ViewModelConstructorMacro"
)
```

**Step 4: Run tests to verify they pass**

Run: `swift test --filter ViewModelConstructorMacroTests`
Expected: PASS

**Step 5: Commit**

```bash
git add Sources/ Tests/
git commit -m "feat: add macro plugin entry point and declaration stub"
```

---

### Task 4: Macro — Validation (Struct Check + init Check)

**Files:**
- Modify: `Sources/ViewModelConstructorMacros/ViewModelConstructorMacro.swift`
- Create: `Sources/ViewModelConstructorMacros/Diagnostics.swift`
- Modify: `Tests/ViewModelConstructorMacroTests/MacroTests.swift`

**Step 1: Write validation tests**

Add to `Tests/ViewModelConstructorMacroTests/MacroTests.swift`:
```swift
func testMacroFailsOnClass() throws {
    #if canImport(ViewModelConstructorMacros)
    assertMacroExpansion(
        """
        @ViewModelConstructor
        class NotAStruct {
            init() {}
        }
        """,
        expandedSource: """
        class NotAStruct {
            init() {}
        }
        """,
        diagnostics: [
            DiagnosticSpec(
                message: "@ViewModelConstructor can only be applied to structs",
                line: 1,
                column: 1
            )
        ],
        macros: testMacros
    )
    #else
    throw XCTSkip("macros not available")
    #endif
}

func testMacroFailsWithoutParameterlessInit() throws {
    #if canImport(ViewModelConstructorMacros)
    assertMacroExpansion(
        """
        @ViewModelConstructor
        struct NoInit {
            let title: String
        }
        """,
        expandedSource: """
        struct NoInit {
            let title: String
        }
        """,
        diagnostics: [
            DiagnosticSpec(
                message: "@ViewModelConstructor requires a parameterless init()",
                line: 1,
                column: 1
            )
        ],
        macros: testMacros
    )
    #else
    throw XCTSkip("macros not available")
    #endif
}
```

**Step 2: Run tests to verify they fail**

Run: `swift test --filter ViewModelConstructorMacroTests`
Expected: FAIL — no diagnostics emitted yet

**Step 3: Implement validation**

`Sources/ViewModelConstructorMacros/Diagnostics.swift`:
```swift
import SwiftDiagnostics

enum ViewModelConstructorDiagnostic: String, DiagnosticMessage {
    case notAStruct
    case missingInit

    var severity: DiagnosticSeverity { .error }

    var message: String {
        switch self {
        case .notAStruct:
            return "@ViewModelConstructor can only be applied to structs"
        case .missingInit:
            return "@ViewModelConstructor requires a parameterless init()"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "ViewModelConstructorMacros", id: rawValue)
    }
}
```

Update `ViewModelConstructorMacro.expansion` (MemberMacro):
```swift
public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
) throws -> [DeclSyntax] {
    guard declaration.is(StructDeclSyntax.self) else {
        context.diagnose(Diagnostic(
            node: node,
            message: ViewModelConstructorDiagnostic.notAStruct
        ))
        return []
    }

    let hasParameterlessInit = declaration.memberBlock.members.contains { member in
        guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
            return false
        }
        return initDecl.signature.parameterClause.parameters.isEmpty
    }

    guard hasParameterlessInit else {
        context.diagnose(Diagnostic(
            node: node,
            message: ViewModelConstructorDiagnostic.missingInit
        ))
        return []
    }

    return []
}
```

**Step 4: Run tests to verify they pass**

Run: `swift test --filter ViewModelConstructorMacroTests`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add Sources/ViewModelConstructorMacros/ Tests/ViewModelConstructorMacroTests/
git commit -m "feat: add macro validation for struct and init() presence"
```

---

### Task 5: Macro — Property Extraction and Type Mapping

**Files:**
- Create: `Sources/ViewModelConstructorMacros/PropertyExtractor.swift`
- Create: `Sources/ViewModelConstructorMacros/TypeMapper.swift`
- Modify: `Tests/ViewModelConstructorMacroTests/MacroTests.swift`

**Step 1: Write property extraction tests**

Add to `Tests/ViewModelConstructorMacroTests/MacroTests.swift`:
```swift
func testExtractsStoredProperties() throws {
    #if canImport(ViewModelConstructorMacros)
    assertMacroExpansion(
        """
        @ViewModelConstructor
        struct VM {
            let title: String
            let count: Int
            let isEnabled: Bool

            init() {
                self.title = ""
                self.count = 0
                self.isEnabled = false
            }
        }
        """,
        expandedSource: """
        struct VM {
            let title: String
            let count: Int
            let isEnabled: Bool

            init() {
                self.title = ""
                self.count = 0
                self.isEnabled = false
            }

            private init(title: String, count: Int, isEnabled: Bool) {
                self.title = title
                self.count = count
                self.isEnabled = isEnabled
            }

            public static func makeDefault() -> Self {
                Self()
            }

            public static var propertyDescriptors: [ViewModelConstructorCore.PropertyDescriptor] {
                [
                    .init(name: "title", typeInfo: .string, isOptional: false),
                    .init(name: "count", typeInfo: .int, isOptional: false),
                    .init(name: "isEnabled", typeInfo: .bool, isOptional: false),
                ]
            }

            public var allPropertyValues: [String: any Sendable] {
                var result = [String: any Sendable]()
                result["title"] = self.title
                result["count"] = self.count
                result["isEnabled"] = self.isEnabled
                return result
            }

            public static func construct(from values: [String: any Sendable]) -> Self {
                Self(
                    title: values["title"] as! String,
                    count: values["count"] as! Int,
                    isEnabled: values["isEnabled"] as! Bool
                )
            }
        }
        """,
        macros: testMacros
    )
    #else
    throw XCTSkip("macros not available")
    #endif
}
```

Note: The exact expanded source formatting may need adjustment during implementation — `assertMacroExpansion` is whitespace-sensitive. Adjust as needed to match actual macro output.

**Step 2: Run test to verify it fails**

Run: `swift test --filter ViewModelConstructorMacroTests/testExtractsStoredProperties`
Expected: FAIL — macro generates no members yet

**Step 3: Implement PropertyExtractor**

`Sources/ViewModelConstructorMacros/PropertyExtractor.swift`:
```swift
import SwiftSyntax

struct ExtractedProperty {
    let name: String
    let typeSyntax: TypeSyntax
    let isOptional: Bool
}

enum PropertyExtractor {
    static func extract(from declaration: DeclGroupSyntax) -> [ExtractedProperty] {
        declaration.memberBlock.members.compactMap { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.bindingSpecifier.tokenKind == .keyword(.let) ||
                  varDecl.bindingSpecifier.tokenKind == .keyword(.var),
                  let binding = varDecl.bindings.first,
                  let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation
            else {
                return nil
            }

            // Skip computed properties (have accessor block with get/set)
            if let accessor = binding.accessorBlock {
                // If it has explicit get/set, it's computed
                if case .accessors = accessor.accessors {
                    return nil
                }
            }

            let typeSyntax = typeAnnotation.type
            let isOptional = typeSyntax.is(OptionalTypeSyntax.self)
                || typeSyntax.description.hasSuffix("?")

            return ExtractedProperty(
                name: pattern.identifier.text,
                typeSyntax: typeSyntax,
                isOptional: isOptional
            )
        }
    }
}
```

**Step 4: Implement TypeMapper**

`Sources/ViewModelConstructorMacros/TypeMapper.swift`:
```swift
import SwiftSyntax

enum TypeMapper {
    /// Returns the TypeInfo expression string for a given type syntax
    static func typeInfoExpression(for type: TypeSyntax) -> String {
        let trimmed = type.trimmedDescription

        // Optional<T> or T?
        if let optional = type.as(OptionalTypeSyntax.self) {
            let wrapped = typeInfoExpression(for: optional.wrappedType)
            return ".optional(wrapped: \(wrapped))"
        }

        // [T] — Array
        if let array = type.as(ArrayTypeSyntax.self) {
            let element = typeInfoExpression(for: array.element)
            return ".array(element: \(element))"
        }

        // [K: V] — Dictionary
        if let dict = type.as(DictionaryTypeSyntax.self) {
            let key = typeInfoExpression(for: dict.key)
            let value = typeInfoExpression(for: dict.value)
            return ".dictionary(key: \(key), value: \(value))"
        }

        // Generic types like Set<T>, Optional<T>, Array<T>, Dictionary<K,V>
        if let identifierType = type.as(IdentifierTypeSyntax.self),
           let genericArgs = identifierType.genericArgumentClause {
            let name = identifierType.name.text
            let args = genericArgs.arguments.map { $0.argument }

            switch name {
            case "Optional" where args.count == 1:
                let wrapped = typeInfoExpression(for: args[0])
                return ".optional(wrapped: \(wrapped))"
            case "Array" where args.count == 1:
                let element = typeInfoExpression(for: args[0])
                return ".array(element: \(element))"
            case "Set" where args.count == 1:
                let element = typeInfoExpression(for: args[0])
                return ".set(element: \(element))"
            case "Dictionary" where args.count == 2:
                let key = typeInfoExpression(for: args[0])
                let value = typeInfoExpression(for: args[1])
                return ".dictionary(key: \(key), value: \(value))"
            default:
                return ".custom(type: \(trimmed).self)"
            }
        }

        // Simple identifier types
        switch trimmed {
        case "String": return ".string"
        case "Int": return ".int"
        case "Double": return ".double"
        case "Float": return ".float"
        case "Bool": return ".bool"
        case "Date": return ".date"
        case "UIColor", "Color": return ".color"
        default:
            return ".custom(type: \(trimmed).self)"
        }
    }

    /// Returns the cast expression for construct(from:)
    static func constructExpression(propertyName: String, type: TypeSyntax) -> String {
        let trimmed = type.trimmedDescription

        if type.is(OptionalTypeSyntax.self) {
            // For T?, use as? T
            let wrappedType = type.as(OptionalTypeSyntax.self)!.wrappedType.trimmedDescription
            return "values[\"\(propertyName)\"] as? \(wrappedType)"
        }

        return "values[\"\(propertyName)\"] as! \(trimmed)"
    }
}
```

**Step 5: Run tests — they may still fail because we haven't wired generation into the macro yet**

Continue to Task 6 for wiring.

**Step 6: Commit extraction and mapping utilities**

```bash
git add Sources/ViewModelConstructorMacros/ Tests/ViewModelConstructorMacroTests/
git commit -m "feat: add property extraction and type mapping for macro"
```

---

### Task 6: Macro — Full Code Generation

**Files:**
- Modify: `Sources/ViewModelConstructorMacros/ViewModelConstructorMacro.swift`
- Modify: `Tests/ViewModelConstructorMacroTests/MacroTests.swift`

**Step 1: Update MemberMacro expansion to generate all members**

Replace the `MemberMacro.expansion` body in `ViewModelConstructorMacro.swift`:

```swift
public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
) throws -> [DeclSyntax] {
    guard declaration.is(StructDeclSyntax.self) else {
        context.diagnose(Diagnostic(
            node: node,
            message: ViewModelConstructorDiagnostic.notAStruct
        ))
        return []
    }

    let hasParameterlessInit = declaration.memberBlock.members.contains { member in
        guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
            return false
        }
        return initDecl.signature.parameterClause.parameters.isEmpty
    }

    guard hasParameterlessInit else {
        context.diagnose(Diagnostic(
            node: node,
            message: ViewModelConstructorDiagnostic.missingInit
        ))
        return []
    }

    let properties = PropertyExtractor.extract(from: declaration)

    guard !properties.isEmpty else {
        return []
    }

    var members: [DeclSyntax] = []

    // 1. Private memberwise init
    let initParams = properties.map { "\($0.name): \($0.typeSyntax.trimmedDescription)" }.joined(separator: ", ")
    let initAssignments = properties.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n        ")
    members.append("""
        private init(\(raw: initParams)) {
            \(raw: initAssignments)
        }
        """ as DeclSyntax)

    // 2. makeDefault()
    members.append("""
        public static func makeDefault() -> Self {
            Self()
        }
        """ as DeclSyntax)

    // 3. propertyDescriptors
    let descriptorEntries = properties.map { prop in
        let typeExpr = TypeMapper.typeInfoExpression(for: prop.typeSyntax)
        return ".init(name: \"\(prop.name)\", typeInfo: \(typeExpr), isOptional: \(prop.isOptional))"
    }.joined(separator: ",\n            ")

    members.append("""
        public static var propertyDescriptors: [ViewModelConstructorCore.PropertyDescriptor] {
            [
                \(raw: descriptorEntries),
            ]
        }
        """ as DeclSyntax)

    // 4. allPropertyValues
    let valueEntries = properties.map { prop in
        "result[\"\(prop.name)\"] = self.\(prop.name)"
    }.joined(separator: "\n        ")

    members.append("""
        public var allPropertyValues: [String: any Sendable] {
            var result = [String: any Sendable]()
            \(raw: valueEntries)
            return result
        }
        """ as DeclSyntax)

    // 5. construct(from:)
    let constructParams = properties.map { prop in
        "\(prop.name): \(TypeMapper.constructExpression(propertyName: prop.name, type: prop.typeSyntax))"
    }.joined(separator: ",\n            ")

    members.append("""
        public static func construct(from values: [String: any Sendable]) -> Self {
            Self(
                \(raw: constructParams)
            )
        }
        """ as DeclSyntax)

    return members
}
```

**Step 2: Update ExtensionMacro expansion to add ViewModelConstructable conformance**

```swift
extension ViewModelConstructorMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard declaration.is(StructDeclSyntax.self) else {
            return []
        }

        let ext: DeclSyntax = """
            extension \(type.trimmed): ViewModelConstructorCore.ViewModelConstructable {}
            """

        return [ext.cast(ExtensionDeclSyntax.self)]
    }
}
```

**Step 3: Run tests**

Run: `swift test --filter ViewModelConstructorMacroTests`
Expected: Tests pass (adjust expanded source whitespace if needed)

**Step 4: Add more comprehensive tests**

Add to `MacroTests.swift`:
```swift
func testOptionalProperty() throws {
    #if canImport(ViewModelConstructorMacros)
    // Test that optional properties generate correct typeInfo and construct expressions
    assertMacroExpansion(
        """
        @ViewModelConstructor
        struct VM {
            let subtitle: String?

            init() {
                self.subtitle = nil
            }
        }
        """,
        expandedSource: /* verify .optional(wrapped: .string) and `as? String` */,
        macros: testMacros
    )
    #else
    throw XCTSkip("macros not available")
    #endif
}

func testArrayAndDictionaryProperties() throws {
    #if canImport(ViewModelConstructorMacros)
    assertMacroExpansion(
        """
        @ViewModelConstructor
        struct VM {
            let items: [String]
            let map: [String: Int]

            init() {
                self.items = []
                self.map = [:]
            }
        }
        """,
        expandedSource: /* verify .array(element: .string) and .dictionary(key: .string, value: .int) */,
        macros: testMacros
    )
    #else
    throw XCTSkip("macros not available")
    #endif
}

func testCustomTypeProperty() throws {
    #if canImport(ViewModelConstructorMacros)
    assertMacroExpansion(
        """
        @ViewModelConstructor
        struct VM {
            let mode: DisplayMode

            init() {
                self.mode = .compact
            }
        }
        """,
        expandedSource: /* verify .custom(type: DisplayMode.self) */,
        macros: testMacros
    )
    #else
    throw XCTSkip("macros not available")
    #endif
}
```

Fill in exact `expandedSource` strings during implementation by running the macro and capturing output.

**Step 5: Run all tests**

Run: `swift test --filter ViewModelConstructorMacroTests`
Expected: All PASS

**Step 6: Commit**

```bash
git add Sources/ViewModelConstructorMacros/ Tests/ViewModelConstructorMacroTests/
git commit -m "feat: implement full ViewModelConstructable code generation in macro"
```

---

### Task 7: UI — Component Registry and Store

**Files:**
- Create: `Sources/ViewModelConstructorUI/ComponentRegistration.swift`
- Create: `Sources/ViewModelConstructorUI/ConstructorStore.swift`

**Step 1: Implement ComponentRegistration**

`Sources/ViewModelConstructorUI/ComponentRegistration.swift`:
```swift
import UIKit
import ViewModelConstructorCore

public struct ComponentRegistration: Identifiable, @unchecked Sendable {
    public let id = UUID()
    public let name: String
    public let categoryRawValue: String
    public let propertyDescriptors: [PropertyDescriptor]

    let createView: @MainActor () -> UIView
    let createDefaultViewModel: () -> any Sendable
    let allPropertyValues: (any Sendable) -> [String: any Sendable]
    let constructFromValues: ([String: any Sendable]) -> any Sendable
    let configureView: @MainActor (UIView, any Sendable) -> Void
}
```

**Step 2: Implement ConstructorStore**

`Sources/ViewModelConstructorUI/ConstructorStore.swift`:
```swift
import SwiftUI
import ViewModelConstructorCore

@MainActor
@Observable
public final class ConstructorStore<Category: ConstructorCategory> {

    public private(set) var registrations: [ComponentRegistration] = []
    public var selectedRegistration: ComponentRegistration?
    public var currentValues: [String: any Sendable] = [:]
    public var previewBackgroundColor: Color = Color(uiColor: .systemBackground)
    public var showBorder: Bool = false

    // Custom input overrides
    var baseTypeOverrides: [BaseType: any CustomInputProvider] = [:]
    var customTypeInputs: [ObjectIdentifier: any CustomInputProvider] = [:]
    var unsupportedTypeViewProvider: (any UnsupportedTypeViewProvider)?

    public init() {}

    public func register<V: UIView & ViewModelConfigurable, VM: ViewModelConstructable>(
        component: V.Type,
        viewModel: VM.Type,
        category: Category
    ) where V.ViewModel == VM {
        let registration = ComponentRegistration(
            name: String(describing: V.self),
            categoryRawValue: category.rawValue,
            propertyDescriptors: VM.propertyDescriptors,
            createView: { V() },
            createDefaultViewModel: { VM.makeDefault() },
            allPropertyValues: { vm in (vm as! VM).allPropertyValues },
            constructFromValues: { values in VM.construct(from: values) },
            configureView: { view, vm in (view as! V).configure(with: vm as! VM) }
        )
        registrations.append(registration)
    }

    public func select(_ registration: ComponentRegistration) {
        selectedRegistration = registration
        let defaultVM = registration.createDefaultViewModel()
        currentValues = registration.allPropertyValues(defaultVM)
    }

    public func resetToDefaults() {
        guard let reg = selectedRegistration else { return }
        let defaultVM = reg.createDefaultViewModel()
        currentValues = reg.allPropertyValues(defaultVM)
    }

    public func buildCurrentViewModel() -> (any Sendable)? {
        guard let reg = selectedRegistration else { return nil }
        return reg.constructFromValues(currentValues)
    }

    public var categorizedRegistrations: [(category: String, components: [ComponentRegistration])] {
        let grouped = Dictionary(grouping: registrations) { $0.categoryRawValue }
        return Category.allCases.compactMap { category in
            guard let components = grouped[category.rawValue], !components.isEmpty else {
                return nil
            }
            return (category: category.rawValue, components: components)
        }
    }
}
```

**Step 3: Add protocol stubs for custom inputs**

Add to `Sources/ViewModelConstructorUI/ConstructorStore.swift` (or separate file):
```swift
public protocol CustomInputProvider {
    var inputViewType: Any.Type { get }
}

public protocol UnsupportedTypeViewProvider {
    var viewType: Any.Type { get }
}
```

Note: These protocols will be refined in Task 8 when we implement the actual input views.

**Step 4: Verify it builds**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add Sources/ViewModelConstructorUI/
git commit -m "feat: add component registry and constructor store"
```

---

### Task 8: UI — Built-in Input Controls

**Files:**
- Create: `Sources/ViewModelConstructorUI/Inputs/StringInputView.swift`
- Create: `Sources/ViewModelConstructorUI/Inputs/NumberInputView.swift`
- Create: `Sources/ViewModelConstructorUI/Inputs/BoolInputView.swift`
- Create: `Sources/ViewModelConstructorUI/Inputs/DateInputView.swift`
- Create: `Sources/ViewModelConstructorUI/Inputs/ColorInputView.swift`
- Create: `Sources/ViewModelConstructorUI/Inputs/EnumInputView.swift`
- Create: `Sources/ViewModelConstructorUI/Inputs/OptionalInputView.swift`
- Create: `Sources/ViewModelConstructorUI/Inputs/ArrayInputView.swift`
- Create: `Sources/ViewModelConstructorUI/Inputs/PropertyInputFactory.swift`

**Step 1: Create PropertyInputFactory — the central dispatcher**

`Sources/ViewModelConstructorUI/Inputs/PropertyInputFactory.swift`:
```swift
import SwiftUI
import ViewModelConstructorCore

struct PropertyInputFactory {

    @ViewBuilder
    static func makeInputView(
        for descriptor: PropertyDescriptor,
        value: Binding<any Sendable>,
        store: (any Sendable)? = nil
    ) -> some View {
        switch descriptor.typeInfo {
        case .string:
            StringInputView(label: descriptor.name, value: value)
        case .int:
            IntInputView(label: descriptor.name, value: value)
        case .double:
            DoubleInputView(label: descriptor.name, value: value)
        case .float:
            FloatInputView(label: descriptor.name, value: value)
        case .bool:
            BoolInputView(label: descriptor.name, value: value)
        case .date:
            DateInputView(label: descriptor.name, value: value)
        case .color:
            ColorInputView(label: descriptor.name, value: value)
        case .enumType(_, let cases):
            EnumInputView(label: descriptor.name, cases: cases, value: value)
        case .optional(let wrapped):
            OptionalInputView(
                label: descriptor.name,
                wrappedTypeInfo: wrapped,
                value: value
            )
        case .array(let element):
            ArrayInputView(label: descriptor.name, elementTypeInfo: element, value: value)
        case .nested, .custom, .dictionary, .set:
            // Placeholder — will be expanded
            UnsupportedTypeInputView(label: descriptor.name, typeName: "\(descriptor.typeInfo)")
        }
    }
}
```

**Step 2: Implement individual input views**

Each input view follows the pattern:

`Sources/ViewModelConstructorUI/Inputs/StringInputView.swift`:
```swift
import SwiftUI

struct StringInputView: View {
    let label: String
    @Binding var value: any Sendable

    var body: some View {
        let stringBinding = Binding<String>(
            get: { value as? String ?? "" },
            set: { value = $0 }
        )
        TextField(label, text: stringBinding)
    }
}
```

`Sources/ViewModelConstructorUI/Inputs/BoolInputView.swift`:
```swift
import SwiftUI

struct BoolInputView: View {
    let label: String
    @Binding var value: any Sendable

    var body: some View {
        let boolBinding = Binding<Bool>(
            get: { value as? Bool ?? false },
            set: { value = $0 }
        )
        Toggle(label, isOn: boolBinding)
    }
}
```

Follow the same pattern for `IntInputView` (TextField with .numberPad + Stepper), `DoubleInputView`, `FloatInputView`, `DateInputView` (DatePicker), `ColorInputView` (ColorPicker).

`Sources/ViewModelConstructorUI/Inputs/EnumInputView.swift`:
```swift
import SwiftUI

struct EnumInputView: View {
    let label: String
    let cases: [String]
    @Binding var value: any Sendable

    var body: some View {
        let selectedBinding = Binding<String>(
            get: { String(describing: value) },
            set: { newCase in
                // Enum reconstruction handled via store
                value = newCase
            }
        )
        Picker(label, selection: selectedBinding) {
            ForEach(cases, id: \.self) { caseName in
                Text(caseName).tag(caseName)
            }
        }
    }
}
```

Note: Enum handling is complex due to type erasure. The exact implementation may need refinement — the macro could generate a `construct(fromCaseName:)` helper. Implement the simplest version first and iterate.

`Sources/ViewModelConstructorUI/Inputs/OptionalInputView.swift`:
```swift
import SwiftUI
import ViewModelConstructorCore

struct OptionalInputView: View {
    let label: String
    let wrappedTypeInfo: TypeInfo
    @Binding var value: any Sendable

    @State private var isNil: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            Toggle("\(label) (optional)", isOn: Binding(
                get: { !isNil },
                set: { hasValue in
                    isNil = !hasValue
                    if !hasValue {
                        value = Optional<Any>.none as Any
                    }
                }
            ))

            if !isNil {
                let wrappedDescriptor = PropertyDescriptor(
                    name: label,
                    typeInfo: wrappedTypeInfo,
                    isOptional: false
                )
                PropertyInputFactory.makeInputView(
                    for: wrappedDescriptor,
                    value: $value
                )
            }
        }
        .onAppear {
            // Check if current value is nil
            if case Optional<Any>.none = value {
                isNil = true
            } else {
                isNil = false
            }
        }
    }
}
```

Create `UnsupportedTypeInputView.swift` as a simple placeholder:
```swift
import SwiftUI

struct UnsupportedTypeInputView: View {
    let label: String
    let typeName: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Label("Unsupported: \(typeName)", systemImage: "exclamationmark.triangle")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}
```

**Step 3: Verify it builds**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add Sources/ViewModelConstructorUI/Inputs/
git commit -m "feat: add built-in input controls for base types"
```

---

### Task 9: UI — Inspector Column (Column 3)

**Files:**
- Create: `Sources/ViewModelConstructorUI/Views/InspectorView.swift`

**Step 1: Implement InspectorView with NavigationStack**

`Sources/ViewModelConstructorUI/Views/InspectorView.swift`:
```swift
import SwiftUI
import ViewModelConstructorCore

struct InspectorView<Category: ConstructorCategory>: View {
    @Bindable var store: ConstructorStore<Category>

    var body: some View {
        NavigationStack {
            if let registration = store.selectedRegistration {
                PropertyListView(
                    descriptors: registration.propertyDescriptors,
                    values: $store.currentValues,
                    title: registration.name
                )
            } else {
                ContentUnavailableView(
                    "No Component Selected",
                    systemImage: "sidebar.left",
                    description: Text("Select a component from the sidebar")
                )
            }
        }
    }
}

struct PropertyListView: View {
    let descriptors: [PropertyDescriptor]
    @Binding var values: [String: any Sendable]
    let title: String

    var body: some View {
        Form {
            ForEach(descriptors, id: \.name) { descriptor in
                let binding = Binding<any Sendable>(
                    get: { values[descriptor.name] ?? "" as any Sendable },
                    set: { values[descriptor.name] = $0 }
                )

                switch descriptor.typeInfo {
                case .nested:
                    NavigationLink(descriptor.name) {
                        // Push nested type's properties
                        NestedPropertyView(
                            descriptor: descriptor,
                            parentValues: $values
                        )
                    }
                default:
                    PropertyInputFactory.makeInputView(
                        for: descriptor,
                        value: binding
                    )
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Reset") {
                    // Handled by parent via store.resetToDefaults()
                }
            }
        }
    }
}
```

Note: `NestedPropertyView` handles push navigation for nested `ViewModelConstructable` types. It extracts the nested ViewModel's property descriptors and values, displays them, and writes changes back to the parent's values dictionary. Implementation details will be refined during development.

**Step 2: Verify it builds**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Sources/ViewModelConstructorUI/Views/
git commit -m "feat: add inspector view with NavigationStack for ViewModel controls"
```

---

### Task 10: UI — Preview Column (Column 2)

**Files:**
- Create: `Sources/ViewModelConstructorUI/Views/PreviewView.swift`
- Create: `Sources/ViewModelConstructorUI/Views/ComponentPreviewRepresentable.swift`
- Create: `Sources/ViewModelConstructorUI/Views/DeviceFrameView.swift`

**Step 1: Implement UIViewRepresentable wrapper**

`Sources/ViewModelConstructorUI/Views/ComponentPreviewRepresentable.swift`:
```swift
import SwiftUI
import UIKit

struct ComponentPreviewRepresentable: UIViewRepresentable {
    let registration: ComponentRegistration
    let viewModel: any Sendable
    let showBorder: Bool
    let updateTrigger: UUID  // changes to force re-creation

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let component = registration.createView()
        component.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(component)
        NSLayoutConstraint.activate([
            component.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            component.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            component.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            component.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
        ])
        registration.configureView(component, viewModel)
        context.coordinator.componentView = component
        return container
    }

    func updateUIView(_ container: UIView, context: Context) {
        if let component = context.coordinator.componentView {
            registration.configureView(component, viewModel)
            component.layer.borderWidth = showBorder ? 1 : 0
            component.layer.borderColor = UIColor.systemRed.cgColor
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var componentView: UIView?
    }
}
```

**Step 2: Implement DeviceFrameView**

`Sources/ViewModelConstructorUI/Views/DeviceFrameView.swift`:
```swift
import SwiftUI

enum DeviceSize: String, CaseIterable, Identifiable {
    case iPhoneSE = "iPhone SE"
    case iPhone15 = "iPhone 15"
    case iPhone15ProMax = "iPhone 15 Pro Max"

    var id: String { rawValue }

    var size: CGSize {
        switch self {
        case .iPhoneSE: return CGSize(width: 375, height: 667)
        case .iPhone15: return CGSize(width: 393, height: 852)
        case .iPhone15ProMax: return CGSize(width: 430, height: 932)
        }
    }
}

struct DeviceFrameView: View {
    let deviceSize: DeviceSize

    var body: some View {
        RoundedRectangle(cornerRadius: 48)
            .stroke(Color.secondary.opacity(0.5), lineWidth: 4)
            .frame(width: deviceSize.size.width * 0.5, height: deviceSize.size.height * 0.5)
            .overlay(
                RoundedRectangle(cornerRadius: 44)
                    .fill(Color.clear)
                    .padding(4)
            )
    }
}
```

**Step 3: Implement PreviewView**

`Sources/ViewModelConstructorUI/Views/PreviewView.swift`:
```swift
import SwiftUI

struct PreviewView<Category: ConstructorCategory>: View {
    @Bindable var store: ConstructorStore<Category>
    @State private var selectedDevice: DeviceSize = .iPhone15
    @State private var updateTrigger = UUID()

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                ColorPicker("Background", selection: $store.previewBackgroundColor)
                    .labelsHidden()
                    .frame(width: 40)

                Toggle("Border", isOn: $store.showBorder)
                    .fixedSize()

                Button {
                    updateTrigger = UUID()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh component")

                Spacer()

                Picker("Device", selection: $selectedDevice) {
                    ForEach(DeviceSize.allCases) { device in
                        Text(device.rawValue).tag(device)
                    }
                }
                .fixedSize()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Preview area
            if let registration = store.selectedRegistration,
               let viewModel = store.buildCurrentViewModel() {
                ScrollView {
                    ZStack {
                        // Device frame
                        RoundedRectangle(cornerRadius: 48)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 4)

                        // Component inside
                        ComponentPreviewRepresentable(
                            registration: registration,
                            viewModel: viewModel,
                            showBorder: store.showBorder,
                            updateTrigger: updateTrigger
                        )
                        .background(store.previewBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 44))
                        .padding(4)
                    }
                    .frame(
                        width: selectedDevice.size.width * 0.5,
                        height: selectedDevice.size.height * 0.5
                    )
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView(
                    "No Preview",
                    systemImage: "eye.slash",
                    description: Text("Select a component to preview")
                )
            }
        }
    }
}
```

**Step 4: Verify it builds**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add Sources/ViewModelConstructorUI/Views/
git commit -m "feat: add preview column with device frame and toolbar"
```

---

### Task 11: UI — Sidebar Column (Column 1)

**Files:**
- Create: `Sources/ViewModelConstructorUI/Views/SidebarView.swift`

**Step 1: Implement SidebarView**

`Sources/ViewModelConstructorUI/Views/SidebarView.swift`:
```swift
import SwiftUI

struct SidebarView<Category: ConstructorCategory>: View {
    @Bindable var store: ConstructorStore<Category>
    @State private var searchText = ""

    var body: some View {
        List(selection: Binding(
            get: { store.selectedRegistration?.id },
            set: { id in
                if let id, let reg = store.registrations.first(where: { $0.id == id }) {
                    store.select(reg)
                }
            }
        )) {
            ForEach(filteredCategories, id: \.category) { group in
                Section(group.category) {
                    ForEach(group.components) { registration in
                        Text(registration.name)
                            .tag(registration.id)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search components")
        .navigationTitle("Components")
    }

    private var filteredCategories: [(category: String, components: [ComponentRegistration])] {
        let all = store.categorizedRegistrations
        guard !searchText.isEmpty else { return all }
        return all.compactMap { group in
            let filtered = group.components.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            guard !filtered.isEmpty else { return nil }
            return (category: group.category, components: filtered)
        }
    }
}
```

**Step 2: Verify it builds**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Sources/ViewModelConstructorUI/Views/SidebarView.swift
git commit -m "feat: add sidebar with categories and search"
```

---

### Task 12: UI — ConstructorView Assembly

**Files:**
- Modify: `Sources/ViewModelConstructorUI/ConstructorView.swift`

**Step 1: Implement the three-column ConstructorView**

`Sources/ViewModelConstructorUI/ConstructorView.swift`:
```swift
import SwiftUI
import ViewModelConstructorCore

public struct ConstructorView<Category: ConstructorCategory>: View {

    @State private var store: ConstructorStore<Category>

    public init() {
        self._store = State(initialValue: ConstructorStore<Category>())
    }

    public var body: some View {
        NavigationSplitView {
            SidebarView(store: store)
        } content: {
            PreviewView(store: store)
        } detail: {
            InspectorView(store: store)
        }
    }

    // MARK: - Public API

    @discardableResult
    public func register<V: UIView & ViewModelConfigurable, VM: ViewModelConstructable>(
        component: V.Type,
        viewModel: VM.Type,
        category: Category
    ) -> Self where V.ViewModel == VM {
        store.register(component: component, viewModel: viewModel, category: category)
        return self
    }

    public func override(inputFor baseType: BaseType, with viewType: Any.Type) -> Self {
        // Store override — will be wired to PropertyInputFactory
        return self
    }

    public func register(customInput viewType: Any.Type, for customType: Any.Type) -> Self {
        // Store custom input — will be wired to PropertyInputFactory
        return self
    }

    public func setUnsupportedTypeView(_ viewType: Any.Type) -> Self {
        // Store fallback view
        return self
    }
}
```

Note: The builder-style API (`register`, `override`, etc.) mutates the internal store. Since `ConstructorView` is a SwiftUI View, the chaining pattern needs to work with `@State`. An alternative is to have the user configure the store directly and pass it in. Adjust during implementation if the SwiftUI View chaining pattern causes issues — consider using a separate `ConstructorConfiguration` object:

```swift
let config = ConstructorConfiguration<Category>()
config.register(component: ..., viewModel: ..., category: ...)
ConstructorView(configuration: config)
```

This may be cleaner for SwiftUI. Decide during implementation.

**Step 2: Verify it builds**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Sources/ViewModelConstructorUI/
git commit -m "feat: assemble three-column ConstructorView with NavigationSplitView"
```

---

### Task 13: Integration Test — End to End

**Files:**
- Create: `Tests/ViewModelConstructorCoreTests/IntegrationTests.swift`

**Step 1: Write an integration test that uses the macro and core types together**

```swift
import Testing
@testable import ViewModelConstructorCore

// A test ViewModel using the macro
@ViewModelConstructor
struct SampleViewModel {
    let title: String
    let count: Int
    let isEnabled: Bool
    let subtitle: String?

    init() {
        self.title = "Hello"
        self.count = 42
        self.isEnabled = true
        self.subtitle = nil
    }
}

@Test func macroGeneratesViewModelConstructableConformance() {
    let vm = SampleViewModel.makeDefault()
    #expect(vm.title == "Hello")
    #expect(vm.count == 42)
    #expect(vm.isEnabled == true)
    #expect(vm.subtitle == nil)
}

@Test func propertyDescriptorsAreCorrect() {
    let descriptors = SampleViewModel.propertyDescriptors
    #expect(descriptors.count == 4)
    #expect(descriptors[0].name == "title")
    #expect(descriptors[1].name == "count")
    #expect(descriptors[2].name == "isEnabled")
    #expect(descriptors[3].name == "subtitle")
    #expect(descriptors[3].isOptional == true)
}

@Test func allPropertyValuesExtractsCorrectly() {
    let vm = SampleViewModel.makeDefault()
    let values = vm.allPropertyValues
    #expect(values["title"] as? String == "Hello")
    #expect(values["count"] as? Int == 42)
    #expect(values["isEnabled"] as? Bool == true)
}

@Test func constructFromValuesCreatesNewInstance() {
    let vm = SampleViewModel.makeDefault()
    var values = vm.allPropertyValues
    values["title"] = "World"
    values["count"] = 99

    let newVM = SampleViewModel.construct(from: values)
    #expect(newVM.title == "World")
    #expect(newVM.count == 99)
    #expect(newVM.isEnabled == true) // unchanged
}

@Test func roundTripPreservesValues() {
    let original = SampleViewModel.makeDefault()
    let values = original.allPropertyValues
    let reconstructed = SampleViewModel.construct(from: values)
    #expect(reconstructed.title == original.title)
    #expect(reconstructed.count == original.count)
    #expect(reconstructed.isEnabled == original.isEnabled)
    #expect(reconstructed.subtitle == original.subtitle)
}
```

**Step 2: Run integration tests**

Run: `swift test --filter ViewModelConstructorCoreTests`
Expected: All PASS

**Step 3: Run all tests**

Run: `swift test`
Expected: All tests across all targets PASS

**Step 4: Commit**

```bash
git add Tests/
git commit -m "test: add integration tests for macro + core round-trip"
```

---

## Summary of Tasks

| # | Task | Key deliverable |
|---|---|---|
| 1 | Package structure | Three-target SPM layout with swift-syntax |
| 2 | Core protocols & models | ViewModelConfigurable, ViewModelConstructable, TypeInfo, etc. |
| 3 | Macro scaffolding | Plugin entry point, macro declaration, test infra |
| 4 | Macro validation | Struct check, init() check, diagnostics |
| 5 | Property extraction | PropertyExtractor + TypeMapper utilities |
| 6 | Macro code generation | Full ViewModelConstructable conformance generation |
| 7 | UI registry & store | ComponentRegistration, ConstructorStore |
| 8 | Built-in input controls | String, Int, Bool, Date, Color, Enum, Optional, Array inputs |
| 9 | Inspector column | Column 3 — NavigationStack with property controls |
| 10 | Preview column | Column 2 — UIViewRepresentable + device frame + toolbar |
| 11 | Sidebar column | Column 1 — categories + search |
| 12 | ConstructorView assembly | Three-column NavigationSplitView |
| 13 | Integration test | End-to-end macro → core → construct round-trip |
