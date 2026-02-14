import UIKit
import ViewModelConstructorCore

@ViewModelConstructor
struct MyTextViewModel {
    var value: String
    var color: UIColor
    var topInset: Double
    var bottomInset: Double
    var leftInset: Double
    var rightInset: Double

    init() {
        self.value = "Hello, World!"
        self.color = .label
        self.topInset = 8
        self.bottomInset = 8
        self.leftInset = 16
        self.rightInset = 16
    }
}

final class MyTextView: UIView, ViewModelConfigurable {
    typealias ViewModel = MyTextViewModel

    private let label = UILabel()
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        addSubview(label)

        topConstraint = label.topAnchor.constraint(equalTo: topAnchor)
        bottomConstraint = label.bottomAnchor.constraint(equalTo: bottomAnchor)
        leadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor)
        trailingConstraint = label.trailingAnchor.constraint(equalTo: trailingAnchor)
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(with viewModel: MyTextViewModel) {
        label.text = viewModel.value
        label.textColor = viewModel.color
        topConstraint.constant = viewModel.topInset
        bottomConstraint.constant = -viewModel.bottomInset
        leadingConstraint.constant = viewModel.leftInset
        trailingConstraint.constant = -viewModel.rightInset
    }
}
