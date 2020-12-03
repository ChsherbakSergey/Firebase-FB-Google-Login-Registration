//
//  ViewController.swift
//  HealthOfYourPet
//
//  Created by Sergey on 11/17/20.
//

import UIKit
import FirebaseAuth

class MainPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userLoggedIn()
    }
    
    func userLoggedIn() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
}

