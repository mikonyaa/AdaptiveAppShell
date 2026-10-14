import UIKit
import XCTest
@testable import AdaptiveShellDemo

@MainActor
final class StudioWindowTests: XCTestCase {
    func testMissingWindowDoesNotCaptureAnUnrelatedScene() {
        XCTAssertNil(WindowSnapshot.capture(from: nil))
    }

    func testTransitionCancellationReleasesSnapshotAndStopsDelayedWork() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIViewController()
        window.isHidden = false
        defer { window.isHidden = true }
        let transition = StudioThemeTransition()
        transition.start(in: window)
        XCTAssertNotNil(transition.snapshot)
        transition.cancel()
        XCTAssertNil(transition.snapshot)
        try await Task.sleep(for: .milliseconds(750))
        XCTAssertNil(transition.snapshot)
        XCTAssertEqual(transition.opacity, 0)
    }

    func testSnapshotCapturesItsHostingWindowEvenWhenAnotherWindowIsKey() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 160, height: 120)
        window.rootViewController = UIViewController()
        window.rootViewController?.view.backgroundColor = .blue
        window.isHidden = false
        defer { window.isHidden = true }
        let snapshot = try XCTUnwrap(WindowSnapshot.capture(from: window))
        XCTAssertEqual(snapshot.size, window.bounds.size)
        XCTAssertFalse(window.isKeyWindow)
    }
}
