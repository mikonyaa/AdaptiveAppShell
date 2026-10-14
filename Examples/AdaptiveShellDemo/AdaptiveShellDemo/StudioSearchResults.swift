import Foundation

enum StudioSearchScope: String, CaseIterable, Identifiable {
    case all = "All"
    case projects = "Projects"
    case tasks = "Tasks"
    case people = "People"

    var id: String { rawValue }
}

struct StudioTaskResult: Identifiable {
    let project: StudioProject
    let task: StudioTask

    var id: String { "\(project.id)/\(task.id)" }
}

struct StudioSearchResults {
    let query: String
    let projects: [StudioProject]
    let tasks: [StudioTaskResult]
    let people: [StudioPerson]

    var isEmpty: Bool { projects.isEmpty && tasks.isEmpty && people.isEmpty }

    init(query: String, scope: StudioSearchScope, projects: [StudioProject], people: [StudioPerson]) {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        self.query = query
        func matches(_ value: String) -> Bool {
            query.isEmpty || value.localizedCaseInsensitiveContains(query)
        }
        self.projects = scope == .all || scope == .projects
            ? projects.filter { matches($0.name) || matches($0.category) } : []
        self.tasks = scope == .all || scope == .tasks
            ? projects.flatMap { project in
                project.tasks.compactMap { task in
                    guard matches(task.title) || matches(project.name) else { return nil }
                    return StudioTaskResult(project: project, task: task)
                }
            } : []
        self.people = scope == .all || scope == .people
            ? people.filter { matches($0.name) || matches($0.role) } : []
    }
}
