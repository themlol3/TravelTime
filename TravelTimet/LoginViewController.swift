import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter email"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }

    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            print("User logged in")
            self.dismiss(animated: true, completion: nil)
        }
    }
}
