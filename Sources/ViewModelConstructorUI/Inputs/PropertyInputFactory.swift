#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

enum PropertyInputFactory {
    @ViewBuilder
    static func makeInput(
        label: String,
        typeInfo: TypeInfo,
        value: Binding<any Sendable>
    ) -> some View {
        switch typeInfo {
        case .string:
            StringInputView(label: label, value: value)

        case .int:
            IntInputView(label: label, value: value)

        case .double:
            DoubleInputView(label: label, value: value)

        case .float:
            FloatInputView(label: label, value: value)

        case .bool:
            BoolInputView(label: label, value: value)

        case .date:
            DateInputView(label: label, value: value)

        case .color:
            ColorInputView(label: label, value: value)

        case .enumType(_, let cases):
            EnumInputView(label: label, cases: cases, value: value)

        case .optional(let wrapped):
            OptionalInputView(
                label: label,
                wrappedTypeInfo: wrapped,
                value: value
            )

        case .array(let element):
            ArrayInputView(
                label: label,
                elementTypeInfo: element,
                value: value
            )

        case .dictionary:
            UnsupportedTypeInputView(label: label, typeName: "Dictionary")

        case .set:
            UnsupportedTypeInputView(label: label, typeName: "Set")

        case .nested:
            // Nested types are handled in InspectorView via NavigationLink
            UnsupportedTypeInputView(label: label, typeName: "Nested")

        case .custom(let type):
            UnsupportedTypeInputView(label: label, typeName: String(describing: type))
        }
    }
}
#endif
