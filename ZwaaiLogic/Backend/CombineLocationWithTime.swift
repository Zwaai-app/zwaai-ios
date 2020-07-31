import Foundation

protocol CombineLocationWithTimeProto {
    func run(
        encryptedLocation: GroupElement,
        completion: @escaping (Result<[GroupElement], AppError>) -> Void
    )
}

class CombineLocationWithTime: Backend, CombineLocationWithTimeProto {
    func run(
        encryptedLocation: GroupElement,
        completion: @escaping (Result<[GroupElement], AppError>) -> Void
    ) {
        let session = deps.createSession(.ephemeral)
        withHostName { hostname in
            let url = URL(string: "http://\(hostname):3000/api/v1/space/checkin")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let hexString = encryptedLocation.hexEncodedString()
            let payload = "{\"encryptedLocation\":\"\(hexString)\"}"
            let hexBytes = payload.data(using: .utf8)!
            let task = session.uploadTaskTestable(with: request, from: hexBytes) { data, response, error in
                if let error = error {
                    completion(.failure(AppError.backendProblem(error: error)))
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(AppError.backendResponseError(statusCode: 0)))
                    return
                }
                guard (200...299).contains(response.statusCode) else {
                    completion(.failure(AppError.backendResponseError(statusCode: response.statusCode)))
                    return
                }
                let decoder = JSONDecoder()
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let response = try? decoder.decode(Response.self, from: data) {
                    completion(.success(response.encryptedLocationTimeCodes))
                }
            }
            task.resume()
        }
    }

    struct Response: Codable {
        let encryptedLocationTimeCodes: [GroupElement]
    }
}
