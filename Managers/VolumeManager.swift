import SwiftUI
import MediaPlayer
import AVFoundation

@MainActor
class VolumeManager: ObservableObject {
    static let shared = VolumeManager()
    
    private var volumeView: MPVolumeView?
    private var audioSession: AVAudioSession?
    private var isActive = false
    private var lastVolume: Float = 0.5
    
    private init() {}
    
    func start() {
        guard !isActive else { return }
        isActive = true
        
        // Setup Audio Session
        let session = AVAudioSession.sharedInstance()
        self.audioSession = session
        do {
            try session.setCategory(.ambient, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            print("VolumeManager: Failed to activate audio session: \(error)")
        }
        
        lastVolume = session.outputVolume
        
        // Create hidden MPVolumeView to suppress system HUD
        let vv = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
        vv.alpha = 0.0001
        self.volumeView = vv
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(vv)
        }
        
        // Observe volume changes via NotificationCenter (avoids KVO concurrency issues)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(volumeDidChange),
            name: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil
        )
    }
    
    func stop() {
        isActive = false
        NotificationCenter.default.removeObserver(self)
        volumeView?.removeFromSuperview()
        volumeView = nil
        
        do {
            try audioSession?.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("VolumeManager: Failed to deactivate audio session: \(error)")
        }
    }
    
    @objc private func volumeDidChange(_ notification: Notification) {
        guard isActive else { return }
        guard let info = notification.userInfo,
              let reason = info["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String,
              reason == "ExplicitVolumeChange" else { return }
        
        guard let newVolume = info["AVSystemController_AudioVolumeNotificationParameter"] as? Float else { return }
        
        let diff = newVolume - lastVolume
        lastVolume = newVolume
        
        if diff > 0.001 {
            // Volume Up -> Zoom In
            triggerZoom(1.0)
        } else if diff < -0.001 {
            // Volume Down -> Zoom Out
            triggerZoom(-1.0)
        }
    }
    
    private func triggerZoom(_ value: Float) {
        GameManager.shared.zoomInput = value
        
        // Reset zoom input after a short delay (impulse)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            GameManager.shared.zoomInput = 0
        }
    }
}
