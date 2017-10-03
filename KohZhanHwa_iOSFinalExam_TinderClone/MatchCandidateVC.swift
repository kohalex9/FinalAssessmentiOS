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

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    func extractAllMatchedUsersIdFromFirebase() {
        Database.database().reference().child("MatchedLists").observe(.childAdded) { (snapshot) in
            guard let info = snapshot.value as? [String:Any] else {return}
            
            if let owner = info["owner"] as? String,
                let matches = info["matches"] as? [String] {
                
                //find out which matchLists belong to the current user
                if owner == self.currentUser.randomId {
                    self.matchedUsersUid = matches
                }
            }
        }
    }
    
    func extractAllUsersFromFirebase() {
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
                
                self.allUsers.append(newUser)
            }
        })
    }
    
    @IBAction func matchBtnTapped(_ sender: Any) {
//        guard let randomId = currentUser.randomId else {return}
//        if currentUser.matchListId == "" {
//            //create new child at firebase
//            let info: [String: Any] = ["matches": [displayUser.randomId]]
//            Database.database().reference().child("MatchedLists").child(randomId).setValue(info)
//
//        } else {
//            //update the child at firebase
//            matchedUsersUid.append(randomId)
//
//            let info: [String: Any] = ["matches": matchedUsersUid]
//            Database.database().reference().child("MatchedLists").child(randomId).updateChildValues(info)
//        }
    }
    
    @IBAction func skipBtnTapped(_ sender: Any) {
        loadNewUser()
    }
    
    func loadNewUser() {
        if currentIndex == allUsers.count {
            currentIndex = 0
        }
        
        var user = allUsers[currentIndex]
        
        if user.randomId == currentUser.randomId {
            user = allUsers[currentIndex + 1]
            guard let name = user.name,
                let profileImgUrl = user.profileImgUrl else {return}
            
            displayUser = user
            nameLabel.text = name
            loadImage(urlString: profileImgUrl)        }
        
        if user.randomId != currentUser.randomId {
            guard let name = user.name,
                let profileImgUrl = user.profileImgUrl else {return}
            
            displayUser = user
            nameLabel.text = name
            loadImage(urlString: profileImgUrl)
        }

        print(displayUser.name)
        currentIndex += 1
    }
    
    @IBAction func refreshBtnTapped(_ sender: Any) {
        
        loadNewUser()

        for user in allUsers {
            if let userId = user.randomId {
                for matchId in matchedUsersUid {
                    if matchId == userId {
                        matchedUsers.append(user)
                        break
                    }
                }
            }
        }
        
        print(matchedUsers.count)
        print(matchedUsersUid.count)
        print(allUsers.count)
        refreshAllArrayData()
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
    
    func createUnmatchedUsers() {
        var cloneAllUsers = allUsers
        
        //        for (i, user) in cloneAllUsers.enumerated() {
        //            if cloneAllUsers.count == 0 {
        //                return
        //            }
        //            for matchedUser in matchedUsers {
        //                if user.randomId == matchedUser.randomId {
        //                    continue
        //                } else {
        //                unmatchedUsers.append(cloneAllUsers.remove(at: i))
        //                }
        //            }
        //        }
    }
    
    func refreshAllArrayData() {
        matchedUsers.removeAll()
        matchedUsersUid.removeAll()
        //allUsers.removeAll()
        extractAllMatchedUsersIdFromFirebase()
        extractAllMatchedUsersIdFromFirebase()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        extractAllUsersFromFirebase()
        extractAllMatchedUsersIdFromFirebase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func createErrorVC(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
