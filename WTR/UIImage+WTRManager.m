//
//  UIImage+WTRManager.m
//  WTRGitCs
//
//  Created by wfz on 2017/5/24.
//  Copyright © 2017年 wfz. All rights reserved.
//

#import "UIImage+WTRManager.h"
#import <Accelerate/Accelerate.h>
#import <CommonCrypto/CommonCryptor.h>
#import "WTRBaseDefine.h"

typedef struct ColorC {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
} ColorC;

ColorC getColorCWithDa(char *da,long width,int i,int j)
{
    ColorC onec;
    onec.r=da[i*width*4+j*4+0];
    onec.g=da[i*width*4+j*4+1];
    onec.b=da[i*width*4+j*4+2];
    onec.a=da[i*width*4+j*4+3];
    return onec;
}
void SetColorCWithDa(char *da,long width,int i,int j,ColorC onec)
{
    da[i*width*4+j*4+0]=onec.r;
    da[i*width*4+j*4+1]=onec.g;
    da[i*width*4+j*4+2]=onec.b;
    da[i*width*4+j*4+3]=onec.a;
}

@implementation UIImage (WTRManager)

- (UIImage *)WTR_imageWithTintColor:(UIColor *)tintColor
{
    if (@available(iOS 13.0, *)) {
        return [self imageWithTintColor:tintColor];
    }
    return [self WTR_imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn alpha:1.0f];
}
- (UIImage *)WTR_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    return [self WTR_imageWithTintColor:tintColor blendMode:blendMode alpha:1.0f];
}
- (UIImage *)WTR_imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    CGSize size=CGSizeMake(ceilf(self.size.width), ceilf(self.size.height));

    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGRect bounds = CGRectMake(0, 0,size.width, size.height);
    [tintColor setFill];
    UIRectFill(bounds);

    [self drawInRect:bounds blendMode:blendMode alpha:alpha];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

-(UIImage *)imagemultiplyByR:(CGFloat)r g:(CGFloat)g b:(CGFloat)b a:(CGFloat)a
{
    CIImage *image=[self WTRCIImage];

    CIFilter *msbf=[CIFilter filterWithName:@"CIColorMatrix"];
    [msbf setValue:image forKey:@"inputImage"];
    [msbf setValue:[CIVector vectorWithX:r Y:0 Z:0 W:0] forKey:@"inputRVector"];
    [msbf setValue:[CIVector vectorWithX:0 Y:g Z:0 W:0] forKey:@"inputGVector"];
    [msbf setValue:[CIVector vectorWithX:0 Y:0 Z:b W:0] forKey:@"inputBVector"];
    [msbf setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:a] forKey:@"inputAVector"];
    
//    [msbf setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBiasVector"];
    
    image=msbf.outputImage;
    
    return [UIImage imageWithWTRCIImage:image];
}

- (CIImage *)WTRCIImage
{
    return [[CIImage alloc] initWithImage:self];
}
+ (UIImage *)imageWithWTRCIImage:(CIImage *)ciimage
{
    if (!ciimage) {
        return nil;
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:ciimage fromRect:[ciimage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return newImage;
}
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

//生成二维码
+(UIImage *)QRCodeImageWithStr:(NSString *)infoStr size:(CGSize)size
{
    return [self QRCodeImageWithStr:infoStr size:size foregroundColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
}
+(UIImage *)QRCodeImageWithStr:(NSString *)infoStr size:(CGSize)size foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor
{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];//Filters like CIQRCodeGenerator and CICode128BarcodeGenerator generate barcode images that encode specified input data.
    [filter setDefaults];
    NSData *infoData = [SafeStr(infoStr) dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:infoData forKeyPath:@"inputMessage"];
    CIImage *ciimage = [filter outputImage];
    
    if (foregroundColor&&backgroundColor) {
        //这个Filter其实是把图片中颜色全部映射到两个新颜色之间 跟黑白图片相似 不过终点颜色变化了
        CIFilter *falseFilter=[CIFilter filterWithName:@"CIFalseColor"];
        [falseFilter setDefaults];
        [falseFilter setValue:ciimage forKeyPath:@"inputImage"];
        [falseFilter setValue:[CIColor colorWithCGColor:foregroundColor.CGColor] forKeyPath:@"inputColor0"];
        [falseFilter setValue:[CIColor colorWithCGColor:backgroundColor.CGColor] forKeyPath:@"inputColor1"];
        ciimage = [falseFilter outputImage];
    }
    
    CGRect rect=[ciimage extent];

    ciimage=[ciimage imageByApplyingTransform:CGAffineTransformMakeScale(size.width/rect.size.width, size.height/rect.size.height)];
    
    return [UIImage imageWithWTRCIImage:ciimage];
    
//    //放大图片 灰度图 没有透明度
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CGImageRef cgimg = [context createCGImage:ciimage fromRect:[ciimage extent]];
//
//    CGColorSpaceRef colorspaceref=CGColorSpaceCreateDeviceGray();//灰度值 每个单元1个字节
//    CGContextRef bitmapcontext=CGBitmapContextCreate(NULL, size.width, size.height, 8,size.width, colorspaceref, 0);//初始数据没有 不能用RGB
//
//    //设置插值方式 像素放大 还是模糊放大
//    CGContextSetInterpolationQuality(bitmapcontext, kCGInterpolationNone);
//    CGContextDrawImage(bitmapcontext,CGRectMake(0, 0, size.width, size.height), cgimg);
//
//    CGImageRef imagr=CGBitmapContextCreateImage(bitmapcontext);
//
//    UIImage *retim=[[UIImage alloc]initWithCGImage:imagr];
//    CGImageRelease(imagr);
//    CGColorSpaceRelease(colorspaceref);
//    CGContextRelease(bitmapcontext);
//
//    CGImageRelease(cgimg);
//    return retim;
}
-(NSString *)QRCodeStr
{
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    // 这个也可以提取图片里文字
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    CIImage *ciim=self.CIImage;
    if (!ciim) {
        ciim=[self WTRCIImage];
    }
    NSArray <CIFeature *>*features = [detector featuresInImage:ciim];
    
    for (int i = 0; i < features.count; i ++) {
        CIQRCodeFeature *feature = (CIQRCodeFeature *)features[i];
        if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
            return SafeStr(feature.messageString);
        }
    }
    return @"";
}


- (UIImage *)imageCutWith:(CGSize)size
{
    return [self imageCutWithSize:size isAspectFill:YES opaque:YES];
}
- (UIImage *)imageCutNoOpaqueWith:(CGSize)size
{
    return [self imageCutWithSize:size isAspectFill:YES opaque:NO];
}
- (UIImage *)imageCutWithSize:(CGSize)size isAspectFill:(BOOL)isAspectFill opaque:(BOOL)opaque
{
    size.width=roundf(size.width);
    size.height=roundf(size.height);

    UIImage *image=self;
    CGFloat ww,hh,x=0,y=0,imb,sib;
    imb=image.size.width/image.size.height;
    sib=size.width/size.height;

    if (isAspectFill) {
        if (imb>sib) {
            y=0;
            hh=size.height;
            ww=image.size.width/image.size.height*hh;
            x=-(ww-size.width)/2;
        }else{
            x=0;
            ww=size.width;
            hh=image.size.height/image.size.width*ww;
            y=-(hh-size.height)/2;
        }
    }else{
        if (imb>sib) {
            x=0;
            ww=size.width;
            hh=image.size.height/image.size.width*ww;
            y=-(hh-size.height)/2;
        }else{
            y=0;
            hh=size.height;
            ww=image.size.width/image.size.height*hh;
            x=-(ww-size.width)/2;
        }
    }

    UIGraphicsBeginImageContextWithOptions(size, opaque, 1.0);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));

    [image drawInRect:CGRectMake(x,y,ww,hh)];

    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return viewImage;
}


- (UIImage *)fixOrientation {
    
    UIImage *aImage=self;
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    
    NSData *imageData = UIImageJPEGRepresentation(self, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (UIImage *)applyWBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

#pragma mark 照片mask提取
- (UIImage*)maskImageWithMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
    return [UIImage imageWithCGImage:masked];
}

- (UIImage *)WTR_heiBaiTuImg:(UIImage *)img
{
    return [UIImage HeiBaiTuWithImage1:self image2:img];
}
//黑白背景显示不同图片
+(UIImage *)HeiBaiTuWithImage1:(UIImage *)image1 image2:(UIImage *)image2
{
    //改成同样大小
    if (image2.size.width!=image1.size.width||image2.size.height!=image1.size.height) {
        image2=[image2 imageCutNoOpaqueWith:image1.size];
    }

    CGSize size=image1.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);

    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    [image1 drawInRect:CGRectMake(0, 0, size.width, size.height)];
    char *da1=CGBitmapContextGetData(context);

    size_t width=CGBitmapContextGetWidth(context);
    size_t heigth=CGBitmapContextGetHeight(context);

    size_t BitsPerComponent=CGBitmapContextGetBitsPerComponent(context);

    size_t BitsPerPixel=CGBitmapContextGetBitsPerPixel(context);

    size_t BytesPerRow=CGBitmapContextGetBytesPerRow(context);


    char *imda1=malloc(width*heigth*BitsPerPixel);
    memcpy(imda1, da1, width*heigth*4);

    CGContextClearRect(context, rect);
    [image2 drawInRect:CGRectMake(0, 0, size.width, size.height)];
    char *da2=CGBitmapContextGetData(context);

    char *imda2=malloc(width*heigth*BitsPerPixel);
    memcpy(imda2, da2, width*heigth*4);


    if (BitsPerPixel!=(4*8)) {
        NSLog(@"格式错误");
    }

    //像素点操作
    for (int i=0; i<heigth; i++) {
        for (int j=0; j<width; j++) {

            ColorC onec1=getColorCWithDa(imda1,width,i,j);
            ColorC onec2=getColorCWithDa(imda2,width,i,j);

            //这里取出来的颜色 红 蓝是调换的 以后取像素点用 mainColorWtr 里的方法
            CGFloat hui1=onec1.b*0.3+onec1.g*0.59+onec1.r*0.11;
            CGFloat hui2=onec2.b*0.3+onec2.g*0.59+onec2.r*0.11;

            CGFloat linjind=0.5;//间隔值 0 ~ 1

            //保证 hui2 大于 hui1
            hui1=hui1*linjind;
            hui2=hui2*(1-linjind)+255*linjind;

            ColorC rsco;
            rsco.r=hui1;
            rsco.g=hui1;
            rsco.b=hui1;
            rsco.a= 255+hui1-hui2; //原理 显示图 = 当前图*a + 背景值*(1-a)  列出两个二元一次方程 求 a 就可以得到

            SetColorCWithDa(imda1, width, i, j, rsco);
        }
    }

    CGColorSpaceRef colorspaceref=CGBitmapContextGetColorSpace(context);//CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo info=CGBitmapContextGetBitmapInfo(context);//1

    UIGraphicsEndImageContext();

    CGContextRef bitmapcontext=CGBitmapContextCreate(imda1, width, heigth, BitsPerComponent,BytesPerRow, colorspaceref, info);
    CGImageRef imagr=CGBitmapContextCreateImage(bitmapcontext);
    UIImage *retim=[[UIImage alloc]initWithCGImage:imagr];
    CGImageRelease(imagr);
    CGColorSpaceRelease(colorspaceref);
    CGContextRelease(bitmapcontext);

    free(imda1);
    free(imda2);

    return retim;
}


-(UIColor *)mainColorWtr
{
    //取像素
    int imagewidth=self.size.width*self.scale;
    int imageheght=self.size.height*self.scale;
    CGColorSpaceRef colorspace=CGColorSpaceCreateDeviceRGB();

    void *imagedata=NULL;
    imagedata=malloc(imagewidth*imageheght*4);

    CGContextRef bmpcontext=CGBitmapContextCreate(imagedata, imagewidth, imageheght, 8, imagewidth*4, colorspace, 1);

    CGContextDrawImage(bmpcontext, CGRectMake(0, 0, imagewidth, imageheght), self.CGImage);

    void *data=CGBitmapContextGetData(bmpcontext);

    uint32_t zr=0,zg=0,zb=0,zs=0;

    //像素点提取
    int jump=MAX(imagewidth, imageheght)/160;//跳跃取点
    if (jump<2) {
        jump=2;
    }
    
    for (int i=0; i<imageheght; i+=jump) {
        for (int j=0; j<imagewidth; j+=jump) {
            ColorC onec=getColorCWithDa(data,imagewidth,i,j);
            if (onec.a>10) {//不是透明的
                if ((onec.r>240)&&(onec.g>240)&&(onec.b>240)) {
                    continue;//白色继续 不是特殊颜色
                }
                if ((onec.r<20)&&(onec.g<20)&&(onec.b<20)) {
                    continue;//黑色继续 不是特殊颜色
                }
                zr+=onec.r;
                zg+=onec.g;
                zb+=onec.b;
                zs++;
            }
        }
    }
    CGColorSpaceRelease(colorspace);
    CGContextRelease(bmpcontext);

    free(imagedata);

    double dr=zr*1.0/zs/255;
    double dg=zg*1.0/zs/255;
    double db=zb*1.0/zs/255;

    if (dr<0) {
        dr=0;
    }
    if (dr>1) {
        dr=1;
    }

    if (dg<0) {
        dg=0;
    }
    if (dg>1) {
        dg=1;
    }

    if (db<0) {
        db=0;
    }
    if (db>1) {
        db=1;
    }

    return [UIColor colorWithRed:dr green:dg blue:db alpha:1];
}

-(UIColor *)mainColorWtr2
{
    //取像素
    int imagewidth=self.size.width*self.scale;
    int imageheght=self.size.height*self.scale;
    CGColorSpaceRef colorspace=CGColorSpaceCreateDeviceRGB();

    void *imagedata=NULL;
    imagedata=malloc(imagewidth*imageheght*4);

    CGContextRef bmpcontext=CGBitmapContextCreate(imagedata, imagewidth, imageheght, 8, imagewidth*4, colorspace, 1);

    CGContextDrawImage(bmpcontext, CGRectMake(0, 0, imagewidth, imageheght), self.CGImage);

    void *data=CGBitmapContextGetData(bmpcontext);

    int jump=MAX(imagewidth, imageheght)/160;//跳跃取点
    if (jump<2) {
        jump=2;
    }

    // num 255 255 255   //使用四个字节  第一个存个数  后三个存颜色
    uint32_t *parr=malloc(sizeof(uint32_t)*imageheght*imagewidth/jump);

    uint32_t clen=0;

    //像素点提取
    for (int i=0; i<imageheght; i+=jump) {
        for (int j=0; j<imagewidth; j+=jump) {
            ColorC onec=getColorCWithDa(data,imagewidth,i,j);
            if (onec.a>10) {//不是透明的
                if ((onec.r>240)&&(onec.g>240)&&(onec.b>240)) {
                    continue;//白色继续 不是特殊颜色
                }
                if ((onec.r<20)&&(onec.g<20)&&(onec.b<20)) {
                    continue;//黑色继续 不是特殊颜色
                }
                uint32_t cr=onec.r;
                uint32_t cg=onec.g;
                uint32_t cb=onec.b;

                uint32_t dy=(cr<<16)+(cg<<8)+cb;

                BOOL isin=NO;
                for (int i=0; i<clen; i++) {
                    uint32_t cnum=parr[i];
                    cnum&=0xFFFFFF;
                    if (cnum==dy) {
                        parr[i]+=(1<<24);
                        isin=YES;
                        break;
                    }
                }
                if (!isin) {
                    parr[clen]=dy;
                    clen++;
                }
            }
        }
    }
    CGColorSpaceRelease(colorspace);
    CGContextRelease(bmpcontext);

    free(imagedata);

    uint32_t maxindex=0;
    uint32_t maxnum=0;

    for (int i=0; i<clen; i++) {
        uint32_t cnum=parr[i];
        cnum&=0xFFFF000000;
        if (cnum>maxnum) {
            maxnum=cnum;
            maxindex=i;
        }
    }

    uint32_t cnum=parr[maxindex];
    uint32_t cr=(cnum>>16)&0xFF;
    uint32_t cg=(cnum>>8)&0xFF;
    uint32_t cb=cnum&0xFF;

    double dr=cr*1.0/255;
    double dg=cg*1.0/255;
    double db=cb*1.0/255;

    free(parr);

    return [UIColor colorWithRed:dr green:dg blue:db alpha:1];
}

+(UIColor *)colorHeCheng:(UIColor *)color1 co:(UIColor *)color2
{
    CGFloat c1r,c1g,c1b,c1a;
    CGFloat c2r,c2g,c2b,c2a;
    [color1 getRed:&c1r green:&c1g blue:&c1b alpha:&c1a];
    [color2 getRed:&c2r green:&c2g blue:&c2b alpha:&c2a];

    CGFloat bili=0;
    if (c1a<1) {
        bili=c1a;
    }else{
        bili=1-c2a;
    }
    if (bili<1) {
        c1r=c1r*bili+c2r*(1-bili);
        c1g=c1g*bili+c2g*(1-bili);
        c1b=c1b*bili+c2b*(1-bili);
        return [UIColor colorWithRed:c1r green:c1g blue:c1b alpha:1];
    }
    return [UIColor clearColor];
}

@end
