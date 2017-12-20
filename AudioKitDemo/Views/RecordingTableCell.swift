//
//  RecordingTableCell.swift
//  Mena Test Project
//
//  Created by Karun Aggarwal on 20/12/17.
//  Copyright © 2017 modacity. All rights reserved.
//

import UIKit

class RecordingTableCell: UITableViewCell {

    @IBOutlet weak var labelRecording: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnPlayAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PlayAudio"), object: sender.tag)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "PlayAudio"))
    }   
    
}
