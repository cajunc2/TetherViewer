//
//  ContentView.swift
//  TetherViewer
//
//  Created by Matthew Martin on 3/16/21.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var photoWatcher: PhotoWatcher
	
	@State var currentScale: CGFloat = 1.0
	@State var previousScale: CGFloat = 1.0
	
	@State var currentOffset = CGSize.zero
	@State var previousOffset = CGSize.zero
	@State var animationDuration = 0.0

	let mainImageView : MainImageView
	
	var body: some View {
		NavigationView {
			List(photoWatcher.imageModels.reversed(), id: \.id) { imageModel in
				SidebarImageView(imageModel: imageModel, photoWatcher: photoWatcher)
			}
			self.mainImageView
		}
		.navigationTitle(photoWatcher.latest?.imageFilename ?? "No Image")
		.toolbar {
			ToolbarItemGroup(placement: .navigation) {
				Button(action: toggleSidebar, label: {
					Image(systemName: "sidebar.left").foregroundColor(.accentColor)
				})
				Button {
					prevImage()
				} label: {
					Image(systemName: "chevron.down").foregroundColor(.accentColor)
				}
				.keyboardShortcut(.leftArrow, modifiers: [])
				
				Button {
					nextImage()
				} label: {
					Image(systemName: "chevron.up").foregroundColor(.accentColor)
				}
				.keyboardShortcut(.rightArrow, modifiers: [])
				
//				Toggle(isOn: $showShadows) {
//					Image(systemName: "circle.dashed").foregroundColor(.accentColor)
//				}
//				.keyboardShortcut("s", modifiers: [])
				
				Toggle(isOn: self.$photoWatcher.showHighlightClipping) {
					Image(systemName: "circle.dashed.inset.fill").foregroundColor(.accentColor)
				}
				.keyboardShortcut("h", modifiers: [])
			}
			ToolbarItemGroup(placement: .primaryAction) {
				Text(getFNumber()).font(.title2).padding()
				Text(getShutterSpeed()).font(.title2).padding()
				Text(getISOValue()).font(.title2).padding()
			}
		}
	}
	
	fileprivate func getFNumber() -> String {
		guard let latest = photoWatcher.latest else {
			return "";
		}
		guard let exif = latest.exif else {
			return "";
		}
		return "ƒ/" + exif.fNumber;
	}
	
	fileprivate func getShutterSpeed() -> String {
		guard let latest = photoWatcher.latest else {
			return "";
		}
		guard let exif = latest.exif else {
			return "";
		}
		return exif.shutterSpeed;
	}
	
	fileprivate func getISOValue() -> String {
		guard let latest = photoWatcher.latest else {
			return "";
		}
		guard let exif = latest.exif else {
			return "";
		}
		return "ISO " + exif.iso;
	}
	
	func nextImage() {
		guard let lastImage = photoWatcher.imageModels.last else {
			return
		}
		guard let selectedImage = photoWatcher.latest else {
			return
		}
		if lastImage.id == selectedImage.id {
			return
		}
		
		guard let selectedIndex = photoWatcher.imageModels.firstIndex(of: selectedImage) else {
			return
		}
		let nextIndex = selectedIndex + 1
		photoWatcher.selectImage(photoWatcher.imageModels[nextIndex])
	}
	
	func prevImage() {
		guard let firstImage = photoWatcher.imageModels.first else {
			return
		}
		guard let selectedImage = photoWatcher.latest else {
			return
		}
		if firstImage.id == selectedImage.id {
			return
		}
		
		guard let selectedIndex = photoWatcher.imageModels.firstIndex(of: selectedImage) else {
			return
		}
		let nextIndex = selectedIndex - 1
		photoWatcher.selectImage(photoWatcher.imageModels[nextIndex])
	}
	
	func toggleSidebar() {
		NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
	}
	
	init(photoWatcher: PhotoWatcher) {
		self.photoWatcher = photoWatcher
		self.mainImageView = MainImageView(pw: photoWatcher)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		//		ContentView()
		Text("LOLBROKEN")
	}
}
