import Foundation

enum ShortcutRunner {
    /// Lance un raccourci Shortcuts via la commande CLI `shortcuts run "Nom"`
    static func run(name: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        task.arguments = ["run", name]
        try? task.run()
    }
}
