import Foundation
import Observation

@MainActor
@Observable
final class StudioStore {
    private(set) var projects = StudioFixtures.projects
    var showProgress = true
    var keepInspectorOpen = false
    var searchQuery = "website"
    var searchScope = StudioSearchScope.all

    var searchResults: StudioSearchResults {
        StudioSearchResults(query: searchQuery, scope: searchScope, projects: projects, people: StudioFixtures.people)
    }

    var upcomingTasks: [StudioTaskResult] {
        Array(projects.filter { $0.collection != .archive }.compactMap { project in
            project.tasks.first(where: { !$0.isComplete }).map { StudioTaskResult(project: project, task: $0) }
        }.prefix(2))
    }

    func project(id: String) -> StudioProject? {
        projects.first { $0.id == id }
    }

    @discardableResult
    func createProject(name: String, category: String, dueDate: Date) -> StudioProject? {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }
        let category = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM"
        let project = StudioProject(
            id: "local-\(UUID().uuidString.lowercased())",
            name: name,
            category: category.isEmpty ? "General" : category,
            dueText: "Due \(formatter.string(from: dueDate))",
            status: .onTrack,
            collection: .client,
            systemImage: "folder",
            ownerInitials: ["AM"],
            tasks: []
        )
        projects.insert(project, at: 0)
        return project
    }

    func toggleTask(_ taskID: String, in projectID: String) {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectID }),
              let taskIndex = projects[projectIndex].tasks.firstIndex(where: { $0.id == taskID }) else { return }
        projects[projectIndex].tasks[taskIndex].isComplete.toggle()
        if projects[projectIndex].tasks.allSatisfy(\.isComplete) {
            projects[projectIndex].status = .complete
        } else if projects[projectIndex].status == .complete {
            projects[projectIndex].status = .onTrack
        }
    }
}
