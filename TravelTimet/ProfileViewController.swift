import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
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
        title = "Profile"

        checkIfUserIsLoggedIn()
    }

    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            setupLoginAndRegisterButtons()
        } else {
            setupUserProfile()
        }
    }

    func setupLoginAndRegisterButtons() {
        let stackView = UIStackView(arrangedSubviews: [loginButton, registerButton])
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

    func setupUserProfile() {
        guard let user = Auth.auth().currentUser else { return }

        let emailLabel = UILabel()
        emailLabel.text = "Welcome Back: \(user.email ?? "No email")"

        let stackView = UIStackView(arrangedSubviews: [emailLabel])
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
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)
    }

    @objc func handleRegister() {
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true, completion: nil)
    }
}
