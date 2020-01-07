//
//  ServiceConnection.swift
//  TrendmatchB2B
//
//  Created by Le Van Long on 6/14/19.
//  Copyright © 2019 Long Le. All rights reserved.
//

import UIKit
import HandyJSON

public enum APIMethod: String {
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case OPTIONS = "OPTIONS"
}

struct APIError: Error {
    
    static let INVALID_EMAIL_PASSWORD = "INVALID_EMAIL_PASSWORD"
    static let EMPTY_OR_INVALID_TOKEN = "EMPTY_OR_INVALID_TOKEN"
    static let EXPIRED_TOKEN = "EXPIRED_TOKEN"
    
    var code = 0
    var errorType = ""
    var message = ""
    
    static let NONE = APIError(code: 0, errorType: "NONE", message: "")
    static let NETWORK_ERROR = APIError(code: -1, errorType: "NETWORK_ERROR", message: NSLocalizedString("api_error_network", value: "Error when connect to server", comment: ""))
    static func ParsingError(message: String) -> APIError {
        return APIError(code: -1, errorType: "PARSING_ERROR", message: message)
    }
    static let INVALID_REQUEST_URL = APIError(code: -2, errorType: "INVALID_REQUEST_URL", message: "Invalid request URL")
    static let INVALID_BASE_URL = APIError(code: -3, errorType: "INVALID_BASE_URL", message: "Invalid base URL")
    static let NO_WORKSPACE_ASSIGNED = APIError(code: 1001, errorType: "NO_WORKSPACE_ASSIGNED", message: "No workspace assigned")
    var localizedDescription: String {
        switch errorType {
        case APIError.INVALID_EMAIL_PASSWORD:
            return NSLocalizedString("api_error_invalid_email_pass", value: "Invalid email or password", comment: "")
        default:
            return message
        }
    }
}

typealias ServiceResult = Result<Any?, APIError>

typealias ServiceRequestHandler = (ServiceResult) -> Void

fileprivate class Queue<T>: NSObject {
    private var data = [T]()
    private let dispatchQueue: DispatchQueue
    
    init(_ dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
        super.init()
    }
    
    var count: Int {
        return data.count
    }
    
    func enqueue(_ item: T) {
        dispatchQueue.sync {
            self.data.insert(item, at: 0)
        }
    }
    
    func clear() {
        dispatchQueue.sync {
            self.data.removeAll()
        }
    }
    
    func dequeue() -> T? {
        guard !data.isEmpty else { return nil }
        var result: T?
        dispatchQueue.sync {
            result = data.removeLast()
        }
        return result
    }
}

fileprivate class ConcurrentSet<T: Hashable>: NSObject {
    private var data: Set<T>
    private let dispatchQueue: DispatchQueue
    init(_ dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
        self.data = Set<T>()
        super.init()
    }
    
    func insert(_ item: T) {
        dispatchQueue.sync {
            _ = self.data.insert(item)
        }
    }
    
    func remove(_ item: T) {
        dispatchQueue.sync {
            _ = self.data.remove(item)
        }
    }
    
    func contains(_ item: T) -> Bool {
        var isContaint = false
        dispatchQueue.sync {
            isContaint = self.data.contains(item)
        }
        return isContaint
    }
    
    func clear() {
        dispatchQueue.sync {
            self.data.removeAll()
        }
    }
}

extension URLRequest {
    func start(with completionHandler: ServiceRequestHandler?) {
        ServiceConnection.shared.send(request: self, completionHandler: completionHandler)
    }
    
    func debugInformation() -> String {
        var retval = "\(self.httpMethod!) \(self.url!.absoluteString)"
        if let __requestBody = httpBody, let jsonBody = String(data: __requestBody, encoding: .utf8) {
            retval += "\n\(jsonBody)"
        }
        return retval
    }
}

class APIRequestBuilder: NSObject {
    //private var urlComponents: URLComponents?
    private var path: String?
    private var queryItems = [String: String]()
    private var params = NSMutableDictionary()
    private var bodyArrays: NSMutableArray?
    private var rawBody: Data?
    private var timeoutInterval = 10
    private var method: APIMethod = .POST
    private var baseUrl = ""
    
    public init(baseUrl: String) throws {
        guard !baseUrl.isEmpty else {
            throw APIError.INVALID_BASE_URL
        }
        self.baseUrl = baseUrl
    }
    
    @discardableResult
    public func method(method: APIMethod) -> APIRequestBuilder {
        self.method = method
        return self
    }
    
    @discardableResult
    public func addPath(_ path: String) -> APIRequestBuilder {
        let normalizedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if normalizedPath.isEmpty { return self }
        if (self.path == nil || self.path!.isEmpty) {
            self.path = path
        }
        else {
            self.path = "\(self.path!)/\(path)"
        }
        return self
    }
    
    @discardableResult
    public func addQuery(key: String, value: String) -> APIRequestBuilder {
        self.queryItems[key] = value
        return self
    }
    
    @discardableResult
    public func addParam(key: String, value: Any) -> APIRequestBuilder {
        self.params[key] = value
        return self
    }
    
    @discardableResult
    public func addParams(_ params: NSDictionary) -> APIRequestBuilder {
        self.params.addEntries(from: params as! [AnyHashable : Any])
        return self
    }
    
    @discardableResult
    public func addRawData(_ data: Data) ->  APIRequestBuilder {
        self.rawBody = data
        return self
    }
    
    @discardableResult
    public func timeout(interval: Int) -> APIRequestBuilder {
        self.timeoutInterval = interval
        return self
    }
    
    public func build() -> URLRequest? {
        var urlPath = baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if let _path = path {
            urlPath += "/\(_path)"
        }
        if queryItems.count > 0 {
            let query = "?" + queryItems.map { "\($0)=\($1)" }.joined(separator: "&")
            urlPath += query
        }
        guard let url = URL(string: urlPath) else {
            return nil
        }
        var request = URLRequest(url: url)
        if let _data = rawBody {
            request.httpBody = _data
        }
        else if params.count > 0 {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init(rawValue: 0))
            } catch let err {
                Logger.error(err.localizedDescription)
            }
        }
        request.httpMethod = self.method.rawValue
        request.timeoutInterval = TimeInterval(self.timeoutInterval)
        return request
    }
}

class ServiceRequestPackage: NSObject {
    var request: URLRequest
    var sessionId = 0
    var handler: ServiceRequestHandler?
    init(request: URLRequest, handler: ServiceRequestHandler?) {
        self.request = request
        self.handler = handler
    }
}

class ServiceConnection: NSObject {
    private static var sessionId = 1
    static let FORCE_LOGOUT_NOTIFICATION = "FORCE_LOGOUT_NOTIFICATION"
    static let FORCE_LOGOUT_ERRORS: [String] = ["EMPTY_OR_INVALID_TOKEN", "EXPIRED_TOKEN"]
    static let BUNDLE_ID = Bundle.main.bundleIdentifier ?? "NONE_BUNDLE_ID"
    static let APP_VESION = "1"
    static let APP_LANGUAGE = Locale.current.languageCode ?? "en"
    static let shared = ServiceConnection()
    
    private let requestQueue: Queue<ServiceRequestPackage>
    
    private(set) var token = ""
    private let queueThreadSafeQueue = DispatchQueue(label: "com.trendmatch.serviceconnection.queue", attributes: .concurrent)
    private var hasWorkingRequest = false
    private var session: URLSession
    
    private override init() {
        requestQueue = Queue<ServiceRequestPackage>(queueThreadSafeQueue)
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
        super.init()
    }
    
    func updateAuthorizationToken(_ token: String) {
        Logger.debug(token)
        if token.isEmpty { self.token = "" }
        else { self.token = "Bearer \(token)" }
    }
    
    func send(request: URLRequest, completionHandler: ServiceRequestHandler?) {
        let header = getHeaders()
        let httpReq = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        for (k,v) in header {
            httpReq.addValue(v, forHTTPHeaderField: k)
        }
        requestQueue.enqueue(ServiceRequestPackage(request: httpReq as URLRequest, handler: completionHandler))
        if !hasWorkingRequest {
            startInternal()
        }
    }
    
    private func startInternal() {
        guard let nextRequest = requestQueue.dequeue() else {
            hasWorkingRequest = false
            return
        }
        hasWorkingRequest = true
        nextRequest.sessionId = ServiceConnection.sessionId
        Logger.info(nextRequest.request)
        let aTask = session.dataTask(with: nextRequest.request) {(data, response, error) in
            defer {
                self.startInternal()
            }
            DispatchQueue.main.async {
                self.parsingResponse(request: nextRequest, data: data, error: error)
            }
        }
        aTask.resume()
    }
    
    private func parsingResponse(request: ServiceRequestPackage, data: Data?, error: Error?) {
        guard let handler = request.handler else { return }
        guard request.sessionId == ServiceConnection.sessionId else { return }
        guard error == nil else {
            handler(ServiceResult.failure(APIError.NETWORK_ERROR))
            #if DEBUG
            Logger.error(APIError.NETWORK_ERROR.message)
            #endif
            return
        }
        guard let _data = data, !_data.isEmpty else {
            #if DEBUG
            Logger.debug("REQUEST:\n\(request.request.debugInformation())\nRESPONSE: EMPTY DATA")
            #endif
            handler(ServiceResult.success(nil))
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: _data, options: .init(rawValue: 0))
            if let jObject = json as? NSDictionary, jObject.count == 1, let errorDict = jObject.value(forKey: "error") as? NSDictionary {
                let errorCode = errorDict.value(forKey: "code") as? Int ?? 0
                let errorType = errorDict.value(forKey: "type") as? String ?? ""
                let errorMessage = errorDict.value(forKey: "message") as? String ?? ""
                let _error = APIError(code: errorCode, errorType: errorType, message: errorMessage)
                if ServiceConnection.FORCE_LOGOUT_ERRORS.contains(_error.errorType) {
                    #if DEBUG
                    Logger.error("EXPIRED TOKEN OR PASSWORD CHANGED, FORCE LOGOUT")
                    #endif
                    forceLogout()
                }
                else {
                    #if DEBUG
                    Logger.error("REQUEST:\n\(request.request.debugInformation())\nRESPONSE ERROR:\(_error.localizedDescription)")
                    #endif
                    handler(.failure(_error))
                }
                return
            }
            #if DEBUG
            var responseJSONString = String(data: _data, encoding: .utf8)!
            if responseJSONString.length > 320 {
                responseJSONString = responseJSONString[0..<320] + "..."
            }
            Logger.debug("REQUEST:\n\(request.request.debugInformation())\nRESPONSE:\n\(responseJSONString)")
            #endif
            handler(ServiceResult.success(json))
        } catch let err {
            #if DEBUG
            let rawResponse = String(data: _data, encoding: .utf8)!
            Logger.debug("REQUEST:\n\(request.request.debugInformation())\nPARSING ERROR WITH RESPONSE:\n\(rawResponse)")
            #endif
            handler(.failure(APIError.ParsingError(message: err.localizedDescription)))
            return
        }
    }
    
    private func forceLogout() {
        cancelAllRequest()
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: ServiceConnection.FORCE_LOGOUT_NOTIFICATION)))
    }
    
    private func cancelAllRequest() {
        ServiceConnection.sessionId += 1
        requestQueue.clear()
    }
    
    private func getHeaders() -> [String: String] {
        var header = [String: String]()
        header["Content-Type"] = "application/json"
        header["X-Trendmatch-App-BundleId"] = ServiceConnection.BUNDLE_ID
        header["X-Trendmatch-App-Agent"] = "iOS \(UIDevice.current.systemVersion) \(ServiceConnection.APP_VESION) \(ServiceConnection.APP_LANGUAGE)"
        if !token.isEmpty {
            header["Authorization"] = token // added Backend API Session key
        }
        return header
    }
}
