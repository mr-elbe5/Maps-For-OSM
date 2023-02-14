import Foundation

class DownloadOperation : Operation {
    
    var task: URLSessionTask!
    var targetUrl: URL!
    
    init(session: URLSession, urlPair: URLPair) {
        task = session.downloadTask(with: urlPair.source)
        targetUrl = urlPair.target
        super.init()
    }
    
    override var isAsynchronous: Bool {
        return true
    }

    private let stateLock = NSLock()
    
    private var _executing: Bool = false
    override private(set) var isExecuting: Bool {
        get {
            return stateLock.withCriticalScope {
                _executing
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            stateLock.withCriticalScope {
                _executing = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _finished: Bool = false
    override private(set) var isFinished: Bool {
        get {
            return stateLock.withCriticalScope {
                _finished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            stateLock.withCriticalScope {
                _finished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    func completeOperation() {
        if isExecuting {
            isExecuting = false
        }
        if !isFinished {
            isFinished = true
        }
    }

    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        isExecuting = true
        main()
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
    
    func trackDownloadByOperation(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let manager = FileManager.default
            if manager.fileExists(atPath:  targetUrl.path) {
                try manager.removeItem(at: targetUrl)
            }
            print("dest = \(targetUrl.path)")
            assertDirectory(for: targetUrl)
            try manager.moveItem(at: location, to: targetUrl)
        }
        catch {
            print("\(error)")
        }
        completeOperation()
    }
    
    func trackDownloadByOperation(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("\(String(describing: error))")
        }
        completeOperation()
    }
    
    func assertDirectory(for fileUrl: URL){
        let dirURL = fileUrl.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: dirURL.path){
            do{
                try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
            }
            catch{
                print("could not create directory for: \(targetUrl.path)")
            }
        }
    }
    
}
