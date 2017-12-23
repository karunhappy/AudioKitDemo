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
    
    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKAudioPlayer!
    var tape: AKAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var delay: AKDelay!
    var mainMixer: AKMixer!
    
    let mic = AKMicrophone()
    
    var recordingArray = [AKAudioFile]()
    var recordingUrl = [URL]()
    
    var state = State.readyToRecord
    
    enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
        
    }
    
    var flagPlayRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    segmentBottom.removeBorders()
        
        self.initialSetup()
        //        setupUIForPlaying()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playAudio(obj:)), name: NSNotification.Name(rawValue: "PlayAudio"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialSetup() {
        
        // Clean tempFiles !
        AKAudioFile.cleanTempDirectory()
        
        // Session settings
        AKSettings.bufferLength = .medium
        
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }
        
        AKSettings.defaultToSpeaker = true
        
        // Patching
        //        inputPlot.node = mic
        if flagPlayRecording == false {
            micMixer = AKMixer(mic)
        }
        micBooster = AKBooster(micMixer)
        
        // Will set the level of microphone monitoring
        micBooster.gain = 0
        recorder = try? AKNodeRecorder(node: micMixer)
        if let file = recorder.audioFile {
            player = try? AKAudioPlayer(file: file)
        }
        player.looping = false
        player.completionHandler = playingEnded
        
        moogLadder = AKMoogLadder(player)
        
        mainMixer = AKMixer(moogLadder, micBooster)
        
        AudioKit.output = mainMixer
        AudioKit.start()
        
        setupUIForRecording()
        flagPlayRecording = false
    }
    
    func playingEnded() {
        DispatchQueue.main.async {
            self.setupUIForPlaying ()
        }
    }
    
    @IBAction func btnRecordAudioAction(_ sender: UIButton) {
        //        if sender.title(for: .normal) == RecordTitle.record.rawValue {
        //            sender.setTitle(RecordTitle.done.rawValue, for: .normal)
        //        } else {
        //            sender.setTitle(RecordTitle.record.rawValue, for: .normal)
        //        }
        switch state {
        case .readyToRecord :
            if flagPlayRecording {
                self.initialSetup()
            }
            //            infoLabel.text = "Recording"
            //            mainButton.setTitle("Stop", for: .normal)
            sender.setTitle(RecordTitle.done.rawValue, for: .normal)
            state = .recording
            // microphone will be monitored while recording
            // only if headphones are plugged
            if AKSettings.headPhonesPlugged {
                micBooster.gain = 1
            }
            do {
                try recorder.record()
            } catch { print("Errored recording.") }
            
        case .recording :
            // Microphone monitoring is muted
            micBooster.gain = 0
            do {
                try player.reloadFile()
            } catch { print("Errored reloading.") }
            
            let recordedDuration = player != nil ? player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                recorder.stop()
                
                let audiofilename = "Recording-" + (self.recordingArray.count + 1).description + ".m4a"
                player.audioFile.exportAsynchronously(name: audiofilename,
                                                      baseDir: .documents,
                                                      exportFormat: .m4a) { audiofile, exportError in
                                                        self.recordingArray.append(audiofile!)
                                                        self.recordingUrl.append((audiofile?.url)!)
                                                        print("recorded audios: ", self.recordingArray)
                                                        print("recorded urls: ", self.recordingUrl)
                                                        self.tableViewRecordings.reloadData()
                                                        
                                                        self.reset()
                                                        if let error = exportError {
                                                            print("Export Failed \(error)")
                                                        } else {
                                                            print("Export succeeded")
                                                        }
                }
                //                player.stop()
                //                setupUIForPlaying ()
                setupUIForRecording()
            }
        case .readyToPlay :
            break
            //            player.play()
            //            infoLabel.text = "Playing..."
            //            mainButton.setTitle("Stop", for: .normal)
            //            sender.setTitle(RecordTitle.done.rawValue, for: .normal)
        //            state = .playing
        case .playing :
            break
            //            player.stop()
            //            setupUIForPlaying()
        }
    }
    
    func setupUIForRecording () {
        //        player.stop()
        //        player.looping = false
        //        do {
        //            try recorder.reset()
        //        } catch { print("Errored resetting.") }
        
        state = .readyToRecord
        btnRecordAudio.setTitle(RecordTitle.record.rawValue, for: .normal)
        //        resetButton.isEnabled = false
        //        resetButton.isHidden = true
        micBooster.gain = 0
        //        setSliders(active: false)
    }
    
    func setupUIForPlaying () {
        //        let recordedDuration = player != nil ? player.audioFile.duration  : 0
        //        infoLabel.text = "Recorded: \(String(format: "%0.1f", recordedDuration)) seconds"
        
        btnRecordAudio.setTitle(RecordTitle.done.rawValue, for: .normal)
        state = .readyToPlay
        //        resetButton.isHidden = false
        //        resetButton.isEnabled = true
        //        setSliders(active: true)
        //        frequencySlider.value = moogLadder.cutoffFrequency
        //        resonanceSlider.value = moogLadder.resonance
    }
    
    func reset() {
        player.stop()
        player.looping = false
        do {
            try recorder.reset()
        } catch { print("Errored resetting.") }
    }
    
    @IBAction func segmentTopAction(_ sender: UISegmentedControl) {
        sender.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    @IBAction func segmentBottomAction(_ sender: UISegmentedControl) {
        sender.selectedSegmentIndex = UISegmentedControlNoSegment
        //        sender.tintColor = UIColor.black
        //        (sender.subviews[sender.selectedSegmentIndex][0] as! UILabel).textColor = UIColor.black
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingTableCell", for: indexPath) as! RecordingTableCell
        
        let index = indexPath.row
        
        cell.labelRecording.text = (self.recordingArray[index]).fileName
        cell.btnPlay.tag = index
        
        return cell
    }
    
    @objc func playAudio(obj: Notification) {
        let audio = obj.object as! Int
        //        do {
        //            let p = try self.player.audioFile.appendedBy(file: self.recordingArray[audio])
        //            p.player?.play()
        //        } catch { print("Errored reloading.") }
        
        //        recorder = try? AKNodeRecorder(node: micMixer, file: self.recordingArray[audio])
        //
        //
        //        if let file = recorder.audioFile {
        //            player = try? AKAudioPlayer(file: file)
        //        }
        //        player.play()
        flagPlayRecording = true
        //        AKAudioFile(readFileName: self.recordingArray[audio].fileName, baseDir: AKAudioFile.BaseDirectory.custom)
        do {
            //            guard
            
            //            let file = try? AKAudioFile(readFileName: self.recordingArray[audio].fileName, baseDir: AKAudioFile.BaseDirectory.custom)
            //            else { return }
            guard let file = try? AKAudioFile(forReading: self.recordingUrl[audio]) else { return }
            print(file, file.standard)
            let player = try AKAudioPlayer(file: (file))
            AudioKit.output = player
            AudioKit.start()
            player.play()
        } catch { print("error readiung file audio") }
        
        
        //        do {
        //            let pp = try? AKAudioPlayer(file: self.recordingArray[audio], looping: false, lazyBuffering: false, completionHandler: nil)
        //
        //            AudioKit.disconnectAllInputs()
        //
        //            var mMixer: AKMixer!
        //            var mBooster: AKBooster!
        //            var moLadder: AKMoogLadder!
        //            var maMixer: AKMixer!
        //            let micc = AKMicrophone()
        //
        //            mMixer = AKMixer(micc)
        //            mBooster = AKBooster(mMixer)
        //
        //            // Will set the level of microphone monitoring
        //            mBooster.gain = 0
        //            moLadder = AKMoogLadder(pp)
        //
        //            maMixer = AKMixer(moLadder, mBooster)
        //
        //            AudioKit.output = maMixer
        //            AudioKit.start()
        //
        //            pp?.start()
        //            pp?.play()
        //        } catch { print("pp file error") }
        
        //        self.initialSetup()
        //        do {
        //            let p = try? AKAudioPlayer(file: self.recordingArray[audio])
        //            p?.start()
        //            p?.play()
        //        } catch { print("Audio file") }
        //
        //        recorder = try? AKNodeRecorder(node: micMixer)
        //        if let file = recorder.audioFile {
        //            player = try? AKAudioPlayer(file: file)
        //        }
    }
}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.white), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        //        self.tintColor = UIColor.black
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: self.bounds.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

