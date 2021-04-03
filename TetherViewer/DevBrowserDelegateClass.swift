import Foundation
import ImageCaptureCore

class DevBrowserDelegateClass : NSObject, ICDeviceBrowserDelegate {
    func deviceBrowser(_ browser: ICDeviceBrowser, didAdd device: ICDevice, moreComing: Bool) {
	  print("Device added = \(device) and more coming = \(moreComing)")
    }

    func deviceBrowser(_ browser: ICDeviceBrowser, didRemove device: ICDevice, moreGoing: Bool) {
	  print("Device added = \(device) and more going = \(moreGoing)")

    }
}
