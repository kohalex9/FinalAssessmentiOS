//
//  MyProfileVC.swift
//  KohZhanHwa_iOSFinalExam_TinderClone
//
//  Created by Alex Koh on 02/10/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class MyProfileVC: UIViewController {
    var currentUser: User = User()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    @IBAction func seeYourMatchesBtnTapped(_ sender: Any) {
        guard let matchProfileTarget = self.storyboard?.instantiateViewController(withIdentifier: "MatchedProfilesVC") as? MatchedProfilesVC else {return}
        
        matchProfileTarget.currentUser = currentUser
        navigationController?.pushViewController(matchProfileTarget, animated: true)
    }
    
    @IBAction func chooseNewMatchBtnTapped(_ sender: Any) {
        guard let matchCandidateVc = storyboard?.instantiateViewController(withIdentifier: "MatchCandidateVC") as? MatchCandidateVC else {return}
        
        matchCandidateVc.currentUser = currentUser
        
        navigationController?.pushViewController(matchCandidateVc, animated: true)
        
    }
    
    
    @IBAction func editProfileBtnTapped(_ sender: Any) {
        guard let signUpEditProfile = storyboard?.instantiateViewController(withIdentifier: "SignUpEditProfileVC") as? SignUpEditProfileVC else {return}
        signUpEditProfile.isSignUp = false
        signUpEditProfile.currentUser = currentUser
        present(signUpEditProfile, animated: true, completion: nil)
    }
    
    
    
    @IBAction func signOutBtnTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            guard let loginNavi = storyboard?.instantiateViewController(withIdentifier: "loginNav") as? UINavigationController else {return}
            self.present(loginNavi, animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func viewDidLoad() {
        //setupInitialView()
        v2setupInitialView()
    }
    
    func v2setupInitialView() {
        guard let currentUserEmail = currentUser.email
            else {return}
        
        emailTextField.text = currentUser.email!
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            guard let info = snapshot.value as? [String:Any] else {return}
            
            if let profileImageUrl = info["profileImageUrl"] as? String,
                let name = info["name"] as? String,
                let age = info["age"] as? String,
                let gender = info["gender"] as? String,
                let email = info["email"] as? String,
                let password = info["password"] as? String,
                let description = info["description"] as? String,
                let randomId = info["randomId"] as? String,
                let matchListId = info["matchListId"] as? String {
                if currentUserEmail == email {
                    self.currentUser.profileImgUrl = profileImageUrl
                    self.currentUser.name = name
                    self.currentUser.age = age
                    self.currentUser.gender = gender
                    self.currentUser.password = password
                    self.currentUser.description = description
                    self.currentUser.randomId = randomId
                    self.currentUser.matchListId = matchListId
                    
                    self.nameTextField.text = name
                    self.ageTextField.text = age
                    self.genderTextField.text = gender
                    self.descriptionTextField.text = description
                    
                    self.loadImage(urlString: profileImageUrl)
                }
            }
            
        })
    }
    
    func setupInitialView() {
        
        //Come from loginVC
        if currentUser.name == nil {
            //Safely unwrap current user email passed from loginVC
            guard let currentUserEmail = currentUser.email
                else {return}
            
            emailTextField.text = currentUser.email!
            Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
                guard let info = snapshot.value as? [String:Any] else {return}
                
                if let profileImageUrl = info["profileImageUrl"] as? String,
                    let name = info["name"] as? String,
                    let age = info["age"] as? String,
                    let gender = info["gender"] as? String,
                    let email = info["email"] as? String,
                    let password = info["password"] as? String,
                    let description = info["description"] as? String,
                    let randomId = info["randomId"] as? String,
                    let matchListId = info["matchListId"] as? String {
                    if currentUserEmail == email {
                        self.currentUser.profileImgUrl = profileImageUrl
                        self.currentUser.name = name
                        self.currentUser.age = age
                        self.currentUser.gender = gender
                        self.currentUser.password = password
                        self.currentUser.description = description
                        self.currentUser.randomId = randomId
                        self.currentUser.matchListId = matchListId
                        
                        self.nameTextField.text = name
                        self.ageTextField.text = age
                        self.genderTextField.text = gender
                        self.descriptionTextField.text = description
                        
                        self.loadImage(urlString: profileImageUrl)
                    }
                }
                 
            })
        } else {
            //Come from SignUp VC
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
