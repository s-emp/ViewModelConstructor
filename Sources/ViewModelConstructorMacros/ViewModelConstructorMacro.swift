import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct ViewModelConstructorMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Validate: must be a struct
        guard declaration.is(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(
                node: node,
                message: ViewModelConstructorDiagnostic.notAStruct
            ))
            return []
        }

        let structDecl = declaration.cast(StructDeclSyntax.self)

        // Validate: must have a parameterless init()
        let hasParameterlessInit = structDecl.memberBlock.members.contains { member in
            guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
                return false
            }
            let params = initDecl.signature.parameterClause.parameters
            return params.isEmpty
        }

        guard hasParameterlessInit else {
            context.diagnose(Diagnostic(
                node: node,
                message: ViewModelConstructorDiagnostic.missingParameterlessInit
            ))
            return []
        }

        return []
    }

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
