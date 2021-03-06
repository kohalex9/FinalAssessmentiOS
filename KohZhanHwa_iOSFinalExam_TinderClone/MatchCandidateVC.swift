//
//  MatchCandidateVC.swift
//  KohZhanHwa_iOSFinalExam_TinderClone
//
//  Created by Alex Koh on 02/10/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MatchCandidateVC: UIViewController {
    
    var currentIndex: Int = 0 //For change different user when tap refresh
    var displayUser : User = User()
    var currentUser: User = User()
    var matchedUsers: [User] = []
    var matchedUsersUid: [String] = []
    var allUsers : [User] = []
    var unmatchedUsers: [User] = []
    
    var sameAgeUser: [User] = []
    var sameGenderUser: [User] = []
    var noFilterUser: [User] = []

    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var matchBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var filterModeLabel: UILabel!
    @IBOutlet weak var refreshBtn: UIButton!
    
    func extractAllMatchedUsersIdFromFirebase() {
        if currentUser.matchListId == "" {
            currentUser.matchListId = currentUser.randomId
        }
        
        guard let currentUserMatchListId = currentUser.matchListId else {return}
        
        Database.database().reference().child("MatchedLists").child(currentUserMatchListId).child("matches").observe(.childAdded) { (snapshot) in
            guard let info = snapshot.value as? [String:Any] else {return}

            if let matchUserId = info["userId"] as? String {
                self.matchedUsersUid.append(matchUserId)
                
                for user in self.allUsers {
                    if let userId = user.randomId {
                        if userId == matchUserId {
                            self.matchedUsers.append(user)
                        }
                    }
                }
            }
        }
    }
    
    func extractAllUsersFromFirebase() {
       guard let currentUserAge = currentUser.age,
        let currenUserGender = currentUser.gender else {return}
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            guard let infoUser = snapshot.value as? [String:Any] else {return}
            
            if let profileImageUrl = infoUser["profileImageUrl"] as? String,
                let name = infoUser["name"] as? String,
                let age = infoUser["age"] as? String,
                let gender = infoUser["gender"] as? String,
                let email = infoUser["email"] as? String,
                let password = infoUser["password"] as? String,
                let description = infoUser["description"] as? String,
                let randomId = infoUser["randomId"] as? String,
                let matchListId = infoUser["matchListId"] as? String {
                
                let newUser = User()
                
                newUser.profileImgUrl = profileImageUrl
                newUser.name = name
                newUser.age = age
                newUser.gender = gender
                newUser.email = email
                newUser.password = password
                newUser.description = description
                newUser.randomId = randomId
                newUser.matchListId = matchListId
                
                self.noFilterUser.append(newUser)
                
                if currentUserAge == age {
                    self.sameAgeUser.append(newUser)
                }
                
                if currenUserGender == gender {
                    self.sameGenderUser.append(newUser)
                }
                
            }
        })
    }
    
    func createErrorVC(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func filterByAge(_ sender: Any) {
        allUsers = sameAgeUser
        filterModeLabel.text = "Filter Mode: Filter By Age"
        currentIndex = 0
        
        refreshBtn.isHidden = false
        matchBtn.isHidden = true
        
        self.viewDidLoad()
    }
    
    @IBAction func filterByGender(_ sender: Any) {
        allUsers = sameGenderUser
        filterModeLabel.text = "Filter Mode: Filter By Gender"
        currentIndex = 0
        
        refreshBtn.isHidden = false
        matchBtn.isHidden = true
        
        self.viewDidLoad()
    }
    
    @IBAction func noFilterBtn(_ sender: Any) {
        allUsers = noFilterUser
        filterModeLabel.text = "Filter Mode: No filter"
        currentIndex = 0
        
        refreshBtn.isHidden = false
        matchBtn.isHidden = true
        
        self.viewDidLoad()
    }
    
    
    @IBAction func matchBtnTapped(_ sender: Any) {
        guard let randomId = currentUser.randomId else {return}
        Database.database().reference().child("MatchedLists").child(randomId).child("matches").childByAutoId().child("userId").setValue(displayUser.randomId)
        
        currentUser.matchListId = randomId
        
        matchBtn.isHidden = true
        skipBtn.isHidden = true
    }
    
    @IBAction func skipBtnTapped(_ sender: Any) {
        loadNewUser()
    }
    
    func loadNewUser() {
        if allUsers.count == 0 {
            refreshBtn.isHidden = true
            matchBtn.isHidden = true
            skipBtn.isHidden = true
            createErrorVC("No more users matching your filter", "Please choose other filter")
            return
        }
        
        matchBtn.isHidden = false
        
        currentIndex += 1
        
        if currentIndex == allUsers.count {
            currentIndex = 0
        }
        
        let user = allUsers[currentIndex]
        
        //warn the user that no more matches matching the filter can be found
        if matchedUsers.count == allUsers.count - 1 {
            refreshBtn.isHidden = true
            matchBtn.isHidden = true
            skipBtn.isHidden = true
            createErrorVC("No more users matching your filter", "Please choose other filter")
            return
        }
        
        for eachMatchUser in matchedUsers {
            if user.randomId == eachMatchUser.randomId {
                loadNewUser()
                return
            }
        }
        
        if user.randomId != currentUser.randomId {
            guard let name = user.name,
                let profileImgUrl = user.profileImgUrl else {return}
            
            displayUser = user
            nameLabel.text = name
            loadImage(urlString: profileImgUrl)
        } else {
            loadNewUser()
            return
        }

        print(displayUser.name)
        print(matchedUsers.count)
        print(matchedUsersUid.count)
        print(allUsers.count)
        //refreshAllArrayData()

    }
    
    @IBAction func refreshBtnTapped(_ sender: Any) {
        
        matchBtn.isHidden = false
        skipBtn.isHidden = false
        
        loadNewUser()
        
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
                    self.profilePictureImageView.image = UIImage(data: data)
                }
            }
        }
        task.resume()
    }
    
    func refreshAllArrayData() {
        matchedUsers.removeAll()
        matchedUsersUid.removeAll()
        //allUsers.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        matchedUsersUid.removeAll()
//        matchedUsers.removeAll()
//        allUsers.removeAll()
        
        extractAllUsersFromFirebase()
        extractAllMatchedUsersIdFromFirebase()
    }

}
