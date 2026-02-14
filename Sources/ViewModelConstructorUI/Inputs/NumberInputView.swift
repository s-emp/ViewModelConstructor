#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

struct IntInputView: View {
    let label: String
    @Binding var value: any Sendable

    var body: some View {
        let binding = Binding<Int>(
            get: { value as? Int ?? 0 },
            set: { value = $0 }
        )
        HStack {
            TextField(label, value: binding, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            Stepper("", value: binding)
                .labelsHidden()
        }
    }
}

struct DoubleInputView: View {
    let label: String
    @Binding var value: any Sendable

    var body: some View {
        let binding = Binding<Double>(
            get: { value as? Double ?? 0.0 },
            set: { value = $0 }
        )
        HStack {
            TextField(label, value: binding, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
            Stepper("", value: binding, step: 0.1)
                .labelsHidden()
        }
    }
}

struct FloatInputView: View {
    let label: String
    @Binding var value: any Sendable

    var body: some View {
        let binding = Binding<Float>(
            get: { value as? Float ?? 0.0 },
            set: { value = $0 }
        )
        HStack {
            TextField(label, value: binding, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
            Stepper(
                "",
                value: binding,
                step: 0.1
            )
            .labelsHidden()
        }
    }
}

#Preview("Int Input") {
    @Previewable @State var value: any Sendable = 42
    IntInputView(label: "Count", value: $value)
        .padding()
}

#Preview("Double Input") {
    @Previewable @State var value: any Sendable = 3.14
    DoubleInputView(label: "Opacity", value: $value)
        .padding()
}

#Preview("Float Input") {
    @Previewable @State var value: any Sendable = Float(1.5)
    FloatInputView(label: "Scale", value: $value)
        .padding()
}
#endif
