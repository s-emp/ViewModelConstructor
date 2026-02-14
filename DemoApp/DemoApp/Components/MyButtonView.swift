import UIKit
import ViewModelConstructorCore

@ViewModelConstructor
struct MyButtonViewModel {
    var value: String
    var backgroundColor: UIColor
    var corners: Double
    var topInset: Double
    var bottomInset: Double
    var leftInset: Double
    var rightInset: Double

    init() {
        self.value = "Tap Me"
        self.backgroundColor = .systemBlue
        self.corners = 12
        self.topInset = 8
        self.bottomInset = 8
        self.leftInset = 16
        self.rightInset = 16
    }
}

final class MyButtonView: UIView, ViewModelConfigurable {
    typealias ViewModel = MyButtonViewModel

    private let button = UIButton(type: .system)
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)

        topConstraint = button.topAnchor.constraint(equalTo: topAnchor)
        bottomConstraint = button.bottomAnchor.constraint(equalTo: bottomAnchor)
        leadingConstraint = button.leadingAnchor.constraint(equalTo: leadingAnchor)
        trailingConstraint = button.trailingAnchor.constraint(equalTo: trailingAnchor)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

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
    }
}
