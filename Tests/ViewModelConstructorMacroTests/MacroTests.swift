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
    #if canImport(ViewModelConstructorMacros)
    func testMacroFailsOnClass() throws {
        assertMacroExpansion(
            """
            @ViewModelConstructor
            class MyClass {
                var name: String = ""
                init() {}
            }
            """,
            expandedSource: """
            class MyClass {
                var name: String = ""
                init() {}
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@ViewModelConstructor can only be applied to structs",
                    line: 1,
                    column: 1
                ),
            ],
            macros: testMacros
        )
    }

    func testMacroFailsWithoutParameterlessInit() throws {
        assertMacroExpansion(
            """
            @ViewModelConstructor
            struct MyViewModel {
                var name: String
                init(name: String) {
                    self.name = name
                }
            }
            """,
            expandedSource: """
            struct MyViewModel {
                var name: String
                init(name: String) {
                    self.name = name
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@ViewModelConstructor requires a parameterless init()",
                    line: 1,
                    column: 1
                ),
            ],
            macros: testMacros
        )
    }

    func testBasicTypes() throws {
        assertMacroExpansion(
            """
            @ViewModelConstructor
            struct MyViewModel {
                var name: String
                var age: Int
                var active: Bool
                init() {
                    self.name = ""
                    self.age = 0
                    self.active = false
                }
            }
            """,
            expandedSource: """
            struct MyViewModel {
                var name: String
                var age: Int
                var active: Bool
                init() {
                    self.name = ""
                    self.age = 0
                    self.active = false
                }

                private init(name: String, age: Int, active: Bool) {
                    self.name = name
                    self.age = age
                    self.active = active
                }

                public static func makeDefault() -> Self {
                    Self()
                }

                public static var propertyDescriptors: [ViewModelConstructorCore.PropertyDescriptor] {
                    [
                    ViewModelConstructorCore.PropertyDescriptor(name: "name", typeInfo: .string, isOptional: false),
                    ViewModelConstructorCore.PropertyDescriptor(name: "age", typeInfo: .int, isOptional: false),
                    ViewModelConstructorCore.PropertyDescriptor(name: "active", typeInfo: .bool, isOptional: false)
                    ]
                }

                public var allPropertyValues: [String: any Sendable] {
                    [
                    "name": self.name,
                    "age": self.age,
                    "active": self.active
                    ]
                }

                public static func construct(from values: [String: any Sendable]) -> Self {
                    Self(
                    name: values["name"] as! String,
                    age: values["age"] as! Int,
                    active: values["active"] as! Bool
                    )
                }
            }

            extension MyViewModel: ViewModelConstructorCore.ViewModelConstructable {
            }
            """,
            macros: testMacros
        )
    }

    func testOptionalProperty() throws {
        assertMacroExpansion(
            """
            @ViewModelConstructor
            struct MyViewModel {
                var title: String?
                init() {
                    self.title = nil
                }
            }
            """,
            expandedSource: """
            struct MyViewModel {
                var title: String?
                init() {
                    self.title = nil
                }

                private init(title: String?) {
                    self.title = title
                }

                public static func makeDefault() -> Self {
                    Self()
                }

                public static var propertyDescriptors: [ViewModelConstructorCore.PropertyDescriptor] {
                    [
                    ViewModelConstructorCore.PropertyDescriptor(name: "title", typeInfo: .optional(wrapped: .string), isOptional: true)
                    ]
                }

                public var allPropertyValues: [String: any Sendable] {
                    [
                    "title": self.title as (any Sendable)?
                    ]
                }

                public static func construct(from values: [String: any Sendable]) -> Self {
                    Self(
                    title: values["title"] as? String
                    )
                }
            }

            extension MyViewModel: ViewModelConstructorCore.ViewModelConstructable {
            }
            """,
            macros: testMacros
        )
    }

    func testArrayAndDictionaryProperties() throws {
        assertMacroExpansion(
            """
            @ViewModelConstructor
            struct MyViewModel {
                var tags: [String]
                var scores: [String: Int]
                init() {
                    self.tags = []
                    self.scores = [:]
                }
            }
            """,
            expandedSource: """
            struct MyViewModel {
                var tags: [String]
                var scores: [String: Int]
                init() {
                    self.tags = []
                    self.scores = [:]
                }

                private init(tags: [String], scores: [String: Int]) {
                    self.tags = tags
                    self.scores = scores
                }

                public static func makeDefault() -> Self {
                    Self()
                }

                public static var propertyDescriptors: [ViewModelConstructorCore.PropertyDescriptor] {
                    [
                    ViewModelConstructorCore.PropertyDescriptor(name: "tags", typeInfo: .array(element: .string), isOptional: false),
                    ViewModelConstructorCore.PropertyDescriptor(name: "scores", typeInfo: .dictionary(key: .string, value: .int), isOptional: false)
                    ]
                }

                public var allPropertyValues: [String: any Sendable] {
                    [
                    "tags": self.tags,
                    "scores": self.scores
                    ]
                }

                public static func construct(from values: [String: any Sendable]) -> Self {
                    Self(
                    tags: values["tags"] as! [String],
                    scores: values["scores"] as! [String: Int]
                    )
                }
            }

            extension MyViewModel: ViewModelConstructorCore.ViewModelConstructable {
            }
            """,
            macros: testMacros
        )
    }

    func testCustomType() throws {
        assertMacroExpansion(
            """
            @ViewModelConstructor
            struct MyViewModel {
                var data: MyCustomType
                init() {
                    self.data = MyCustomType()
                }
            }
            """,
            expandedSource: """
            struct MyViewModel {
                var data: MyCustomType
                init() {
                    self.data = MyCustomType()
                }

                private init(data: MyCustomType) {
                    self.data = data
                }

                public static func makeDefault() -> Self {
                    Self()
                }

                public static var propertyDescriptors: [ViewModelConstructorCore.PropertyDescriptor] {
                    [
                    ViewModelConstructorCore.PropertyDescriptor(name: "data", typeInfo: .custom(type: MyCustomType.self), isOptional: false)
                    ]
                }

                public var allPropertyValues: [String: any Sendable] {
                    [
                    "data": self.data
                    ]
                }

                public static func construct(from values: [String: any Sendable]) -> Self {
                    Self(
                    data: values["data"] as! MyCustomType
                    )
                }
            }

            extension MyViewModel: ViewModelConstructorCore.ViewModelConstructable {
            }
            """,
            macros: testMacros
        )
    }

    func testExtensionConformanceGenerated() throws {
        assertMacroExpansion(
            """
            @ViewModelConstructor
            struct SimpleVM {
                var value: Int
                init() {
                    self.value = 0
                }
            }
            """,
            expandedSource: """
            struct SimpleVM {
                var value: Int
                init() {
                    self.value = 0
                }

                private init(value: Int) {
                    self.value = value
                }

                public static func makeDefault() -> Self {
                    Self()
                }

                public static var propertyDescriptors: [ViewModelConstructorCore.PropertyDescriptor] {
                    [
                    ViewModelConstructorCore.PropertyDescriptor(name: "value", typeInfo: .int, isOptional: false)
                    ]
                }

                public var allPropertyValues: [String: any Sendable] {
                    [
                    "value": self.value
                    ]
                }

                public static func construct(from values: [String: any Sendable]) -> Self {
                    Self(
                    value: values["value"] as! Int
                    )
                }
            }

            extension SimpleVM: ViewModelConstructorCore.ViewModelConstructable {
            }
            """,
            macros: testMacros
        )
    }
    #else
    func testMacroDoesNotCrash() throws {
        throw XCTSkip("macros are only supported when running tests for the host platform")
    }
    #endif
}
