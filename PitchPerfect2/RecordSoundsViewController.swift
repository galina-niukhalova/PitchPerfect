//
//  RecordSoundsViewController.swift
//  PitchPerfect2
//
//  Created by Galina Niukhalova on 6/12/20.
//

import UIKit
import AVFoundation

// AVAudioRecorderDelegate - protocol
class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    var audioRecorder: AVAudioRecorder!
    var session: AVAudioSession!
    
    struct RecordingLabels {
        static let InProgress = "Recording in Progress"
        static let StartRecording = "Tap to Record"
    }
    
    // MARK: Alerts
    
    struct Alerts {
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecorderError = "Audio Recorder Error"
    }
    
    func showAlerts(message: String) {
        print(message)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getRecordedFilePath() -> URL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        return filePath!
    }
    
    func configureUI(recording: Bool) {
        if recording {
            recordingLabel.text = RecordingLabels.InProgress
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
        } else {
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            recordingLabel.text = RecordingLabels.StartRecording
        }
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        configureUI(recording: true)
        
        let filePath = getRecordedFilePath()

        // We need it to record or play back audio
        // Shared session across all apps on a device
        session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
            
            try audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
        } catch {
            showAlerts(message: Alerts.AudioSessionError)
        }
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        configureUI(recording: false)
        
        audioRecorder.stop()
        try! session.setActive(false)
    }
    
    // MARK: - Audio Recorder Delegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            // sent url of recorder file to the second screen
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            showAlerts(message: Alerts.AudioRecorderError)
        }
    }
    
    // sender comes from performSegue sender - in our case it is audioRecorder.url
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

