//
//  ProfileViewController.swift
//  HealthOfYourPet
//
//  Created by Sergey on 11/19/20.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewDelegateAndDataSource()
        
    }
    
    func setTableViewDelegateAndDataSource() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = crateTableViewHeader()
    }
    
    func crateTableViewHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 200)
        headerView.backgroundColor = .systemGray6
        let imageView = UIImageView()
        imageView.frame = CGRect(x: (headerView.width - 150) / 2, y: 25, width: 150, height: 150)
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            switch result {
            case.failure(let error):
                print("Got Error downloading profile image: \(error)")
            case.success(let url):
                self?.downloadImage(with: imageView, url: url)
            }
        })
        
        return headerView
    }
    
    func downloadImage(with imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogOutCell", for: indexPath) as! ProfileTableViewCell
        cell.nameLabel.text = data[indexPath.row]
        cell.nameLabel.textAlignment = .center
        cell.nameLabel.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "", message: "Do you really want to Log Out?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            //Facebook Log Out
            
            FBSDKLoginKit.LoginManager().logOut()
            
            //Google Log Out
            
            GIDSignIn.sharedInstance()?.signOut()
            
            //Firebase Log Out
            do {
                try FirebaseAuth.Auth.auth().signOut()
                // If Log out present Login Screen
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            } catch {
                print("Failed to log out")
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
}
