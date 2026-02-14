#if canImport(UIKit)
import SwiftUI
import UIKit
import ViewModelConstructorCore

struct ColorInputView: View {
    let label: String
    @Binding var value: any Sendable

    var body: some View {
        let binding = Binding<Color>(
            get: {
                if let uiColor = value as? UIColor {
                    return Color(uiColor: uiColor)
                }
                return .black
            },
            set: { value = UIColor($0) }
        )
        ColorPicker(label, selection: binding)
    }
}

#Preview {
    @Previewable @State var value: any Sendable = UIColor.systemBlue
    ColorInputView(label: "Background Color", value: $value)
        .padding()
}
#endif
