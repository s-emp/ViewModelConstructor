import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ViewModelConstructorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = []
}
