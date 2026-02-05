#if canImport(UIKit)
import SwiftUI
import UIKit
import ViewModelConstructorCore

struct ArrayInputView: View {
    let label: String
    let elementTypeInfo: TypeInfo
    @Binding var value: any Sendable

    var body: some View {
        let items = (value as? [any Sendable]) ?? []

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    var mutableItems = items
                    mutableItems.append(defaultValue(for: elementTypeInfo))
                    value = mutableItems
                } label: {
                    Image(systemName: "plus.circle")
                }
            }

            ForEach(items.indices, id: \.self) { index in
                HStack {
                    PropertyInputFactory.makeInput(
                        label: "\(label)[\(index)]",
                        typeInfo: elementTypeInfo,
                        value: Binding<any Sendable>(
                            get: {
                                let current = (value as? [any Sendable]) ?? []
                                guard index < current.count else {
                                    return defaultValue(for: elementTypeInfo)
                                }
                                return current[index]
                            },
                            set: { newVal in
                                var current = (value as? [any Sendable]) ?? []
                                guard index < current.count else { return }
                                current[index] = newVal
                                value = current
                            }
                        )
                    )
                    Button(role: .destructive) {
                        var mutableItems = (value as? [any Sendable]) ?? []
                        guard index < mutableItems.count else { return }
                        mutableItems.remove(at: index)
                        value = mutableItems
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                }
            }
        }
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
        default: return ""
        }
    }
}
#endif
