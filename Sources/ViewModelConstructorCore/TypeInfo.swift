public indirect enum TypeInfo: @unchecked Sendable {
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
