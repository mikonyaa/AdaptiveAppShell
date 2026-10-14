import Observation
import SwiftUI
import UIKit

@MainActor
final class StudioWindowReference {
    weak var window: UIWindow?
}

struct StudioWindowReader: UIViewRepresentable {
    let reference: StudioWindowReference

    func makeUIView(context: Context) -> WindowProbe {
        WindowProbe(reference: reference)
    }

    func updateUIView(_ uiView: WindowProbe, context: Context) {
        reference.window = uiView.window
    }

    final class WindowProbe: UIView {
        let reference: StudioWindowReference

        init(reference: StudioWindowReference) {
            self.reference = reference
            super.init(frame: .zero)
            isUserInteractionEnabled = false
            accessibilityElementsHidden = true
        }

        required init?(coder: NSCoder) { return nil }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            reference.window = window
        }
    }
}

@MainActor
enum WindowSnapshot {
    static func capture(from window: UIWindow?) -> UIImage? {
        guard let window, !window.isHidden, !window.bounds.isEmpty else { return nil }
        return UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        }
    }
}

@MainActor
@Observable
final class StudioThemeTransition {
    private(set) var snapshot: UIImage?
    private(set) var opacity = 0.0
    @ObservationIgnored private var task: Task<Void, Never>?

    func start(in window: UIWindow?) {
        cancel()
        guard let snapshot = WindowSnapshot.capture(from: window) else { return }
        self.snapshot = snapshot
        opacity = 1
        task = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(70))
                guard let self else { return }
                withAnimation(.easeInOut(duration: 0.52)) { self.opacity = 0 }
                try await Task.sleep(for: .milliseconds(560))
                self.snapshot = nil
                self.task = nil
            } catch {
                return
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        snapshot = nil
        opacity = 0
    }
}
