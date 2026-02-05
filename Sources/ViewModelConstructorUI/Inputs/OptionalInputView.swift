#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

struct OptionalInputView: View {
    let label: String
    let wrappedTypeInfo: TypeInfo
    @Binding var value: any Sendable

    @State private var isNonNil: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("\(label) (optional)", isOn: $isNonNil)
                .onChange(of: isNonNil) { _, newValue in
                    if !newValue {
                        value = Optional<Any>.none as any Sendable
                    } else {
                        value = defaultValue(for: wrappedTypeInfo)
                    }
                }
            if isNonNil {
                PropertyInputFactory.makeInput(
                    label: label,
                    typeInfo: wrappedTypeInfo,
                    value: $value
                )
            }
        }
        .onAppear {
            isNonNil = !isOptionalNil(value)
        }
    }

    private func isOptionalNil(_ val: any Sendable) -> Bool {
        let mirror = Mirror(reflecting: val)
        if mirror.displayStyle == .optional {
            return mirror.children.isEmpty
        }
        return false
    }

    private func defaultValue(for typeInfo: TypeInfo) -> any Sendable {
        switch typeInfo {
        case .string: return ""
        case .int: return 0
        case .double: return 0.0
        case .float: return Float(0.0)
        case .bool: return false
        case .date: return Date()
        case .color: return UIColor.black
        case .enumType(_, let cases): return cases.first ?? ""
        case .optional(let wrapped): return defaultValue(for: wrapped)
        case .array: return [any Sendable]()
        default: return ""
        }
    }
}
#endif
