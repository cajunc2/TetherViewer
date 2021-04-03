//
//  SidebarImageView.swift
//  TetherViewer
//
//  Created by Matthew Martin on 3/17/21.
//

import SwiftUI

extension Image {
	init(thumbnail: ImageModel?) {
		guard let imageModel = thumbnail else {
			self = Image(systemName: "nosign")
			return
		}
		guard let thumbnailImage = imageModel.thumbnail else {
			self = Image(systemName: "nosign")
			return
		}
		self = Image(nsImage: thumbnailImage)
	}
}

struct SidebarImageView: View {
	@ObservedObject var imageModel: ImageModel
	@ObservedObject var photoWatcher : PhotoWatcher
	
	var body: some View {
		VStack {
			ZStack {
				((imageModel.imageFilename == photoWatcher.latest?.imageFilename) ? Color.accentColor.opacity(0.25) : Color.clear)
				VStack {
					Image(thumbnail: imageModel).resizable().scaledToFit()
					Text(imageModel.imageFilename)
				}.padding().aspectRatio(1.0, contentMode: .fill)
			}
		}
		.frame(maxWidth: .infinity)
		.gesture(TapGesture().onEnded({ _ in
			photoWatcher.selectImage(imageModel)
		}))
	}
	
//	init(imageModel: ImageModel, photoWatcher: PhotoWatcher) {
//		print("SidebarImageView#init(ImageModel[" + imageModel.imageFilename + "], PhotoWatcher)")
//		self.imageModel = imageModel
//		self.photoWatcher = photoWatcher
//		photoWatcher.imageModels.forEach { (im) in
//			print(im.imageFilename)
//		}
//	}
}

struct SidebarImageView_Previews: PreviewProvider {
	static var previews: some View {
		//		SidebarImageView(imageModel: ImageModel(imageUrl: URL(fileURLWithPath: "/")))
		Text("BOOOOOOOOORKED")
	}
}
