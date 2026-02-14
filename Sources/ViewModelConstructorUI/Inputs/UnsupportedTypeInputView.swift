#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

struct UnsupportedTypeInputView: View {
    let label: String
    let typeName: String

    var body: some View {
        Label {
            Text("\(label) — \(typeName) (unsupported)")
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.orange)
        }
    }
}

#Preview {
    UnsupportedTypeInputView(label: "metadata", typeName: "CustomComplexType")
        .padding()
}
#endif
