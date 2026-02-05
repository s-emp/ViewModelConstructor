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
    func testMacroDoesNotCrash() throws {
        assertMacroExpansion(
            """
            @ViewModelConstructor
            struct MyViewModel {
                var name: String
                var age: Int
                init() {
                    self.name = ""
                    self.age = 0
                }
            }
            """,
            expandedSource: """
            struct MyViewModel {
                var name: String
                var age: Int
                init() {
                    self.name = ""
                    self.age = 0
                }
            }
            """,
            macros: testMacros
        )
    }

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
    #else
    func testMacroDoesNotCrash() throws {
        throw XCTSkip("macros are only supported when running tests for the host platform")
    }
    #endif
}
