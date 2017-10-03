//
//  MatchedProfilesVC.swift
//  KohZhanHwa_iOSFinalExam_TinderClone
//
//  Created by Alex Koh on 02/10/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MatchedProfilesVC: UIViewController {
    
    var currentUser: User = User()
    var matchedUsers: [User] = []
    var matchedUsersUid: [String] = []
    var allUsers : [User] = []

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var refreshBtn: UIButton!
    @IBAction func refreshContent(_ sender: Any) {
        print(allUsers.count)
        print(matchedUsersUid.count)
        print(matchedUsers.count)
        
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
        tableView.reloadData()
        
        if matchedUsers.count == 0 {
            createErrorVC("Your match list is empty!", "Go back profileVC and click choose new candidate to choose new match")
        }
        refreshBtn.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        extractAllUsersFromFirebase()
        extractAllMatchedUsersIdFromFirebase()
        refreshBtn.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        matchedUsers.removeAll()
        matchedUsersUid.removeAll()
        allUsers.removeAll()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func createErrorVC(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension MatchedProfilesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = matchedUsers[indexPath.row].name
        cell.detailTextLabel?.text = matchedUsers[indexPath.row].age
        
        return cell
    }
}

extension MatchedProfilesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = matchedUsers[indexPath.row]
        
        guard let candidateVC = storyboard?.instantiateViewController(withIdentifier: "CandidateDetailVC") as? CandidateDetailVC else {return}
        
        candidateVC.currentUser = selectedUser
        candidateVC.matchListsUserId = matchedUsersUid
        candidateVC.currentIndex = indexPath.row
        
        navigationController?.pushViewController(candidateVC, animated: true)
        
    }
}












