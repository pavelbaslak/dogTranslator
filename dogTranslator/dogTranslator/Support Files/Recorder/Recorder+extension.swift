//
//  Recorder+extension.swift
//  dogTranslator
//
//  Created by Stas Dashkevich on 11.12.22.
//

import Foundation
import AVFoundation
import UIKit

// MARK: Delegate
public protocol RecorderDelegate: NSObject, AVAudioRecorderDelegate {
    func recorderDidFailToAchievePermission(_ recorder: Recorder)
    func recorder(_ recorder: Recorder, didCaptureDecibels decibels: Int)
}
public class Recorder {
    
    // MARK: Values for show sound information
    private var isMonitoring = false
    private var timer: Timer!
    private var decibelsForMath: [Int] = []
    
    public var seconds: Double = 0.0
    
    public var decibels: [Int] = Array(repeating: 0, count: 60)

    public var avg: Int? {
        if decibelsForMath.count != 0 {
            return decibelsForMath.reduce(0) { $0 + $1 } / decibelsForMath.count
        }
        
        return 0
    }
    
    public var min: Int? {
        return decibelsForMath.min()
    }
    
    public var max: Int? {
        return decibelsForMath.max()
    }
    
    // MARK: Session and recorder
    public var session:  AVAudioSession!
    private var recorder: AVAudioRecorder!
    
    // MARK: Delegates
    public var delegate: RecorderDelegate?
    public var avDelegate: AVAudioRecorderDelegate?
    
}

// MARK: Start
extension Recorder {
    
    public func record(_ delegate: AVAudioRecorderDelegate) {
        decibels = Array(repeating: 0, count: 60)
        decibelsForMath = []
        
        session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print(error)
        }
        
        checkPermissionAndStartRecording()
    }
    
    private func startRecording() {
        let audioFilename = getDocumentDirectory().appendingPathComponent("newRecording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 24000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: audioFilename, settings: settings as [String : Any])
            recorder.delegate = self.avDelegate
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
            recorder.record()
        } catch {
            print(error)
        }
    }
    
    private func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func checkPermissionAndStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            startRecording()
            startMonitoring()
        case .undetermined:
            requestPermissions()
        case .denied:
            DispatchQueue.main.async {
                self.delegate?.recorderDidFailToAchievePermission(self)

            }
            print("denied")
        @unknown default:
            requestPermissions()
        }
    }
    
    private func requestPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.startRecording()
                    self.startMonitoring()
                } else {
                    self.checkPermissionAndStartRecording()
                }
            }
        }
    }
}

// MARK: Stop
extension Recorder {
    
    public func stop() {
        if recorder != nil {
            recorder.stop()
        }
       
        recorder = nil
        session  = nil
        
        decibelsForMath = []
        decibels        = Array(repeating: 0, count: 60)
    }
}


// MARK: Decibels logic
extension Recorder {
    
    private func getDecibels() -> Float {
        recorder.updateMeters()
        return 96 - abs(recorder.averagePower(forChannel: 0))
    }
    
    public func startMonitoring() {
        if recorder != nil {
            isMonitoring = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if !self.isMonitoring {
                    timer.invalidate()
                } else {
                    self.delegate?.recorder(self, didCaptureDecibels: Int(self.getDecibels()))
                    self.seconds = Double(self.recorder.currentTime)
                    if self.decibels.count <= 60 {
                        self.decibels.append(Int(self.getDecibels()))
                    } else {
                        self.decibels.remove(at: 0)
                        self.decibels.append(Int(self.getDecibels()))
                        self.decibelsForMath.append(Int(self.getDecibels()))
                    }
                }
            }
        }
    }
    
    public func stopMonitoring() {
        isMonitoring = false
        
        if isMonitoring == false, timer != nil {
            timer.invalidate()
        }
    }
}
