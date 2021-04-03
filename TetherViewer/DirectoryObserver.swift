//
//  DirectoryObserver.swift
//  TetherViewer
//
//  Created by Matthew Martin on 3/16/21.
//

import Foundation

class DirectoryObserver {
    
    private let fileDescriptor: CInt
    private let source: DispatchSourceProtocol
    
    deinit {
        self.source.cancel()
        close(fileDescriptor)
    }
    
    init(URL: URL, block: @escaping ()->Void) {
        self.fileDescriptor = open(URL.path, O_EVTONLY)
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fileDescriptor, eventMask: .write, queue: DispatchQueue.global())
        self.source.setEventHandler() {
            block()
        }
        self.source.resume()
    }
    
}
