// Copyright © 2014 C4
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import UIKit

/// A C4Image provides a view-based container for displaying a single image. You can create images from files, from other image objects, or from raw image data you receive.
public class C4Image: C4View, NSCopying {
    internal class ImageView: UIImageView {
        var imageLayer: C4ImageLayer {
            return self.layer as! C4ImageLayer // swiftlint:disable:this force_cast
        }

        override class func layerClass() -> AnyClass {
            return C4ImageLayer.self
        }
    }

    /// C4Shape's contents are drawn on a C4ShapeLayer.
    public var imageLayer: C4ImageLayer {
        get {
            return self.imageView.imageLayer
        }
    }

    //MARK: Initializers

    /// Initializes an empty C4Image
    public override init() {
        super.init()
        let uiimage = UIImage()
        self.view = ImageView(image: uiimage)
    }

    /// Initializes a new C4Image using the specified filename from the bundle (i.e. your project), it will also grab images
    /// from the web if the filename starts with http.
    /// ````
    /// let img = C4Image("logo")
    /// canvas.add(img)
    /// ````
    /// - parameter name:	The name of the image included in your project, or a web address.
    convenience public init?(_ name: String) {
        self.init(name, scale: 1.0)
    }

    /// Initializes a new C4Image using the specified filename from the bundle (i.e. your project), it will also grab images
    /// from the web if the filename starts with http.
    /// ````
    /// let img = C4Image("http://www.c4ios.com/images/logo@2x.png", scale: 2.0)
    /// canvas.add(img)
    /// ````
    /// - parameter name:	The name of the image included in your project, or a web address.
    convenience public init?(_ name: String, scale: Double) {
        guard let image = UIImage(named: name) else {
            return nil
        }
        self.init(uiimage: image, scale: scale)
    }

    /// Initializes a new C4Image using an existing C4Image (basically like copying).
    /// ````
    /// let a = C4Image("logo")
    /// canvas.add(a)
    /// let b = C4Image(image: a)
    /// b.center = canvas.center
    /// canvas.add(b)
    /// ````
    /// - parameter image: A C4Image.
    convenience public init(image: C4Image) {
        self.init()
        let uiimage = image.uiimage
        self.view = ImageView(image: uiimage)
    }

    /// Initializes a new C4Image using a UIImage.
    /// ````
    /// if let uii = UIImage(named:"logo") {
    ///     let img = C4Image(uiimage: uii)
    ///     canvas.add(img)
    /// }
    /// ````
    /// - parameter uiimage: A UIImage object.
    convenience public init(uiimage: UIImage) {
        self.init(uiimage: uiimage, scale: 1.0)
    }

    /// Initializes a new C4Image using a UIImage, with option for specifying the scale of the image.
    /// ````
    /// if let uii = UIImage(named:"logo") {
    ///     let img = C4Image(uiimage: uii, scale: 2.0)
    ///     canvas.add(img)
    /// }
    /// ````
    /// - parameter uiimage: A UIImage object.
    /// - parameter scale: A `Double` should be larger than 0.0
    convenience public init(uiimage: UIImage, let scale: Double) {
        self.init()

        if scale != 1.0 {
            let scaledImage = UIImage(CGImage: uiimage.CGImage!, scale: CGFloat(scale), orientation: uiimage.imageOrientation)
            self.view = ImageView(image: scaledImage)
        } else {
            self.view = ImageView(image: uiimage)
        }
        _originalSize = C4Size(view.frame.size)
    }

    /// Initializes a new C4Image using a CGImageRef.
    /// ````
    /// let cgi = CGImageCreate()
    /// let img = C4Image(cgimage: cgi)
    /// canvas.add(img)
    /// ````
    /// [Example](https://gist.github.com/C4Framework/06319d420426cb0f1cb3)
    /// - parameter cgimage: A CGImageRef object.
    convenience public init(cgimage: CGImageRef) {
        let image = UIImage(CGImage: cgimage)
        self.init(uiimage: image, scale: 1.0)
    }

    /// Initializes a new C4Image using a CGImageRef, with option for specifying the scale of the image.
    /// ````
    /// let cgi = CGImageCreate()
    /// let img = C4Image(cgimage: cgi, scale: 2.0)
    /// canvas.add(img)
    /// ````
    /// - parameter cgimage: A CGImageRef object.
    /// - parameter scale: The scale of the image.
    convenience public init(cgimage: CGImageRef, scale: Double) {
        let image = UIImage(CGImage: cgimage)
        self.init(uiimage: image, scale: scale)
    }

    /// Initializes a new C4Image using a CIImage.
    /// Use this method if you're working with the output of a CIFilter.
    /// - parameter ciimage: A CIImage object.
    convenience public init(ciimage: CIImage) {
        self.init(ciimage: ciimage, scale: 1.0)
    }

    /// Initializes a new C4Image using a CIImage, with option for specifying the scale of the image.
    /// Use this method if you're working with the output of a CIFilter.
    /// - parameter ciimage: A CIImage object.
    /// - parameter scale: The scale of the image.
    convenience public init(ciimage: CIImage, scale: Double) {
        let image = UIImage(CIImage: ciimage)
        self.init(uiimage: image, scale: scale)
    }

    /// Initializes a new C4Image using raw data.
    /// Use this if you download an image as data you can pass it here to create an image.
    /// See the body of init(url:) to see how to download an image as data.
    /// - parameter data: An NSData object.
    convenience public init(data: NSData) {
        self.init(data: data, scale: 1.0)
    }

    /// Initializes a new C4Image using raw data, with option for specifying the scale of the image.
    /// Use this if you download an image as data you can pass it here to create an image.
    /// See the body of init(url:) to see how to download an image as data.
    /// - parameter data: An NSData object.
    /// - parameter scale: The scale of the image.
    convenience public init(data: NSData, scale: Double) {
        let image = UIImage(data: data)
        self.init(uiimage: image!, scale: scale)
    }

    /// Initializes a new C4Image from an URL.
    /// ````
    ///  if let url = NSURL(string: "http://www.c4ios.com/images/logo@2x.png") {
    ///      let img = C4Image(url: url)
    ///      canvas.add(img)
    /// }
    /// ````
    /// - parameter url: An NSURL object.
    convenience public init(url: NSURL) {
        self.init(url: url, scale: 1.0)
    }

    /// Initializes a new C4Image from an URL, with option for specifying the scale of the image.
    /// ````
    /// if let url = NSURL(string: "http://www.c4ios.com/images/logo@2x.png") {
    ///     let img = C4Image(url: url, scale: 2.0)
    ///     canvas.add(img)
    /// }
    /// ````
    /// - parameter url: An NSURL object.
    /// - parameter scale: The scale of the image.
    convenience public init(url: NSURL, scale: Double) {
        var error: NSError?
        var data: NSData?
        do {
            data = try NSData(contentsOfURL: url, options:.DataReadingMappedIfSafe)
        } catch let error1 as NSError {
            error = error1
            data = nil
        }
        if let d = data {
            self.init(data: d, scale: scale)
            return
        }
        if let e = error {
            C4Log("There was an error loading image data from url:\n ERROR: \(e.localizedDescription)\n URL:\(url)")
        }
        self.init()
    }

    /// Initializes a new C4Image using raw data. This method differs from `C4Image(data:...)` in that you can pass an array of
    /// raw data to the initializer. This works if you're creating your own raw images by changing the values of individual
    /// pixels. Pixel data should be RGBA.
    /// - parameter pixels: An array of raw pixel data.
    /// - parameter size: The size {w, h} of the image you're creating based on the pixel array.
    convenience public init(pixels: [Pixel], size: C4Size) {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let bitsPerComponent: Int = 8
        let bitsPerPixel: Int = 32
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)

        assert(pixels.count == Int(width * height))

        var data = pixels // Copy to mutable []
        let providerRef = CGDataProviderCreateWithCFData(
            NSData(bytes: &data, length: data.count * sizeof(Pixel))
        )

        let cgim = CGImageCreate(
            width,
            height,
            bitsPerComponent,
            bitsPerPixel,
            width * Int(sizeof(Pixel)),
            rgbColorSpace,
            bitmapInfo,
            providerRef,
            nil,
            true,
            CGColorRenderingIntent.RenderingIntentDefault
        )

        self.init(cgimage: cgim!)
    }

    /// Initializes a new C4Image using another image.
    /// - parameter c4image: An C4Image around which the new image is created.
    convenience public init(c4image: C4Image) {
        let cgim = c4image.cgimage
        self.init(cgimage: cgim)
    }

    /// Initializes a new copy of the receiver.
    /// - parameter zone: This parameter is ignored. Memory zones are no longer used by Objective-C.
    /// - returns: a new instance that’s a copy of the receiver.
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let uiimage = UIImage(CGImage: self.contents)
        let img = C4Image(uiimage: uiimage, scale: scale)
        img.frame = self.frame
        img.constrainsProportions = self.constrainsProportions
        img._originalSize = _originalSize
        return img
    }

    //MARK: Properties

    /// Returns the UIImageView of the object.
    /// - returns: A UIImageView object.
    internal var imageView: ImageView {
        return self.view as! ImageView // swiftlint:disable:this force_cast
    }

    /// Returns a UIImage representation of the receiver.
    /// - returns:	A UIImage object.
    public var uiimage: UIImage {
        get {
            return imageView.image!
        }
    }

    /// Returns a CGImageRef representation of the receiver.
    /// - returns:	A CGImageRef object.
    public var cgimage: CGImageRef {
        get {
            return uiimage.CGImage!
        }
    }

    /// Returns a CIImage representation of the receiver. Generally, this would be used to work with filters.
    /// - returns:	A CIImage object.
    public var ciimage: CIImage {
        get {
            return CIImage(CGImage: cgimage)
        }
    }

    /// An object that provides the contents of the layer. Animatable.
    /// The default value of this property is nil.
    /// If you are using the layer to display a static image, you can set this property to the CGImageRef containing the image
    /// you want to display. Assigning a value to this property causes the layer to use your image rather than create a
    /// separate backing store.
    public var contents: CGImage {
        get {
            let layer = imageView.layer as CALayer
            return layer.contents as! CGImage // swiftlint:disable:this force_cast
        } set(val) {
            imageView.layer.contents = val
        }
    }

    /// The scale factor of the image. (read-only)
    var scale: Double {
        return Double(uiimage.scale)
    }

    /// A variable that provides access to the width of the receiver. Animatable.
    /// The default value of this property is defined by the image being created.
    /// Assigning a value to this property causes the receiver to change the width of its frame. If the receiver's
    /// `contrainsProportions` variable is set to `true` the receiver's height will change to match the new width.
    public override var width: Double {
        get {
            return Double(view.frame.size.width)
        } set(val) {
            var newSize = C4Size(val, Double(view.frame.size.height))
            if constrainsProportions {
                let ratio = Double(self.size.height / self.size.width)
                newSize.height = val * ratio
            }
            var rect = self.frame
            rect.size = newSize
            self.frame = rect
        }
    }

    /// A variable that provides access to the height of the receiver. Animatable.
    /// The default value of this property is defined by the image being created.
    /// Assigning a value to this property causes the receiver to change the height of its frame. If the receiver's
    /// `contrainsProportions` variable is set to `true` the receiver's width will change to match the new width.
    public override var height: Double {
        get {
            return Double(view.frame.size.height)
        } set(val) {
            var newSize = C4Size(Double(view.frame.size.width), val)
            if constrainsProportions {
                let ratio = Double(self.size.width / self.size.height)
                newSize.width = val * ratio
            }
            var rect = self.frame
            rect.size = newSize
            self.frame = rect
        }
    }

    /// Assigning a value of true to this property will cause the receiver to scale its entire frame whenever its `width` or
    /// `height` variables are set.
    /// The default value of this property is `false`.
    public var constrainsProportions: Bool = false

    internal var _originalSize: C4Size = C4Size()
    /// The original size of the receiver when it was initialized.
    public var originalSize: C4Size {
        get {
            return _originalSize
        }
    }

    /// The original width/height ratio of the receiver when it was initialized.
    public var originalRatio: Double {
        get {
            return _originalSize.width / _originalSize.height
        }
    }

    //MARK: Filters
    lazy internal var output: CIImage = self.ciimage
    lazy internal var filterQueue: dispatch_queue_t = {
        return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        }()
    lazy internal var renderImmediately = true
}
