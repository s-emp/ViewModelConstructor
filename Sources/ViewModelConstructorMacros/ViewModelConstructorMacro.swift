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

        // Extract stored properties
        let properties = PropertyExtractor.extractStoredProperties(from: declaration)

        var members: [DeclSyntax] = []

        // 1. Private memberwise init
        members.append(generateMemberwiseInit(properties: properties))

        // 2. makeDefault()
        members.append(generateMakeDefault())

        // 3. propertyDescriptors
        members.append(generatePropertyDescriptors(properties: properties))

        // 4. allPropertyValues
        members.append(generateAllPropertyValues(properties: properties))

        // 5. construct(from:)
        members.append(generateConstruct(properties: properties))

        return members
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Only generate extension for structs with parameterless init
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return []
        }

        let hasParameterlessInit = structDecl.memberBlock.members.contains { member in
            guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
                return false
            }
            return initDecl.signature.parameterClause.parameters.isEmpty
        }

        guard hasParameterlessInit else {
            return []
        }

        let extensionDecl: DeclSyntax =
            "extension \(type.trimmed): ViewModelConstructorCore.ViewModelConstructable {}"
        guard let extensionDeclSyntax = extensionDecl.as(ExtensionDeclSyntax.self) else {
            return []
        }
        return [extensionDeclSyntax]
    }

    // MARK: - Code Generation Helpers

    private static func generateMemberwiseInit(properties: [ExtractedProperty]) -> DeclSyntax {
        let params = properties.map { prop in
            "\(prop.name): \(prop.typeSyntax.trimmedDescription)"
        }.joined(separator: ", ")

        let assignments = properties.map { prop in
            "    self.\(prop.name) = \(prop.name)"
        }.joined(separator: "\n")

        return """
            private init(\(raw: params)) {
            \(raw: assignments)
            }
            """
    }

    private static func generateMakeDefault() -> DeclSyntax {
        return """
            public static func makeDefault() -> Self {
                Self()
            }
            """
    }

    private static func generatePropertyDescriptors(properties: [ExtractedProperty]) -> DeclSyntax {
        let descriptors = properties.map { prop in
            let typeInfoExpr = TypeMapper.typeInfoExpression(for: prop.typeSyntax)
            return
                "    ViewModelConstructorCore.PropertyDescriptor(name: \"\(prop.name)\", typeInfo: \(typeInfoExpr), isOptional: \(prop.isOptional))"
        }.joined(separator: ",\n")

        return """
            public static var propertyDescriptors: [ViewModelConstructorCore.PropertyDescriptor] {
                [
            \(raw: descriptors)
                ]
            }
            """
    }

    private static func generateAllPropertyValues(properties: [ExtractedProperty]) -> DeclSyntax {
        let entries = properties.map { prop in
            if prop.isOptional {
                return "    \"\(prop.name)\": self.\(prop.name) as (any Sendable)?"
            } else {
                return "    \"\(prop.name)\": self.\(prop.name)"
            }
        }.joined(separator: ",\n")

        return """
            public var allPropertyValues: [String: any Sendable] {
                [
            \(raw: entries)
                ]
            }
            """
    }

    private static func generateConstruct(properties: [ExtractedProperty]) -> DeclSyntax {
        let args = properties.map { prop in
            let expr = TypeMapper.constructExpression(propertyName: prop.name, type: prop.typeSyntax)
            return "    \(prop.name): \(expr)"
        }.joined(separator: ",\n")

        return """
            public static func construct(from values: [String: any Sendable]) -> Self {
                Self(
            \(raw: args)
                )
            }
            """
    }
}
