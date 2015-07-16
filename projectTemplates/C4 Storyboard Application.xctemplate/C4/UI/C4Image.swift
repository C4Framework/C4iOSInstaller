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

import QuartzCore
import UIKit

public class C4Image: C4View {
//MARK: Initializers
    /**
    Initializes a new C4Image using the specified filename from the bundle (i.e. your project), it will also grab images from the web if the filename starts with http.

        let img = C4Image("logo")
        canvas.add(img)

    :param: name	The name of the image included in your project, or a web address.
    */
    convenience public init(_ filename: String) {
        self.init(filename, scale: 1.0)
    }

    /**
    Initializes a new C4Image using the specified filename from the bundle (i.e. your project), it will also grab images from the web if the filename starts with http.
    
        let img = C4Image("http://www.c4ios.com/images/logo@2x.png", scale: 2.0)
        canvas.add(img)

    :param: name	The name of the image included in your project, or a web address.
    */
    convenience public init(_ filename: String, scale: Double) {
        if filename.hasPrefix("http") {
            self.init(url: NSURL(string: filename)!, scale: scale)
            return
        }
        var image = UIImage(named: filename, inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil)
        self.init(uiimage: image!, scale: scale)
    }

    /**
    Initializes a new C4Image using an existing C4Image (basically like copying).

        let a = C4Image("logo")
        canvas.add(a)
        let b = C4Image(image: a)
        b.center = canvas.center
        canvas.add(b)

    :param: image A C4Image.
    */
    convenience public init(image: C4Image) {
        self.init()
        let uiimage = image.uiimage
        self.view = UIImageView(image: uiimage)
    }
    
    /**
    Initializes a new C4Image using a UIImage.

        if let uii = UIImage(named:"logo") {
            let img = C4Image(uiimage: uii)
            canvas.add(img)
        }
    
    :param: uiimage A UIImage object.
    */
    convenience public init(uiimage: UIImage) {
        self.init(uiimage: uiimage, scale: 1.0)
    }

    /**
    Initializes a new C4Image using a UIImage, with option for specifying the scale of the image.

        if let uii = UIImage(named:"logo") {
            let img = C4Image(uiimage: uii, scale: 2.0)
            canvas.add(img)
        }

    :param: uiimage A UIImage object.
    :param: scale A `Double` should be larger than 0.0

    */
    convenience public init(uiimage: UIImage, var scale: Double) {
        self.init()

        if scale != 1.0 {
            let scaledImage = UIImage(CGImage: uiimage.CGImage, scale: CGFloat(scale), orientation: uiimage.imageOrientation)
            self.view = UIImageView(image: scaledImage)
        } else {
            self.view = UIImageView(image: uiimage)
        }
        _originalSize = C4Size(view.frame.size)
    }

    /**
    Initializes a new C4Image using a CGImageRef.

        let cgi = CGImageCreate()
        let img = C4Image(cgimage: cgi)
        canvas.add(img)
    
    :Example:
    https://gist.github.com/C4Framework/06319d420426cb0f1cb3

    :param: cgimage A CGImageRef object.
    */
    convenience public init(cgimage: CGImageRef) {
        let image = UIImage(CGImage: cgimage)
        self.init(uiimage: image!, scale: 1.0)
    }

    /**
    Initializes a new C4Image using a CGImageRef, with option for specifying the scale of the image.

        let cgi = CGImageCreate()
        let img = C4Image(cgimage: cgi, scale: 2.0)
        canvas.add(img)

    :param: uiimage A CGImageRef object.
    */
    convenience public init(cgimage: CGImageRef, scale: Double) {
        let image = UIImage(CGImage: cgimage)
        self.init(uiimage: image!, scale: scale)
    }

    /**
    Initializes a new C4Image using a CIImage.
    
    Use this method if you're working with the output of a CIFilter.

    :param: ciimage A CIImage object.
    */
    convenience public init(ciimage: CIImage) {
        self.init(ciimage: ciimage, scale: 1.0)
    }

    /**
    Initializes a new C4Image using a CIImage, with option for specifying the scale of the image.

    Use this method if you're working with the output of a CIFilter.

    :param: uiimage A CIImage object.
    */
    convenience public init(ciimage: CIImage, scale: Double) {
        let image = UIImage(CIImage: ciimage)
        self.init(uiimage: image!, scale: scale)
    }

    /**
    Initializes a new C4Image using raw data.
    
    Use this if you download an image as data you can pass it here to create an image. 
    
    See the body of init(url:) to see how to download an image as data.

    :param: data An NSData object.
    */
    convenience public init(data: NSData) {
        self.init(data: data, scale: 1.0)
    }

    /**
    Initializes a new C4Image using raw data, with option for specifying the scale of the image.

    Use this if you download an image as data you can pass it here to create an image.

    See the body of init(url:) to see how to download an image as data.
    
    :param: data An NSData object.
    */
    convenience public init(data: NSData, scale: Double) {
        let image = UIImage(data: data)
        self.init(uiimage: image!, scale: scale)
    }

    /**
    Initializes a new C4Image from an URL.

        if let url = NSURL(string: "http://www.c4ios.com/images/logo@2x.png") {
            let img = C4Image(url: url)
            canvas.add(img)
        }

    :param: url An NSURL object.
    */
    convenience public init(url: NSURL) {
        self.init(url: url, scale: 1.0)
    }

    /**
    Initializes a new C4Image from an URL, with option for specifying the scale of the image.
    
        if let url = NSURL(string: "http://www.c4ios.com/images/logo@2x.png") {
            let img = C4Image(url: url, scale: 2.0)
            canvas.add(img)
        }

    :param: url An NSURL object.
    */
    convenience public init(url: NSURL, scale: Double) {
        var error: NSError?
        var data = NSData(contentsOfURL: url, options:.DataReadingMappedIfSafe, error: &error)
        if let d = data {
            self.init(data: d, scale: scale)
            return
        }
        if let e = error {
            C4Log("There was an error loading image data from url:\n ERROR: \(e.localizedDescription)\n URL:\(url)")
        }
        self.init()
    }

    /**
    Initializes a new C4Image using raw data. This method differs from `C4Image(data:...)` in that you can pass an array of raw data to the initializer. This works if you're creating your own raw images by changing the values of individual pixels. Pixel data should be RGBA.
    
    :param: rawData An array of raw pixel data.
    :param: size The size {w,h} of the image you're creating based on the pixel array.
    */
    convenience public init(rawData: Void, size: C4Size) {
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = 8
        
        var data: Void = rawData
        var context = withUnsafeMutablePointer(&data) { (pointer: UnsafeMutablePointer<Void>) -> (CGContext) in
            
            let alphaInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
            let orderInfo = CGBitmapInfo.ByteOrder32Big
            let info = alphaInfo | orderInfo
            return CGBitmapContextCreate(pointer, Int(size.width), Int(size.height), 8, Int(4*size.width), colorspace, info)
        }
        
        let image = CGBitmapContextCreateImage(context)
        self.init(cgimage: image)
    }
    
//MARK: Properties
    /**
    Returns the UIImageView of the object.

    :returns: A UIImageView object.
    */
    internal var imageView : UIImageView {
        get {
            return self.view as! UIImageView
        }
    }
    
    /**
    Returns a UIImage representation of the receiver.
    :returns:	A UIImage object.
    */
    public var uiimage: UIImage {
        get {
            return imageView.image!
        }
    }
    
    /**
    Returns a CGImageRef representation of the receiver.
    :returns:	A CGImageRef object.
    */
    var cgimage: CGImageRef {
        get {
            return uiimage.CGImage
        }
    }
    
    /**
    Returns a CIImage representation of the receiver. Generally, this would be used to work with filters.
    :returns:	A CIImage object.
    */
    var ciimage: CIImage {
        get {
            return CIImage(CGImage: cgimage)
        }
    }
    
    /**
    An object that provides the contents of the layer. Animatable.
    The default value of this property is nil.
    If you are using the layer to display a static image, you can set this property to the CGImageRef containing the image you want to display. Assigning a value to this property causes the layer to use your image rather than create a separate backing store.
    If the layer object is tied to a view object, you should avoid setting the contents of this property directly. The interplay between views and layers usually results in the view replacing the contents of this property during a subsequent update.
    */
    var contents : CGImageRef {
        get {
            let layer = imageView.layer as CALayer
            return layer.contents as! CGImageRef
        } set(val) {
            imageView.layer.contents = val
        }
    }
    
    /**
    A variable that provides access to the width of the receiver. Animatable.
    The default value of this property is defined by the image being created.
    Assigning a value to this property causes the receiver to change the width of its frame. If the receiver's `contrainsProportions` variable is set to `true` the receiver's height will change to match the new width.
    */
    public override var width : Double {
        get {
            return Double(view.frame.size.width)
        } set(val) {
            var newSize = C4Size(val,Double(view.frame.size.height))
            if constrainsProportions {
                let ratio = Double(self.size.height / self.size.width)
                newSize.height = val * ratio
            }
            var rect = self.frame
            rect.size = newSize
            self.frame = rect
        }
    }

    /**
    A variable that provides access to the height of the receiver. Animatable.
    The default value of this property is defined by the image being created.
    Assigning a value to this property causes the receiver to change the height of its frame. If the receiver's `contrainsProportions` variable is set to `true` the receiver's width will change to match the new width.
    */
    public override var height : Double {
        get {
            return Double(view.frame.size.height)
        } set(val) {
            var newSize = C4Size(Double(view.frame.size.width),val)
            if constrainsProportions {
                let ratio = Double(self.size.width / self.size.height)
                newSize.width = val * ratio
            }
            var rect = self.frame
            rect.size = newSize
            self.frame = rect
        }
    }

    /**
    Assigning a value of true to this property will cause the receiver to scale its entire frame whenever its `width` or `height` variables are set.
    The default value of this property is `false`.
    */
    public var constrainsProportions : Bool = false
    
    /**
    The original size of the receiver when it was initialized.
    */
    internal var _originalSize : C4Size = C4Size()
    public var originalSize : C4Size {
        get {
            return _originalSize
        }
    }

    /**
    The original width/height ratio of the receiver when it was initialized.
    */
    public var originalRatio : Double {
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