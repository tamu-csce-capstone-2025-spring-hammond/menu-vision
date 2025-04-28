import Foundation

/// A centralized API management class for handling network requests in the MenuVision application.
///
/// Provides a singleton instance for making HTTP requests with flexible configuration
/// and built-in fallback mechanism for primary and backup server endpoints.
class API {
    /// The shared singleton instance of the API class.
    ///
    /// Ensures a single point of access for network request management throughout the app.
    static let shared = API()
    
    /// The primary base URL for making network requests.
    ///
    /// Points to the main server endpoint for the MenuVision backend.
    private let primaryBaseURL = URL(string: "https://menu-vision-b202af7ea787.herokuapp.com/")!
    
    /// The backup base URL for network requests.
    ///
    /// Provides an alternative server endpoint in case the primary URL fails.
    private let backupBaseURL = URL(string: "http://127.0.0.1:8080/")!
    
    /// The timeout interval for network requests.
    ///
    /// Defines the maximum time to wait for a response before considering the request failed.
    private let timeout: TimeInterval = 10.0
    
    /// Private initializer to enforce singleton pattern.
    ///
    /// Prevents external instantiation of the API class.
    private init() {}
    
    /// Performs a network request with configurable parameters and fallback mechanism.
    ///
    /// - Parameters:
    ///   - endpoint: The specific API endpoint to be called
    ///   - method: The HTTP method (default is "GET")
    ///   - body: Optional request body data
    ///   - headers: Optional HTTP headers
    ///   - useBackup: Flag to determine whether to use backup URL (default is false)
    ///   - completion: Closure to handle the result of the network request
    ///
    /// - Note: Automatically handles retrying with backup URL if the primary request fails
    func request(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String] = [:],
        useBackup: Bool = false,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        // Implementation details preserved from original code
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
                    self.request(
                        endpoint: endpoint,
                        method: method,
                        body: body,
                        headers: headers,
                        useBackup: true,
                        completion: completion
                    )
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
