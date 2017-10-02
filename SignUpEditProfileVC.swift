//
//  SignUpEditProfileVC.swift
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


class SignUpEditProfileVC: UIViewController {
    
    var isSignUp: Bool = false
    var profileImageUrl: String = ""
    
    @IBOutlet weak var plusPhotoBtn: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var selfDescriptionTextView: UITextView!
    @IBOutlet weak var signUpBtn: UIButton! {
        didSet {
            signUpBtn.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    @IBOutlet weak var editProfileBtn: UIButton! {
        didSet {
            editProfileBtn.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    @IBAction func plusPhotoBtnTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func signUpBtnTapped(_ sender: Any) {
        guard let name = nameTextField.text,
            let age = ageTextField.text,
            let gender = genderTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let description = selfDescriptionTextView.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Create new use fail: ", error)
                self.createErrorVC("Sign Up Fail", error.localizedDescription)
                return
            }
            
            if let user = user {
                
                let post: [String: Any] = ["name": name, "age": age, "gender": gender, "email": email, "description": description]
                Database.database().reference().child("Users").child(user.uid).setValue(post)
                
                //Create an instance of User to be passed to MyProfileVC later
                let currentUser = User()
                currentUser.profileImgUrl = self.profileImageUrl
                currentUser.name = name
                currentUser.age = age
                currentUser.gender = gender
                currentUser.email = email
                currentUser.description = description
                
                guard let myProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as? MyProfileVC else {return}
                
                myProfileVC.currentUser = currentUser
                
                self.present(myProfileVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func editProfileBtnTapped(_ sender: Any) {
        
    }
    
    
    override func viewDidLoad() {
        setupInitialView()
    }
    
    func setupInitialView() {
        //disable signUpBtn and editProfileBtn by default
        //only enable it after all info are entered
        if isSignUp {
            signUpBtn.isHidden = false
            signUpBtn.isEnabled = false
            
            editProfileBtn.isHidden = true
        } else {
            signUpBtn.isHidden = true
            
            editProfileBtn.isHidden = false
            editProfileBtn.isEnabled = true
        }
        
        //Setup delegate for every textfields and textview
        nameTextField.delegate = self
        ageTextField.delegate = self
        genderTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        selfDescriptionTextView.delegate = self
    }
    
    func createErrorVC(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //dismiss the keyboard when user touches the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        genderTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        selfDescriptionTextView.resignFirstResponder()
    }
    
    func checkSholdEnableButton() {
        let isFormValid = nameTextField.hasText && ageTextField.hasText && genderTextField.hasText && genderTextField.hasText && emailTextField.hasText && passwordTextField.hasText && selfDescriptionTextView.hasText && plusPhotoBtn.imageView?.image != nil && profileImageUrl != ""
        
        if isFormValid {
            signUpBtn.isEnabled = true
            editProfileBtn.isEnabled = true
            
            signUpBtn.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            editProfileBtn.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)


        } else {
            signUpBtn.isEnabled = false
            editProfileBtn.isEnabled = false
            
            signUpBtn.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            editProfileBtn.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    func uploadToStorage(_ image: UIImage) {
        let ref = Storage.storage().reference()
        
        let timeStamp = Date().timeIntervalSince1970
        
        //compress the image so that the image isn't too big
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        //metadata - gives us the url to retrieve the data on the cloud
        
        ref.child("\(timeStamp).jpeg").putData(imageData, metadata: metaData) { (meta, error) in
            if let validError = error {
                print("Failed to upload image: ", validError.localizedDescription)
            }
            
            if let downloadPath = meta?.downloadURL()?.absoluteString {
                self.profileImageUrl = downloadPath
            }
        }
    }
}

extension SignUpEditProfileVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkSholdEnableButton()
    }
}

extension SignUpEditProfileVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkSholdEnableButton()
    }
}

extension SignUpEditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoBtn.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            uploadToStorage(editedImage)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoBtn.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            uploadToStorage(originalImage)
        }
        dismiss(animated: true, completion: nil)
    }
}










