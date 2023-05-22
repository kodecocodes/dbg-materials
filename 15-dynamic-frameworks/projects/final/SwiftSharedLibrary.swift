// SwiftFramework.swift
// swiftc SwiftFramework.swift -emit-library -o /tmp/libSwiftSharedLibrary.dylib

@_cdecl("swift_function")
public func swift_function() {
   print("hello from \(#function)")
}

public func mangled_function() {
   print("!!!!!! \(#function)")
}
