import UIKit
import ViewModelConstructorCore

@ViewModelConstructor
struct MyButtonViewModel {
    let value: String
    let backgroundColor: UIColor
    let corners: Double
    let topInset: Double
    let bottomInset: Double
    let leftInset: Double
    let rightInset: Double
    let isEnabled: Bool
    var action: (@MainActor @Sendable () -> Void)?
    var dynamicInset: DynamicInset

    init() {
        self.value = "Tap Me"
        self.backgroundColor = .systemBlue
        self.corners = 12
        self.topInset = 8
        self.bottomInset = 8
        self.leftInset = 16
        self.rightInset = 16
        self.isEnabled = true
        self.dynamicInset = DynamicInset()
    }
    
    @ViewModelConstructor
    struct DynamicInset {
        let topInset: Double
        let bottomInset: Double
        let leftInset: Double
        let rightInset: Double
        
        init() {
            self.topInset = 0
            self.bottomInset = 0
            self.leftInset = 0
            self.rightInset = 0
        }
    }
}

final class MyButtonView: UIView, ViewModelConfigurable {
    typealias ViewModel = MyButtonViewModel

    private let button = UIButton(type: .system)
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var actionHandler: (@MainActor @Sendable () -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        topConstraint = button.topAnchor.constraint(equalTo: topAnchor)
        bottomConstraint = button.bottomAnchor.constraint(equalTo: bottomAnchor)
        leadingConstraint = button.leadingAnchor.constraint(equalTo: leadingAnchor)
        trailingConstraint = button.trailingAnchor.constraint(equalTo: trailingAnchor)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    @objc private func handleTap() {
        // The action is stored on the view model when configured; invoke if present.
        actionHandler?()
    }

    func configure(with viewModel: MyButtonViewModel) {
        button.setTitle(viewModel.value, for: .normal)
        button.backgroundColor = viewModel.backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = viewModel.corners
        button.clipsToBounds = true
        topConstraint.constant = viewModel.topInset
        bottomConstraint.constant = -viewModel.bottomInset
        leadingConstraint.constant = viewModel.leftInset
        trailingConstraint.constant = -viewModel.rightInset
        button.isEnabled = viewModel.isEnabled
        actionHandler = viewModel.action
    }
}
