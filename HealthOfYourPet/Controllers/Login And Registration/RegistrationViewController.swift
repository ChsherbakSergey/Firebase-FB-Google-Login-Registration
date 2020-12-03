//
//  RegistrationViewController.swift
//  HealthOfYourPet
//
//  Created by Sergey on 11/17/20.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import SCLAlertView
import FirebaseAuth
import JGProgressHUD

class RegistrationViewController: UIViewController {
    
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
    
    private let userImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person.crop.circle")
//        image.image = UIImage(named: "addProfileImage")
        image.tintColor = .lightGray
        image.layer.borderWidth = 2
        image.layer.borderColor = UIColor.black.cgColor
        image.contentMode = .scaleAspectFit
        image.layer.masksToBounds = true
        image.isUserInteractionEnabled = true
        return image
    }()
    
    private let firstNameTextField: UITextField = {
        let textField = MDCOutlinedTextField()
        textField.label.text = "First Name"
        textField.placeholder = "First Name"
        textField.layer.borderColor = UIColor.black.cgColor
        textField.sizeToFit()
        return textField
    }()
    
    private let lastNameTextField: UITextField = {
        let textField = MDCOutlinedTextField()
        textField.label.text = "Last Name"
        textField.placeholder = "Last Name"
        textField.layer.borderColor = UIColor.black.cgColor
        textField.sizeToFit()
        return textField
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
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Avenir Next Demi Bold", size: 22)
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        setInitialUI()
        setDelegates()
        dismissTextFieldWhenTapOutsideOfIt()
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        userImage.frame = CGRect(x: (scrollView.width - size) / 2, y: 30, width: size, height: size)
        userImage.layer.cornerRadius = userImage.width / 2.0
        firstNameTextField.frame = CGRect(x: 35, y: userImage.bottom + 40, width: scrollView.frame.size.width - 70, height: 52)
        lastNameTextField.frame = CGRect(x: 35, y: firstNameTextField.bottom + 20, width: scrollView.frame.size.width - 70, height: 52)
        emailTextField.frame = CGRect(x: 35, y: lastNameTextField.bottom + 20, width: scrollView.frame.size.width - 70, height: 52)
        passwordTextField.frame = CGRect(x: 35, y: emailTextField.bottom + 20, width: scrollView.frame.size.width - 70, height: 52)
        loginButton.frame = CGRect(x: 35, y: passwordTextField.bottom + 20, width: scrollView.frame.size.width - 70, height: 52)
    }
    
    func setInitialUI() {
        view.backgroundColor = .systemBackground
        //adding Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(userImage)
        scrollView.addSubview(firstNameTextField)
        scrollView.addSubview(lastNameTextField)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)
        //loginButton Target
        loginButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        //Set gesture for userImage
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeUserImage))
        userImage.addGestureRecognizer(gesture)
    }
    
    func setDelegates() {
        //TextFields Delegates
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc private func didTapChangeUserImage() {
        presentPhotoActionSheet()
    }
    
    private func dismissTextFieldWhenTapOutsideOfIt() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOutsideTextField))
        scrollView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapOutsideTextField() {
        scrollView.endEditing(true)
    }
    
    @objc private func didTapRegisterButton() {
        
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        // Firebase Registration
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                strongSelf.alertUserLoginError(message: "Looks like user account with that email adress already exists!")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }
                let appUser = AppUser(firstName: firstName, lastName: lastName, emailAdress: email)
                DatabaseManager.shared.insertUser(with: appUser, completion: { success in
                    if success {
                        //Upload the image
                        guard let image = strongSelf.userImage.image, let data = image.pngData() else {
                            return
                        }
                        let fileName = appUser.profilePictureFileName
                        StorageManager.shared.updateProfilePicture(with: data, fileName: fileName, completion: { result in
                            switch result {
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            case .success(let downloadUrl):
                                print(downloadUrl)
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                            }
                        })
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    func alertUserLoginError(message: String = "Please enter all the information to Register" ) {
        let alert = SCLAlertView()
        alert.showError("Woops", subTitle: message , closeButtonTitle: "Close", animationStyle: .bottomToTop)
    }

}

extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            didTapRegisterButton()
        }
        return true
    }
    
}

extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        userImage.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
