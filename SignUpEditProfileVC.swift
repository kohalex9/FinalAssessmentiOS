//
//  SignUpEditProfileVC.swift
//  KohZhanHwa_iOSFinalExam_TinderClone
//
//  Created by Alex Koh on 02/10/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import Foundation
import UIKit


class SignUpEditProfileVC: UIViewController {
    
    var isSignUp: Bool = false
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var selfDescriptionTextView: UITextView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var editProfileBtn: UIButton!
    
    @IBAction func plusPhotoBtnTapped(_ sender: Any) {
    }
    
    @IBAction func signUpBtnTapped(_ sender: Any) {
    }
    
    @IBAction func editProfileBtnTapped(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        if isSignUp {
            signUpBtn.isHidden = false
            editProfileBtn.isHidden = true
        } else {
            signUpBtn.isHidden = true
            editProfileBtn.isHidden = false
        }
    }
}
