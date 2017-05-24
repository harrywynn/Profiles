//
//  EditProfileViewController.swift
//  Passport-Challenge
//
//  Created by Harry J Wynn IV on 5/23/17.
//  Copyright © 2017 Harry J Wynn IV. All rights reserved.
//

import UIKit
import RandomKit
import FirebaseDatabase
import Firebase
import XLForm

class EditProfileViewController: XLFormViewController {

    fileprivate struct Tags {
        static let Name = "name"
        static let Age = "age"
        static let Hobbies = "hobbies"
        static let Avatar = "avatar"
        static let Gender = "gender"
        static let Push = "selectorPush"
    }
    
    
    public var profile: Profile?
    
    public var isPushed: Bool = false
    
    var ref: FIRDatabaseReference!
    
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.isPushed) {
            self.title = "Edit Profile"
        } else {
            self.title = "Add Profile"
        }
        
        // database
        ref = FIRDatabase.database().reference(withPath: "profiles")
        
        // for saving
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(EditProfileViewController.savePressed(_:)))
        
        // fill in form with our profile values
        if (profile != nil) {
            form.formRow(withTag: Tags.Name)?.value = profile?.name
            form.formRow(withTag: Tags.Gender)?.value = profile?.gender
            form.formRow(withTag: Tags.Age)?.value = profile?.age
            form.formRow(withTag: Tags.Hobbies)?.value = profile?.hobbies
            
            let avatarData: NSData = NSData(base64Encoded: (profile?.avatar)!, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
            form.formRow(withTag: Tags.Avatar)?.value = UIImage(data:avatarData as Data, scale:1.0)
        }
    }
    
    
    // MARK: instance methods
    
    func initializeForm() {
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor(title: "Profile")
     
        section = XLFormSectionDescriptor.formSection(withTitle: "Profile Data")
        
        form.addFormSection(section)
        
        
        // name
        row = XLFormRowDescriptor(tag: Tags.Name, rowType: XLFormRowDescriptorTypeText, title: "Name")
        row.isRequired = true
        section.addFormRow(row)
        
        // gender
        row = XLFormRowDescriptor(tag: Tags.Gender, rowType:XLFormRowDescriptorTypeSelectorPush, title:"Gender")
        row.selectorOptions = [XLFormOptionsObject(value: "Male", displayText: "Male"),
                               XLFormOptionsObject(value: "Female", displayText:"Female")]
        row.isRequired = true
        section.addFormRow(row)
        
        // age
        row = XLFormRowDescriptor(tag: Tags.Age, rowType: XLFormRowDescriptorTypeNumber, title: "Age")
        row.isRequired = true
        section.addFormRow(row)
        
        // avatar
        row = XLFormRowDescriptor(tag: Tags.Avatar, rowType: XLFormRowDescriptorTypeImage, title: "Avatar")
        row.value = UIImage(named: "default_avatar")
        row.isRequired = true
        section.addFormRow(row)
        
        // hobbies
        row = XLFormRowDescriptor(tag: Tags.Hobbies, rowType: XLFormRowDescriptorTypeTextView)
        row.cellConfigAtConfigure["textView.placeholder"] = "Hobbies"
        row.isRequired = true
        section.addFormRow(row)
        
        self.form = form
    }

    func savePressed(_ button: UIBarButtonItem) {
        let array = formValidationErrors()
        
        if ((array?.count)! > 0) {
            for errorItem in array! {
                let error = errorItem as! NSError
                let validationStatus : XLFormValidationStatus = error.userInfo[XLValidationStatusErrorKey] as! XLFormValidationStatus
                if let rowDescriptor = validationStatus.rowDescriptor, let indexPath = form.indexPath(ofFormRow: rowDescriptor), let cell = tableView.cellForRow(at: indexPath) {
                    self.animateCell(cell)
                }
            }
        } else {
            // create a new profile if we need to
            if (profile == nil) {
                profile = Profile.init()
            }
            
            // save image as Base64 encoded string
            let imageDescriptor = form.formRow(withTag: Tags.Avatar)!
            
            if let avatar = imageDescriptor.value as? UIImage {
                let avatarData:NSData = UIImageJPEGRepresentation(avatar, 0.5)! as NSData
                let avatarStr = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                profile?.avatar = avatarStr
            }
            
            // get gender option
            let genderDescriptor = form.formRow(withTag: Tags.Gender)!
            
            if let gender = genderDescriptor.value as? XLFormOptionsObject {
                profile?.gender = gender.formValue() as? String
            }

            profile?.name = form.formRow(withTag: Tags.Name)?.value as! String
            profile?.age = form.formRow(withTag: Tags.Age)?.value as! Int
            profile?.hobbies = form.formRow(withTag: Tags.Hobbies)?.value as! String

            // save it
            let profileRef = self.ref.child((profile?.id!.description)!);
            profileRef.setValue(profile?.serialize())
            
            // go back
            if (self.isPushed) {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: {})
            }
        }
    }
    
    func animateCell(_ cell: UITableViewCell) {
        // animate cell on form errors
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values =  [0, 20, -20, 10, 0]
        animation.keyTimes = [0, NSNumber(value: 1 / 6.0), NSNumber(value: 3 / 6.0), NSNumber(value: 5 / 6.0), 1]
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.isAdditive = true
        cell.layer.add(animation, forKey: "shake")
    }
}
