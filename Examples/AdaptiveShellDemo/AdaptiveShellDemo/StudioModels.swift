import AdaptiveAppShell
import Foundation
import SwiftUI

enum StudioTab: String, Hashable, CaseIterable, Sendable {
    case overview
    case projects
    case activity
    case search
    case settings
    case clientWork
    case internalWork
    case archive

    static let sections: [AdaptiveShellSection<StudioTab>] = [
        AdaptiveShellSection(
            id: "primary",
            items: [
                AdaptiveShellItem(
                    id: .overview,
                    title: "Overview",
                    systemImage: "house",
                    selectedSystemImage: "house.fill"
                ),
                AdaptiveShellItem(
                    id: .projects,
                    title: "Projects",
                    systemImage: "folder",
                    selectedSystemImage: "folder.fill"
                ),
                AdaptiveShellItem(
                    id: .activity,
                    title: "Activity",
                    systemImage: "waveform.path.ecg"
                ),
                AdaptiveShellItem(
                    id: .search,
                    title: "Search",
                    systemImage: "magnifyingglass"
                ),
                AdaptiveShellItem(
                    id: .settings,
                    title: "Settings",
                    systemImage: "gearshape",
                    selectedSystemImage: "gearshape.fill"
                )
            ]
        ),
        AdaptiveShellSection(
            id: "collections",
            title: "Collections",
            items: [
                AdaptiveShellItem(
                    id: .clientWork,
                    title: "Client work",
                    systemImage: "briefcase",
                    selectedSystemImage: "briefcase.fill",
                    compactPlacement: .hidden
                ),
                AdaptiveShellItem(
                    id: .internalWork,
                    title: "Internal",
                    systemImage: "building.2",
                    selectedSystemImage: "building.2.fill",
                    compactPlacement: .hidden
                ),
                AdaptiveShellItem(
                    id: .archive,
                    title: "Archive",
                    systemImage: "archivebox",
                    selectedSystemImage: "archivebox.fill",
                    compactPlacement: .hidden
                )
            ]
        )
    ]
}

enum StudioRoute: Hashable, Sendable {
    case project(String)
    case task(String)
}

enum StudioSheet: Identifiable {
    case newProject
    case profile

    var id: String {
        switch self {
        case .newProject:
            "new-project"
        case .profile:
            "profile"
        }
    }
}

enum StudioProjectStatus: String, Hashable, Sendable {
    case onTrack = "On track"
    case atRisk = "At risk"
    case complete = "Complete"
}

enum StudioCollection: String, Hashable, Sendable {
    case client
    case internalWork
    case archive
}

struct StudioProject: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let category: String
    let dueText: String
    let progress: Double
    let status: StudioProjectStatus
    let collection: StudioCollection
    let systemImage: String
    let ownerInitials: [String]
    let tasks: [StudioTask]
}

struct StudioTask: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let dueText: String
    let isComplete: Bool
}

struct StudioActivity: Identifiable, Hashable, Sendable {
    let id: String
    let initials: String
    let title: String
    let detail: String
    let time: String
}

enum StudioFixtures {
    static let projects: [StudioProject] = [
        StudioProject(
            id: "spring-catalogue",
            name: "Spring catalogue",
            category: "Brand + Print",
            dueText: "Due 16 Jul",
            progress: 0.75,
            status: .onTrack,
            collection: .client,
            systemImage: "book.closed",
            ownerInitials: ["AM", "NW"],
            tasks: [
                StudioTask(id: "cover", title: "Finalize cover", dueText: "8 Jul", isComplete: true),
                StudioTask(id: "copy", title: "Copy review", dueText: "10 Jul", isComplete: true),
                StudioTask(id: "images", title: "Image selection", dueText: "12 Jul", isComplete: false),
                StudioTask(id: "proof", title: "Print proof", dueText: "14 Jul", isComplete: false),
                StudioTask(id: "signoff", title: "Stakeholder sign-off", dueText: "16 Jul", isComplete: false)
            ]
        ),
        StudioProject(
            id: "website-qa",
            name: "Website QA",
            category: "Web",
            dueText: "Due 22 Jul",
            progress: 0.40,
            status: .onTrack,
            collection: .client,
            systemImage: "globe",
            ownerInitials: ["SC", "AM"],
            tasks: [
                StudioTask(id: "forms", title: "Test contact forms", dueText: "18 Jul", isComplete: false),
                StudioTask(id: "mobile", title: "Mobile performance", dueText: "20 Jul", isComplete: false),
                StudioTask(id: "launch", title: "Launch checklist", dueText: "22 Jul", isComplete: false)
            ]
        ),
        StudioProject(
            id: "packaging-review",
            name: "Packaging review",
            category: "Packaging",
            dueText: "Due 30 Jul",
            progress: 0.20,
            status: .atRisk,
            collection: .client,
            systemImage: "shippingbox",
            ownerInitials: ["NW", "SC"],
            tasks: [
                StudioTask(id: "samples", title: "Material samples", dueText: "21 Jul", isComplete: false),
                StudioTask(id: "supplier", title: "Supplier review", dueText: "25 Jul", isComplete: false)
            ]
        ),
        StudioProject(
            id: "studio-handbook",
            name: "Studio handbook",
            category: "Operations",
            dueText: "Due 4 Aug",
            progress: 0.62,
            status: .onTrack,
            collection: .internalWork,
            systemImage: "text.book.closed",
            ownerInitials: ["AM"],
            tasks: [
                StudioTask(id: "process", title: "Review process section", dueText: "28 Jul", isComplete: false)
            ]
        ),
        StudioProject(
            id: "winter-campaign",
            name: "Winter campaign",
            category: "Campaign",
            dueText: "Completed 2025",
            progress: 1.0,
            status: .complete,
            collection: .archive,
            systemImage: "checkmark.seal",
            ownerInitials: ["SC", "NW"],
            tasks: []
        )
    ]

    static let activity: [StudioActivity] = [
        StudioActivity(
            id: "activity-1",
            initials: "AM",
            title: "Alex completed Copy review",
            detail: "Spring catalogue",
            time: "12 min"
        ),
        StudioActivity(
            id: "activity-2",
            initials: "NW",
            title: "Noah uploaded two print proofs",
            detail: "Packaging review",
            time: "44 min"
        ),
        StudioActivity(
            id: "activity-3",
            initials: "SC",
            title: "Sam updated the launch checklist",
            detail: "Website QA",
            time: "2 hr"
        ),
        StudioActivity(
            id: "activity-4",
            initials: "AM",
            title: "Alex invited a reviewer",
            detail: "Studio handbook",
            time: "Yesterday"
        )
    ]

    static func project(id: String) -> StudioProject {
        projects.first { $0.id == id } ?? projects[0]
    }
}
