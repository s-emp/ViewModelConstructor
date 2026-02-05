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
    #else
    func testMacroDoesNotCrash() throws {
        throw XCTSkip("macros are only supported when running tests for the host platform")
    }
    #endif
}
