import SwiftUI
import SwiftData

@main
struct ExamPulseApp: App {
    private let dependencies = DependencyContainer()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exam.self,
            StudyDocument.self,
            Topic.self,
            Flashcard.self,
            Question.self,
            AnswerAttempt.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dependencies, dependencies)
                .task {
                    _ = try? await dependencies.notificationService.requestAuthorization()
                    await dependencies.storeService.loadProduct()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
