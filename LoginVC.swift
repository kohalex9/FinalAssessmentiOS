//
//  LoginVC.swift
//  KohZhanHwa_iOSFinalExam_TinderClone
//
//  Created by Alex Koh on 02/10/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        if email.characters.count <= 0 {
            createErrorVC("Empty email fill", "Please enter your email address")
        }
        if password.characters.count <= 0 {
            createErrorVC("Empty password fill", "Please enter your password")
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let validError = error {
                print("Failed to sign in: ", validError.localizedDescription)
                self.createErrorVC("Failed to SignIn", validError.localizedDescription)
            }
            
            if let user = user {
                
                guard let myProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as? MyProfileVC else {return}
                myProfileVC.currentUser.email = email
                
                let navigationController = UINavigationController(rootViewController: myProfileVC)
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func signUpBtnTapped(_ sender: Any) {
        guard let signUpEditProfileVC = storyboard?.instantiateViewController(withIdentifier: "SignUpEditProfileVC") as? SignUpEditProfileVC else {return}
        signUpEditProfileVC.isSignUp = true
        
        navigationController?.pushViewController(signUpEditProfileVC, animated: true)
    }
    
    override func viewDidLoad() {
        guard let email = Auth.auth().currentUser?.email else {return}
        
        //check if there is any user logged in
        if Auth.auth().currentUser != nil {
            
            guard let myProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as? MyProfileVC else {return}
            myProfileVC.currentUser.email = email
            
            let navigationController = UINavigationController(rootViewController: myProfileVC)
            self.present(navigationController, animated: true, completion: nil)
            
        }
    }
    
    func createErrorVC(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
}
