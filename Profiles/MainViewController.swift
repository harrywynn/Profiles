//
//  MainViewController.swift
//  Passport-Challenge
//
//  Created by Harry J Wynn IV on 5/23/17.
//  Copyright © 2017 Harry J Wynn IV. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class MainViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    var ref: FIRDatabaseReference!
    
    var filteredProfiles = [Profile]()
    var profiles = [Profile]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference(withPath: "profiles")

        ref.observe(.value, with: { snapshot in
            // make objects for each item
            var newProfiles: [Profile] = []

            for item in snapshot.children {
                let profile = Profile(snapshot: item as! FIRDataSnapshot)
                newProfiles.append(profile)
            }

            self.profiles = newProfiles
            
            // filter and redisplay
            self.filterProfiles()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filterProfiles()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ADD_PROFILE") {
            if let dest = segue.destination as? UINavigationController {
                dest.preferredContentSize = CGSize(width: 320, height: 338)

                if let controller = dest.popoverPresentationController {
                    controller.barButtonItem = addButton
                    controller.sourceView = self.view
                    controller.delegate = self
                }
            }
        } else if (segue.identifier == "LOAD_PROFILE") {
            if let dest = segue.destination as? ProfileViewController {
                dest.profile = self.filteredProfiles[(self.tableView.indexPathForSelectedRow?.row)!]
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
    // MARK: - Table view methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredProfiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)

        let profile = self.filteredProfiles[indexPath.row]

        cell.textLabel?.text = profile.name
        
        
        let avatarData: NSData = NSData(base64Encoded: profile.avatar, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        cell.imageView?.image = UIImage(data:avatarData as Data, scale:1.0)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }
    
    
    // MARK: instance methods
    
    @IBAction func filterView() {
        let filter = FilterViewController()
        self.navigationController?.pushViewController(filter, animated: true)
    }

    func filterProfiles() {
        if (UserDefaults.standard.object(forKey: "FilterOptions") == nil) {
            // these are the defaults
            var filterOptions = [String: String]()
            filterOptions["field"] = "default"
            filterOptions["direction"] = "default"
            filterOptions["gender"] = "all"
            
            // save the options
            UserDefaults.standard.set(filterOptions, forKey: "FilterOptions")
            UserDefaults.standard.synchronize()
            
        }
        
        // get the filter options from defaults
        let filterOptions = UserDefaults.standard.object(forKey: "FilterOptions") as! Dictionary<String, String>
        
        self.filteredProfiles = self.profiles
        
        // sort by name or age
        if (filterOptions["field"] != "default") {
            if (filterOptions["field"] == "name") {
                if (filterOptions["direction"] == "descending") {
                    self.filteredProfiles.sort(by: { $0.name > $1.name })
                } else {
                    self.filteredProfiles.sort(by: { $0.name < $1.name })
                }
            } else if (filterOptions["field"] == "age") {
                if (filterOptions["direction"] == "descending") {
                    self.filteredProfiles.sort(by: { $0.age > $1.age })
                } else {
                    self.filteredProfiles.sort(by: { $0.age < $1.age })
                }
            }
        } else {
            self.filteredProfiles.sort(by: { $0.id < $1.id })
        }
        
        // pull out specific gender
        if (filterOptions["gender"] != "all") {
            let filtered = self.filteredProfiles.filter {
                $0.gender == String.capitalizeFirstLetter(filterOptions["gender"]!)
            }
            
            self.filteredProfiles = filtered
        }

        // refresh table
        self.tableView.reloadData()
    }
    
}
