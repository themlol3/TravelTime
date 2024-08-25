import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter username"
        textField.borderStyle = .roundedRect
        return textField
    }()

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

    let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()

    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [usernameTextField, emailTextField, passwordTextField, confirmPasswordTextField, registerButton])
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

    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text, password == confirmPassword else {
            print("Password no")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Failed  register: \(error.localizedDescription)")
                return
            }

            guard let uid = authResult?.user.uid else { return }
            let databaseRef = Database.database().reference().child("users").child(uid)
            
            let username = self.usernameTextField.text ?? ""
            
            let values: [String: Any] = ["username": username, "email": email]

            databaseRef.updateChildValues(values) { error, ref in
                if let error = error {
                    print("Fail uinfo: \(error.localizedDescription)")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
