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
    var currentDisplayUser: User = User() //Currently displaying user
    var matchListsUserId: [String] = []
    var currentIndex: Int = 0
    
    @IBOutlet weak var profileImageImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func backBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unmatchBtnTapped(_ sender: Any) {
       guard let currentUserMatchListId = currentUser.matchListId,
               let currentDisplayUserRandomId = currentDisplayUser.randomId else {return}
        Database.database().reference().child("MatchedLists").child(currentUserMatchListId).child("matches").observe(.childAdded) { (snapshot) in
            guard let info = snapshot.value as? [String:Any] else {return}
            let currentChildId = snapshot.key
            
            if let matchUserId = info["userId"] as? String {
                if matchUserId == currentDisplayUserRandomId {
                    Database.database().reference().child("MatchedLists").child(currentUserMatchListId).child("matches").child(currentChildId).removeValue()
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialView()
    }
    
    func setupInitialView() {
        guard let profileImageUrl = currentUser.profileImgUrl,
            let name = currentDisplayUser.name,
            let age = currentDisplayUser.age,
            let gender = currentDisplayUser.gender,
            let email = currentDisplayUser.email,
            let description = currentDisplayUser.description else {return}
        
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
