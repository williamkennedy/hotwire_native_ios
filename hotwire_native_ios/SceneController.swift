import HotwireNative
import SafariServices
import UIKit
import WebKit

final class SceneController: UIResponder {
    var window: UIWindow?

    private let rootURL = URL(string: "http://localhost:3006")!
    private lazy var navigator = Navigator(pathConfiguration: pathConfiguration, delegate: self)

    // MARK: - Setup

    private func configureBridge() {
        Hotwire.registerBridgeComponents([
            FormComponent.self,
            KeyboardComponent.self
        ])
    }

    private func configureWebView() {
        Hotwire.config.makeCustomWebView = { config in
            let customWebView = CustomWebView(frame: .zero, configuration: config)
            Bridge.initialize(customWebView)
            return customWebView
        }
    }

    private func configureRootViewController() {
        guard let window = window else {
            fatalError()
        }

        window.rootViewController = navigator.rootViewController
    }

    // MARK: - Authentication

    private func promptForAuthentication() {
        let authURL = rootURL.appendingPathComponent("/signin")
        navigator.route(authURL)
    }

    // MARK: - Path Configuration

    private lazy var pathConfiguration = PathConfiguration(sources: [
        .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!),
    ])
}

extension SceneController: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()

        configureBridge()
        configureWebView()
        configureRootViewController()

        navigator.route(rootURL)
    }
}

extension SceneController: NavigatorDelegate {

    func handle(proposal: VisitProposal) -> ProposalResult {
        switch proposal.viewController {

        case "numbers_detail":
            let alertController = UIAlertController(title: "Number", message: "\(proposal.url.lastPathComponent)", preferredStyle: .alert)
            alertController.addAction(.init(title: "OK", style: .default, handler: nil))
            return .acceptCustom(alertController)

        default:
            return .acceptCustom(WebViewController(url: proposal.url))
        }
    }


    func visitableDidFailRequest(_ visitable: any Visitable, error: any Error, retryHandler: RetryBlock?) {
        if let turboError = error as? TurboError, case let .http(statusCode) = turboError, statusCode == 401 {
            promptForAuthentication()
        } else if let errorPresenter = visitable as? ErrorPresenter {
            errorPresenter.presentError(error) {
                retryHandler?()
            }
        } else {
            let alert = UIAlertController(title: "Visit failed!", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            navigator.rootViewController.present(alert, animated: true)
        }
    }
}


class WebViewController: HotwireWebViewController {



    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

class CustomWebView: WKWebView {
    let toolbar: UIToolbar = UIToolbar()
    var heading1: (() -> Void)?
    var bold: (() -> Void)?
    var italic: (() -> Void)?
    var undo: (() -> Void)?
    var redo: (() -> Void)?

    override var inputAccessoryView: UIView {
        toolbar.isHidden = true

        toolbar.sizeToFit()

        let heading1 = UIBarButtonItem(title: "h1", style: .plain, target: self, action: #selector(heading1Tapped))
        let bold = UIBarButtonItem(image: UIImage(systemName: "bold"), style: .plain, target: self, action: #selector(boldTapped))
        let italic = UIBarButtonItem(image: UIImage(systemName: "italic"), style: .plain, target: self, action: #selector(italicTapped))
        let undo = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward"), style: .plain, target: self, action: #selector(undoTapped))
        let redo = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.forward"), style: .plain, target: self, action: #selector(redoTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done",  style: .plain, target: self, action: #selector(doneButtonTapped))


        toolbar.setItems([heading1, bold, italic, undo, redo, flexibleSpace, done ], animated: true)

        return toolbar


    }

    @objc private func heading1Tapped() {
        heading1?()
    }

    @objc private func boldTapped() {
        bold?()
    }


    @objc private func italicTapped() {
        italic?()
    }

    @objc private func undoTapped() {
        undo?()
    }


    @objc private func redoTapped() {
        redo?()
    }

    @objc private func doneButtonTapped() {
        self.endEditing(true)  // Dismiss the keyboard
    }

    func toggleCustomToolbar() {
        toolbar.isHidden = !toolbar.isHidden
    }
}

