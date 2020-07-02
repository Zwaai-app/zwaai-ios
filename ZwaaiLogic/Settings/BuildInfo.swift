import Foundation

public class BuildInfo: ObservableObject {
    @Published public var commitHash: String = ""
    @Published public var branch: String = ""

    public init() {
        load()
    }

    func load() {
        DispatchQueue(label: "loadBuildInfo").async {
            loadBuildInfo { commitHash, branch in
                DispatchQueue.main.async {
                    self.commitHash = commitHash
                    self.branch = branch
                }
            }
        }
    }
}

func loadBuildInfo(completion: (_ commitHash: String, _ branch: String) -> Void) {
    guard let buildinfoPath = Bundle(for: BuildInfo.self).path(forResource: "buildinfo", ofType: "txt"),
        let data = FileManager.default.contents(atPath: buildinfoPath),
        let contents = String(data: data, encoding: .utf8) else { return }

    let lines = contents.components(separatedBy: "\n")
    completion(lines[0], lines[1])
}
