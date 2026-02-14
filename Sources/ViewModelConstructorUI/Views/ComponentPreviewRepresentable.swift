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
            componentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
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
        context.coordinator.lastRegistrationID = registration.id
        return containerView
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
        let width = proposal.width ?? UIView.layoutFittingCompressedSize.width
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let fittingSize = uiView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: max(fittingSize.width, 1), height: max(fittingSize.height, 1))
    }

    func updateUIView(_ containerView: UIView, context: Context) {
        let needsRecreate = context.coordinator.lastTrigger != updateTrigger
            || context.coordinator.lastRegistrationID != registration.id

        if needsRecreate {
            context.coordinator.lastTrigger = updateTrigger
            context.coordinator.lastRegistrationID = registration.id

            // Remove old component
            context.coordinator.componentView?.removeFromSuperview()

            let componentView = registration.createView()
            componentView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(componentView)

            NSLayoutConstraint.activate([
                componentView.topAnchor.constraint(equalTo: containerView.topAnchor),
                componentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                componentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                componentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
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
        var lastRegistrationID: UUID?
    }
}
#endif
