import Cocoa
import FlutterMacOS
import UniformTypeIdentifiers

public class UtopiaSaveFilePlugin: NSObject, FlutterPlugin {
    let registrar: FlutterPluginRegistrar
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "utopia_save_file", binaryMessenger: registrar.messenger)
        let instance = UtopiaSaveFilePlugin(registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(_ registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! NSDictionary
        switch call.method {
        case "fromFile":
            let dto = SaveFileDtoFromFile(from: arguments)
            performSave(dto, result) { InputStream(fileAtPath: dto.path) }
        case "fromUrl":
            let dto = SaveFileDtoFromUrl(from: arguments)
            saveFromUrl(dto, result)
        case "fromAsset":
            let dto = SaveFileDtoFromAsset(from: arguments)
            let path = registrar.lookupKey(forAsset: dto.key)
            let url = Bundle.main.bundleURL.appendingPathComponent(path)
            performSave(dto, result) { InputStream(url: url) }
        case "fromBytes":
            let dto = SaveFileDtoFromBytes(from: arguments)
            performSave(dto, result) { InputStream(data: dto.bytes.data) }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func saveFromUrl(_ dto: SaveFileDtoFromUrl, _ result: @escaping FlutterResult) {
        showPanel(dto) { destUrl in
            guard destUrl != nil else {
                result(false)
                return
            }
            guard let srcUrl = URL(string: dto.url) else {
                result(false)
                return
            }
            let task = URLSession.shared.downloadTask(with: srcUrl) { url, _, _ in
                guard let downloadedUrl = url else {
                    result(false)
                    return
                }
                do {
                    try FileManager.default.moveItem(at: downloadedUrl, to: destUrl!)
                    result(true)
                } catch {
                    result(false)
                }
            }
            task.resume()
        }
    }
    
    private func performSave(_ dto: SaveFileDto, _ result: @escaping FlutterResult, _ inputStreamProvider: @escaping () -> InputStream?) {
        showPanel(dto) { [self] url in
            guard url != nil else {
                result(false)
                return
            }
            DispatchQueue.global().async {
                guard let stream = inputStreamProvider() else {
                    result(false)
                    return
                }
                result(self.saveFile(stream, url!))
            }
        }
    }
    
    private func showPanel(_ dto: SaveFileDto, completionHandler handler: @escaping (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = dto.name
        panel.canCreateDirectories = true
        if let contentType = UTType(mimeType: dto.mime) {
            panel.allowedContentTypes = [contentType]
        } else {
            panel.allowsOtherFileTypes = true
        }
        panel.begin { response in
            if response == .OK {
                handler(panel.url!)
            } else {
                handler(nil)
            }
        }
    }
    
    private func saveFile(_ stream: InputStream, _ url: URL) -> Bool {
        stream.open()

        guard let outputStream = OutputStream(url: url, append: false) else {
            stream.close()
            return false
        }
        outputStream.open()
        
        let bufferSize = 4096
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        
        while stream.hasBytesAvailable {
            let bytesRead = stream.read(&buffer, maxLength: bufferSize)
            
            if bytesRead > 0 {
                outputStream.write(buffer, maxLength: bytesRead)
            } else if bytesRead < 0 {
                stream.close()
                outputStream.close()
                return false
            }
        }
        
        stream.close()
        outputStream.close()
        
        return true
    }

}
