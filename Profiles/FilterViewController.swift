//
//  FilterViewController.swift
//  Passport-Challenge
//
//  Created by Harry J Wynn IV on 5/24/17.
//  Copyright © 2017 Harry J Wynn IV. All rights reserved.
//

import UIKit
import XLForm

class FilterViewController: XLFormViewController {

    var filterOptions = [String: String]()
    
    fileprivate struct Tags {
        static let Field = "field"
        static let Direction = "direction"
        static let Gender = "gender"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    func initializeForm() {
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor

        form = XLFormDescriptor(title: "View Options")
        
        // sorting
        section = XLFormSectionDescriptor.formSection(withTitle: "Sorting")
        section.footerTitle = "Set the sorting for all profiles."
        form.addFormSection(section)
        
        // sorting field
        row = XLFormRowDescriptor(tag: Tags.Field, rowType:XLFormRowDescriptorTypeSelectorPush, title:"Field")
        row.selectorOptions = [XLFormOptionsObject(value: "name", displayText: "Name"),
                               XLFormOptionsObject(value: "age", displayText:"Age"),
                               XLFormOptionsObject(value: "default", displayText:"Default")
        ]
        section.addFormRow(row)
        
        
        // sorting direction
        row = XLFormRowDescriptor(tag: Tags.Direction, rowType:XLFormRowDescriptorTypeSelectorPush, title:"Direction")
        row.selectorOptions = [XLFormOptionsObject(value: "ascending", displayText: "Ascending"),
                               XLFormOptionsObject(value: "descending", displayText:"Descending"),
                               XLFormOptionsObject(value: "default", displayText:"Default")
        ]
        section.addFormRow(row)
        
        
        // filtering
        section = XLFormSectionDescriptor.formSection(withTitle: "Filtering")
        section.footerTitle = "Set the filtering for all profiles."
        form.addFormSection(section)
        
        
        // gender filter
        row = XLFormRowDescriptor(tag: Tags.Gender, rowType:XLFormRowDescriptorTypeSelectorPush, title:"Gender")
        row.selectorOptions = [XLFormOptionsObject(value: "male", displayText: "Male"),
                               XLFormOptionsObject(value: "female", displayText:"Female"),
                               XLFormOptionsObject(value: "all", displayText:"All")
        ]
        section.addFormRow(row)
        
        self.form = form
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load existing options
        filterOptions = UserDefaults.standard.object(forKey: "FilterOptions") as! Dictionary

        // set existing values
        form.formRow(withTag: Tags.Field)?.value = XLFormOptionsObject(value: filterOptions["field"], displayText:String.capitalizeFirstLetter(filterOptions["field"]!))
        form.formRow(withTag: Tags.Direction)?.value = XLFormOptionsObject(value: filterOptions["direction"], displayText:String.capitalizeFirstLetter(filterOptions["direction"]!))
        form.formRow(withTag: Tags.Gender)?.value = XLFormOptionsObject(value: filterOptions["gender"], displayText:String.capitalizeFirstLetter(filterOptions["gender"]!))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // field filter value
        let fieldDescriptor = form.formRow(withTag: Tags.Field)!
        
        if let field = fieldDescriptor.value as? XLFormOptionsObject {
            filterOptions["field"] = field.formValue() as? String
        }
        
        // direction filter value
        let directionDescriptor = form.formRow(withTag: Tags.Direction)!
        
        if let direction = directionDescriptor.value as? XLFormOptionsObject {
            filterOptions["direction"] = direction.formValue() as? String
        }
        
        // gender filter value
        let genderDescriptor = form.formRow(withTag: Tags.Gender)!
        
        if let gender = genderDescriptor.value as? XLFormOptionsObject {
            filterOptions["gender"] = gender.formValue() as? String
        }

        // save the options
        UserDefaults.standard.set(filterOptions, forKey: "FilterOptions")
        UserDefaults.standard.synchronize()
    }
}
