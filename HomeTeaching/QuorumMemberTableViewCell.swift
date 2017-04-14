//
//  QuorumMemberTableViewCell.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/8/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit

class QuorumMemberTableViewCell: UITableViewCell {
    
    @IBOutlet var quorumMemberName : UILabel!
    
    var quorumMember : QuorumMember? {
        didSet {
            quorumMemberChanged()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func quorumMemberChanged() {
        if self.quorumMemberName != nil {
            self.quorumMemberName.text = quorumMember?.displayName()
        }
    }

}
