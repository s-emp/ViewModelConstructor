import SwiftSyntax

struct ExtractedProperty {
    let name: String
    let typeSyntax: TypeSyntax
    let isOptional: Bool
}

enum PropertyExtractor {
    static func extractStoredProperties(from declaration: DeclGroupSyntax) -> [ExtractedProperty] {
        var properties: [ExtractedProperty] = []

        for member in declaration.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }

            for binding in varDecl.bindings {
                // Skip computed properties (those with accessor blocks containing get/set)
                if let accessorBlock = binding.accessorBlock {
                    if case .accessors(let accessors) = accessorBlock.accessors {
                        let hasGetOrSet = accessors.contains { accessor in
                            accessor.accessorSpecifier.tokenKind == .keyword(.get)
                                || accessor.accessorSpecifier.tokenKind == .keyword(.set)
                        }
                        if hasGetOrSet {
                            continue
                        }
                    }
                }

                guard let typeAnnotation = binding.typeAnnotation,
                    let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
                else {
                    continue
                }

                let typeSyntax = typeAnnotation.type
                let isOptional =
                    typeSyntax.is(OptionalTypeSyntax.self)
                    || (typeSyntax.as(IdentifierTypeSyntax.self)?.name.text == "Optional")

                properties.append(ExtractedProperty(
                    name: pattern.identifier.text,
                    typeSyntax: typeSyntax,
                    isOptional: isOptional
                ))
            }
        }

        return properties
    }
}
