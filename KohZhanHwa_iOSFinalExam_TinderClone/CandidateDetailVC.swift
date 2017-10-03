//
//  CandidateDetailVC.swift
//  KohZhanHwa_iOSFinalExam_TinderClone
//
//  Created by Alex Koh on 02/10/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CandidateDetailVC: UIViewController {

    var currentUser: User = User()
    var matchListsUserId: [String] = []
    var currentIndex: Int = 0
    
    @IBOutlet weak var profileImageImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    @IBAction func unmatchBtnTapped(_ sender: Any) {
        Database.database().reference().child("MatchedLists").observe(.childAdded) { (snapshot) in
            guard let info = snapshot.value as? [String:Any] else {return}
            
            if let owner = info["owner"] as? String,
                let matches = info["matches"] as? [String] {
                
                //find out which matchLists belong to the current user
                if owner == self.currentUser.randomId {
                    
                    self.matchListsUserId.remove(at: self.currentIndex)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        descriptionTextView.text = description
        
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
                    self.profileImageImageView.image = UIImage(data: data)
                }
            }
        }
        task.resume()
    }
    
    


}
