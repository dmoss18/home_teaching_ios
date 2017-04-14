//
//  AssignmentCollectionViewCell.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/1/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit

class AssignmentTableViewCell: UITableViewCell {
    @IBOutlet var householdName : UILabel!
    
    var assignment : Assignment? {
        didSet {
            assignmentChanged()
        }
    }
    
    override func awakeFromNib() {
        assignmentChanged()
    }
    
    func assignmentChanged() {
        if self.householdName != nil {
            self.householdName.text = assignment?.household?.name
        }
    }
}
