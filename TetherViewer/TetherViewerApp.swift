//
//  TetherViewerApp.swift
//  TetherViewer
//
//  Created by Matthew Martin on 3/16/21.
//

import SwiftUI

@main
struct TetherViewerApp: App {
	let path = "/Users/cajuncc/Pictures/FUJIFILM/"
	
	var view: ContentView?
	var body: some Scene {
		WindowGroup {
			ContentView(photoWatcher: PhotoWatcher(watchDir: URL(fileURLWithPath: path, isDirectory: true)))
		}
	}
}
