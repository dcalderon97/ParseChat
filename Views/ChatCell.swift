//
//  ChatCell.swift
//  ParseChat
//
//  Created by Daniel Calderon on 2/24/18.
//  Copyright © 2018 Daniel Calderon. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {


    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.cornerRadius = 10
        bubbleView.clipsToBounds = true
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
