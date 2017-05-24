//
//  ProfileViewController.swift
//  Passport-Challenge
//
//  Created by Harry J Wynn IV on 5/24/17.
//  Copyright © 2017 Harry J Wynn IV. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var hobbies: UILabel!
    
    
    public var profile: Profile!
    
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Profile"

        // database
        ref = FIRDatabase.database().reference(withPath: "profiles")
        
        // for editing
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ProfileViewController.editProfile(_:)))
        navigationItem.rightBarButtonItem = editButton
        
        // round the image
        avatar.setRounded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set profile image
        let avatarData: NSData = NSData(base64Encoded: profile.avatar, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        avatar.image = UIImage(data:avatarData as Data, scale:1.0)
        
        // set personal data
        name.text = profile.name
        gender.text = profile.gender
        age.text = "\(profile.age!) Years Old"
        hobbies.text = profile.hobbies
        
        if (profile.gender == "Male") {
            self.view.backgroundColor = UIColor(hex: "87CEFA")
        } else {
            self.view.backgroundColor = UIColor(hex: "90EE90")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EDIT_PROFILE") {
            if let dest = segue.destination as? EditProfileViewController {
                dest.profile = self.profile
                dest.isPushed = true
            }
        }
    }
    
    
    
    // MARK: instance methods
    
    func editProfile(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "EDIT_PROFILE", sender: sender)
    }
    
    @IBAction func deleteProfile(_ sender: UIButton) {
        // confirm with the user
        let alertController = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)

        let  deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            // delete it
            let profileRef = self.ref.child((self.profile?.id!.description)!);
            profileRef.removeValue()
            self.navigationController?.popViewController(animated: true)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
}


