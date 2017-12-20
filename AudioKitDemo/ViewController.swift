//
//  ViewController.swift
//  Mena Test Project
//
//  Created by Marc Gelfo on 12/16/17.
//  Copyright © 2017 modacity. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    @IBOutlet weak var segmentTop: UISegmentedControl!
    @IBOutlet weak var segmentBottom: UISegmentedControl!
    @IBOutlet weak var tableViewRecordings: UITableView!
    @IBOutlet weak var btnRecordAudio: UIButton!
    
    enum RecordTitle: String {
        case record = "Record Audio"
        case done = "Done"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnRecordAudioAction(_ sender: UIButton) {
        if sender.title(for: .normal) == RecordTitle.record.rawValue {
            sender.setTitle(RecordTitle.done.rawValue, for: .normal)
        } else {
            sender.setTitle(RecordTitle.record.rawValue, for: .normal)
        }
    }
    
    @IBAction func segmentTopAction(_ sender: UISegmentedControl) {
    }
    
    @IBAction func segmentBottomAction(_ sender: UISegmentedControl) {
    }
    
}
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingTableCell", for: indexPath)
        
        return cell
    }
}
