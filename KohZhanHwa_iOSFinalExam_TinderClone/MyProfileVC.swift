//
//  MyProfileVC.swift
//  KohZhanHwa_iOSFinalExam_TinderClone
//
//  Created by Alex Koh on 02/10/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import Foundation
import UIKit

class MyProfileVC: UIViewController {
    var currentUser: User = User()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    @IBAction func editProfileBtnTapped(_ sender: Any) {
        guard let signUpEditProfile = storyboard?.instantiateViewController(withIdentifier: "SignUpEditProfileVC") as? SignUpEditProfileVC else {return}
        signUpEditProfile.isSignUp = false
        present(signUpEditProfile, animated: true, completion: nil)
    }
    
    @IBAction func signOutBtnTapped(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        setupInitialView()
    }
    
    func setupInitialView() {
        guard let profileImageUrl = currentUser.profileImgUrl,
            let name = currentUser.name,
            let age = currentUser.age,
            let gender = currentUser.gender,
            let email = currentUser.email,
            let description = currentUser.description else {return}
        
        nameTextField.text = name
        ageTextField.text = age
        genderTextField.text = gender
        emailTextField.text = email
        descriptionTextField.text = description
        
        loadImage(urlString: profileImageUrl)
    }
    
    func loadImage(urlString: String) {
        //1.url
        //2.session
        //3.task
        //4.start
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    self.profileImage.image = UIImage(data: data)
                }
            }
        }
        task.resume()
    }
    
    
    
}
