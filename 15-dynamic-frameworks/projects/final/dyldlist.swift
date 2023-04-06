// dyldlist.swift
// add dyld_priv.h in module.modulemap then
// swiftc -I. -o /tmp/dyldlist dyldlist.swift 
import YayModule	

let cache_uuid = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
let manager = FileManager.default

if  _dyld_get_shared_cache_uuid(cache_uuid) {
    let cachePath = String(cString: dyld_shared_cache_file_path())
    print("Inspecting dyld cache at \"\(cachePath)\"")
    
    dyld_shared_cache_iterate_text(cache_uuid) { info in
        
        if let module = info?.pointee {
            let uuid = UUID(uuid: module.dylibUuid).uuidString
            let path = String(cString: module.path)
            let exists = manager.fileExists(atPath: path)
            
            print("\(exists ? "*" : " ") \(uuid) - \(path)")
        }
    }
}

