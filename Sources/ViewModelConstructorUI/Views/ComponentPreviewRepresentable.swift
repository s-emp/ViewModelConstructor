#if canImport(UIKit)
import SwiftUI
import UIKit
import ViewModelConstructorCore

struct ComponentPreviewRepresentable: UIViewRepresentable {
    let registration: ComponentRegistration
    let values: [String: any Sendable]
    let showBorder: Bool
    let updateTrigger: UUID

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = true

        let componentView = registration.createView()
        componentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(componentView)

        NSLayoutConstraint.activate([
            componentView.topAnchor.constraint(equalTo: containerView.topAnchor),
            componentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            componentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])

        // Configure with current values
        let viewModel = registration.constructFromValues(values)
        registration.configureView(componentView, viewModel)

        // Apply border
        if showBorder {
            componentView.layer.borderWidth = 1
            componentView.layer.borderColor = UIColor.systemBlue.cgColor
        }

        context.coordinator.componentView = componentView
        return containerView
    }

    func updateUIView(_ containerView: UIView, context: Context) {
        // If updateTrigger changed, recreate the component
        if context.coordinator.lastTrigger != updateTrigger {
            context.coordinator.lastTrigger = updateTrigger

            // Remove old component
            context.coordinator.componentView?.removeFromSuperview()

            let componentView = registration.createView()
            componentView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(componentView)

            NSLayoutConstraint.activate([
                componentView.topAnchor.constraint(equalTo: containerView.topAnchor),
                componentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                componentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ])

            context.coordinator.componentView = componentView
        }

        // Configure with current values
        if let componentView = context.coordinator.componentView {
            let viewModel = registration.constructFromValues(values)
            registration.configureView(componentView, viewModel)

            componentView.layer.borderWidth = showBorder ? 1 : 0
            componentView.layer.borderColor = showBorder ? UIColor.systemBlue.cgColor : nil
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var componentView: UIView?
        var lastTrigger: UUID = UUID()
    }
}
#endif
