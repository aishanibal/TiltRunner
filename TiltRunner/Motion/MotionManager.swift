import CoreMotion
import Combine

/// Wraps CMMotionManager to expose left/right steering via device roll.
/// No Info.plist usage-description entry is required for deviceMotion.
final class MotionManager: ObservableObject {
    @Published var roll: Double = 0

    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 1.0 / 60.0

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            self.roll = motion.attitude.roll
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
