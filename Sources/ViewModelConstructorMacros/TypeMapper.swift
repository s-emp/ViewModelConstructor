import SwiftSyntax

enum TypeMapper {
    /// Extracts a TypeSyntax from a GenericArgumentSyntax.Argument (swift-syntax 602 uses an enum).
    private static func extractType(from argument: GenericArgumentSyntax.Argument) -> TypeSyntax? {
        switch argument {
        case .type(let typeSyntax):
            return typeSyntax
        case .expr:
            return nil
        }
    }

    /// Maps a TypeSyntax to a TypeInfo expression string (e.g., ".string", ".optional(wrapped: .int)")
    static func typeInfoExpression(for type: TypeSyntax) -> String {
        // Optional sugar syntax: T?
        if let optionalType = type.as(OptionalTypeSyntax.self) {
            let wrapped = typeInfoExpression(for: optionalType.wrappedType)
            return ".optional(wrapped: \(wrapped))"
        }

        // Array sugar syntax: [T]
        if let arrayType = type.as(ArrayTypeSyntax.self) {
            let element = typeInfoExpression(for: arrayType.element)
            return ".array(element: \(element))"
        }

        // Dictionary sugar syntax: [K: V]
        if let dictType = type.as(DictionaryTypeSyntax.self) {
            let key = typeInfoExpression(for: dictType.key)
            let value = typeInfoExpression(for: dictType.value)
            return ".dictionary(key: \(key), value: \(value))"
        }

        // Identifier types (String, Int, Optional<T>, Array<T>, etc.)
        if let identType = type.as(IdentifierTypeSyntax.self) {
            let name = identType.name.text

            // Check for base types
            switch name {
            case "String": return ".string"
            case "Int": return ".int"
            case "Double": return ".double"
            case "Float": return ".float"
            case "Bool": return ".bool"
            case "Date": return ".date"
            case "Color", "UIColor": return ".color"
            default:
                break
            }

            // Generic types: Optional<T>, Array<T>, Dictionary<K,V>, Set<T>
            if let genericArgs = identType.genericArgumentClause {
                let args = Array(genericArgs.arguments)
                switch name {
                case "Optional" where args.count == 1:
                    if let wrappedType = extractType(from: args[0].argument) {
                        let wrapped = typeInfoExpression(for: wrappedType)
                        return ".optional(wrapped: \(wrapped))"
                    }
                case "Array" where args.count == 1:
                    if let elementType = extractType(from: args[0].argument) {
                        let element = typeInfoExpression(for: elementType)
                        return ".array(element: \(element))"
                    }
                case "Dictionary" where args.count == 2:
                    if let keyType = extractType(from: args[0].argument),
                        let valueType = extractType(from: args[1].argument)
                    {
                        let key = typeInfoExpression(for: keyType)
                        let value = typeInfoExpression(for: valueType)
                        return ".dictionary(key: \(key), value: \(value))"
                    }
                case "Set" where args.count == 1:
                    if let elementType = extractType(from: args[0].argument) {
                        let element = typeInfoExpression(for: elementType)
                        return ".set(element: \(element))"
                    }
                default:
                    return ".custom(type: \(name).self)"
                }
            }

            // Unknown/custom type
            return ".custom(type: \(name).self)"
        }

        // Fallback for any other syntax
        return ".custom(type: \(type.trimmedDescription).self)"
    }

    /// Generates the construct expression for a property in the `construct(from:)` method.
    static func constructExpression(propertyName: String, type: TypeSyntax) -> String {
        let isOptional =
            type.is(OptionalTypeSyntax.self)
            || (type.as(IdentifierTypeSyntax.self)?.name.text == "Optional")

        if isOptional {
            let unwrappedType = unwrapOptionalType(type)
            return "values[\"\(propertyName)\"] as? \(unwrappedType)"
        } else {
            return "values[\"\(propertyName)\"] as! \(type.trimmedDescription)"
        }
    }

    /// Unwraps an optional type to get the inner type name.
    private static func unwrapOptionalType(_ type: TypeSyntax) -> String {
        if let optionalType = type.as(OptionalTypeSyntax.self) {
            return optionalType.wrappedType.trimmedDescription
        }
        if let identType = type.as(IdentifierTypeSyntax.self),
            identType.name.text == "Optional",
            let genericArgs = identType.genericArgumentClause
        {
            let args = Array(genericArgs.arguments)
            if args.count == 1 {
                if let wrappedType = extractType(from: args[0].argument) {
                    return wrappedType.trimmedDescription
                }
            }
        }
        return type.trimmedDescription
    }
}
