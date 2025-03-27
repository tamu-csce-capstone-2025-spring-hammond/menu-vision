import Foundation

class API {
    static let shared = API()
    
    private let primaryBaseURL = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/")!
    private let backupBaseURL = URL(string: "http://127.0.0.1:8080")!
    private let timeout: TimeInterval = 10.0

    private init() {}

    func request(endpoint: String,
                 method: String = "GET",
                 body: Data? = nil,
                 headers: [String: String] = [:],
                 useBackup: Bool = false,
                 completion: @escaping (Result<Data, Error>) -> Void) {
        
        let baseURL = useBackup ? backupBaseURL : primaryBaseURL
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method
        request.timeoutInterval = timeout
        request.httpBody = body
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                if !useBackup {
                    print("Primary URL failed. Retrying with backup...")
                    self.request(endpoint: endpoint,
                                 method: method,
                                 body: body,
                                 headers: headers,
                                 useBackup: true,
                                 completion: completion)
                } else {
                    completion(.failure(error))
                }
            } else if let data = data {
                completion(.success(data))
            }
        }

        task.resume()
    }
}