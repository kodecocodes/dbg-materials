//
//  dsc_extractor.swift
//  swiftc dsc_extractor.swift
// Pre-Ventura
//  usage dsc_extractor /S*/L*/dyld/dyld_shared_cache_arm64e /tmp/dsc_payload
// Ventura
// usage dsc_extractor /System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e /tmp/dsc_payload

import Foundation

typealias extract_dylibs = @convention(c) (UnsafePointer<CChar>?, UnsafePointer<CChar>?, ((UInt32, UInt32) -> Void)?) -> Int32

if CommandLine.argc != 3 {
    print("\(String(utf8String: getprogname()) ?? "") <cache_path> <output_path>")
    exit(1)
}

guard let handle = dlopen("/usr/lib/dsc_extractor.bundle", RTLD_NOW) else {
    print("Couldn't find handle")
    exit(1)
}

guard let sym = dlsym(handle, "dyld_shared_cache_extract_dylibs_progress") else {
    print("Couldn't find dyld_shared_cache_extract_dylibs_progress")
    exit(1)
}

let extract_dylibs_func = unsafeBitCast(sym, to: extract_dylibs.self)
let err = extract_dylibs_func(CommandLine.arguments[1], CommandLine.arguments[2]) { cur, total in
    print("\(cur)/\(total)")
}

if err != 0 {
    print("Something went wrong")
    exit(1)
} else {
    print("success! files written at \"\(CommandLine.arguments[2])\"")
}

