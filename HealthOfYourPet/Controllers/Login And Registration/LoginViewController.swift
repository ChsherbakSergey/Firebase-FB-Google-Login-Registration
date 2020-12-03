//
//  LoginViewController.swift
//  HealthOfYourPet
//
//  Created by Sergey on 11/17/20.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import SCLAlertView
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD()
        spinner.style = .dark
        return spinner
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageLogo: UIImageView = {
        let logoImage = UIImageView()
        logoImage.image = UIImage(named: "logo-1")
        logoImage.contentMode = .scaleAspectFit
        return logoImage
    }()
    
    private let emailTextField: UITextField = {
        let textField = MDCOutlinedTextField()
        textField.label.text = "Email Adress"
        textField.placeholder = "Email Adress"
        textField.layer.borderColor = UIColor.black.cgColor
        textField.sizeToFit()
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = MDCOutlinedTextField()
        textField.label.text = "Password"
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.layer.borderColor = UIColor.black.cgColor
        textField.sizeToFit()
        return textField
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot password?", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir Next", size: 12)
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.label, for: .normal)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Avenir Next Demi Bold", size: 22)
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    private let dontHaveAnAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an accont?"
        label.font = UIFont(name: "Avenir Next Demi Bold", size: 12)
        label.textColor = UIColor.label
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up Now!", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir Next", size: 12)
        button.setTitleColor(UIColor.red, for: .normal)
        button.layer.masksToBounds = true
        return button
    }()
    
    private let orSignInWithLabel: UILabel = {
        let label = UILabel()
        label.text = "Or Sign in with Social Networks"
        label.font = UIFont(name: "Avenir Next Demi Bold", size: 12)
        label.textColor = UIColor.label
        return label
    }()
    
    private let facebookButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    private let googleButton: GIDSignInButton = {
        let button = GIDSignInButton()
        return button
    }()
    
    private var loginWithGoogleObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        setNavigationBar()
        setInitialUI()
        setDelegates()
        dismissTextFieldWhenTapOutsideOfIt()
        setNotificationObserverForGoogleSignIn()
    }
    
    deinit {
        if let observer = loginWithGoogleObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        imageLogo.frame = CGRect(x: (scrollView.width - size) / 2, y: 30, width: size, height: size)
        emailTextField.frame = CGRect(x: 35, y: imageLogo.bottom + 60, width: scrollView.frame.size.width - 70, height: 52)
        passwordTextField.frame = CGRect(x: 35, y: emailTextField.bottom + 20, width: scrollView.frame.size.width - 70, height: 52)
        forgotPasswordButton.frame = CGRect(x: scrollView.frame.size.width - 135, y: passwordTextField.bottom + 10, width: 100, height: 20)
        loginButton.frame = CGRect(x: 35, y: forgotPasswordButton.bottom + 10, width: scrollView.frame.size.width - 70, height: 52)
        dontHaveAnAccountLabel.frame = CGRect(x: (scrollView.width - size) / 3 + 10, y: loginButton.bottom + 10, width: scrollView.frame.size.width / 3, height: 20)
        signUpButton.frame = CGRect(x: scrollView.width / 2 + 20, y: loginButton.bottom + 10, width: 80, height: 20)
        orSignInWithLabel.frame = CGRect(x: scrollView.center.x - 90, y: signUpButton.bottom + 10, width: 180, height: 20)
        facebookButton.frame = CGRect(x: 35, y: orSignInWithLabel.bottom + 10, width: scrollView.frame.size.width - 70, height: 28)
        googleButton.frame = CGRect(x: 30, y: facebookButton.bottom + 10, width: scrollView.frame.size.width - 60, height: 28)
    }
    
    func setNavigationBar() {
        //Set BackBarButtonItem title
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "Login", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.black
    }
    
    func setInitialUI() {
        view.backgroundColor = .systemBackground
        //adding Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageLogo)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(forgotPasswordButton)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(dontHaveAnAccountLabel)
        scrollView.addSubview(signUpButton)
        scrollView.addSubview(orSignInWithLabel)
        scrollView.addSubview(facebookButton)
        scrollView.addSubview(googleButton)
        //loginButton Target
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        //signUpButton Target
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        //forgotPasswordButton Target
        forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPasswordButton), for: .touchUpInside)
        //Set the presenting view controller of the GIDSignIn object, and (optionally) to sign in silently when possible.
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance().signIn()
    }
    
    func setDelegates() {
        //TextFields Delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        //FacebookButton Delegate
        facebookButton.delegate = self
    }
    
    private func dismissTextFieldWhenTapOutsideOfIt() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutsideTextField))
        gesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(gesture)
    }
    
    func setNotificationObserverForGoogleSignIn() {
        loginWithGoogleObserver = NotificationCenter.default.addObserver(forName: .didLoginWithGoogle, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc private func didTapOutsideTextField() {
        scrollView.endEditing(true)
    }
    
    @objc private func didTapLoginButton() {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Log In
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Error when log in the user")
                return
            }
            let user = result.user
            UserDefaults.standard.setValue(email, forKey: "email")
            
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc private func didTapSignUpButton() {
        let vc = RegistrationViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapForgotPasswordButton() {
        print("Forgot Password")
    }
    
    func alertUserLoginError() {
        let alert = SCLAlertView()
        alert.showError("Woops", subTitle: "Please enter all the information to Log In", closeButtonTitle: "Close", animationStyle: .bottomToTop)
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            didTapLoginButton()
        }
        return true
    }
    
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completionHandler: { connection, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            guard let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let email = result["email"] as? String, let picture = result["picture"] as? [String: Any], let data = picture["data"] as? [String: Any], let pictureUrl = data["url"] as? String else {
                print("Failed to get user name and email from facebook result")
                return
            }
            
            UserDefaults.standard.setValue(email, forKey: "email")
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    //User already exists
                }
                let appUser = AppUser(firstName: firstName, lastName: lastName, emailAdress: email)
                DatabaseManager.shared.insertUser(with: appUser, completion: { success in
                    if success {
                        guard let url = URL(string: pictureUrl) else {
                            print("Failed to get url for Facebook picture")
                            return
                        }
                        print("Downloading data from facebook image")
                        
                        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                            guard let data = data else {
                                print("Failed to get data for picture url from facebook")
                                return
                            }
                            print("Got data from facebook, now uploading it")
                            
                            //Upload image
                            let fileName = appUser.profilePictureFileName
                            StorageManager.shared.updateProfilePicture(with: data, fileName: fileName, completion: { result in
                                switch result {
                                case .failure(let error):
                                    print("Storage manager error: \(error)")
                                case .success(let downloadUrl):
                                    print(downloadUrl)
                                    UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture_url")
                                }
                            })
                        }).resume()
                        
                    }
                })
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook credential log in failed. MFA may be nedded: \(error) ")
                    }
                    return
                }
                
                print("Successfully logged in with facebook")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
            
        })
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //No operation here
    }
    
}
