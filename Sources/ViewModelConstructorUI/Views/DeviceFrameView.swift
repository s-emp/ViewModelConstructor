#if canImport(UIKit)
import SwiftUI

enum DeviceSize: String, CaseIterable, Identifiable {
    case iPhoneSE = "iPhone SE"
    case iPhone15 = "iPhone 15"
    case iPhone15ProMax = "iPhone 15 Pro Max"

    var id: String { rawValue }

    var size: CGSize {
        switch self {
        case .iPhoneSE: return CGSize(width: 375, height: 667)
        case .iPhone15: return CGSize(width: 393, height: 852)
        case .iPhone15ProMax: return CGSize(width: 430, height: 932)
        }
    }
}

struct DeviceFrameView<Content: View>: View {
    let deviceSize: DeviceSize
    let backgroundColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(backgroundColor)
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.secondary.opacity(0.5), lineWidth: 2)

                ScrollView {
                    content()
                        .frame(maxWidth: .infinity, alignment: .top)
                }
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(2)
            }
            .frame(width: deviceSize.size.width * 0.5, height: deviceSize.size.height * 0.5)

            Text(deviceSize.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
#endif
