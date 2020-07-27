import Foundation

public class BuildInfo: ObservableObject {
    @Published public var commitHash: String = ""
    @Published public var branch: String = ""
    @Published public var hostname: String = ""

    public init() {
        load()
    }

    func load() {
        DispatchQueue(label: "loadBuildInfo").async {
            loadBuildInfo { commitHash, branch, hostname in
                DispatchQueue.main.async {
                    self.commitHash = commitHash
                    self.branch = branch
                    self.hostname = hostname
                }
            }
        }
    }
}

func loadBuildInfo(completion: (_ commitHash: String, _ branch: String, _ hostname: String) -> Void) {
    guard let buildinfoPath = Bundle(for: BuildInfo.self).path(forResource: "buildinfo", ofType: "txt"),
        let data = FileManager.default.contents(atPath: buildinfoPath),
        let contents = String(data: data, encoding: .utf8) else { return }

    let lines = contents.components(separatedBy: "\n")
    completion(lines[0], lines[1], lines[2])
}
