#
#  Be sure to run `pod spec lint WTR.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "WTR"
  s.version      = "1.0.5"
  s.summary      = "基本快捷方法"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
    WTR基本快捷方法
                   DESC

  s.homepage     = "https://github.com/zhong015/WTR.git"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "wtr" => "1522280795@qq.com" }
  # Or just: s.author    = "wtr"
  # s.authors            = { "wtr" => "1522280795@qq.com" }
  # s.social_media_url   = "http://twitter.com/wtr"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  s.platform     = :ios, "12.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://github.com/zhong015/WTR.git", :tag => s.version }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "WTR/WTRDefine.h"
  # s.exclude_files = "WTRGitCs/*.plist"
  # s.public_header_files = "WTR/WTRDefine.h"

  s.subspec 'WTRBase' do |ss|
    ss.source_files = 'WTR/WTRFilePath.{h,m}','WTR/UIView+WTRFrame.{h,m}','WTR/WTR.{h,m}','WTR/WTRBaseDefine.h'
  end

  s.subspec 'WTRDIYTransitions' do |ss|
    ss.source_files = 'WTR/WTRDIYTransitions.{h,m}'
    ss.dependency 'WTR/WTRBase'
  end

  s.subspec 'WTRVideo' do |ss|
    ss.source_files = 'WTR/WTRVideoCut.{h,m}'
    ss.dependency 'WTR/WTRBase'
  end

  s.subspec 'WTRDownload' do |ss|
    ss.source_files = 'WTR/WTRMultipartForm.{h,m}','WTR/WTRMutiDownloader.{h,m}',"WTR/UIImageView+WTRLoad.{h,m}","WTR/WTRStreamDManager.{h,m}"
    ss.dependency 'WTR/WTRBase'
  end

  s.subspec 'WTRImageManager' do |ss|
    ss.source_files = "WTR/UIImage+WTRManager.{h,m}"
    ss.dependency 'WTR/WTRBase'
    ss.dependency 'WTR/WTRDownload'
  end

  s.subspec 'WTRHUD' do |ss|
    ss.source_files = "WTR/WTRHUD.{h,m}",'WTR/SVIndefiniteAnimatedView2.{h,m}','WTR/SVStatusShowView.{h,m}'
    ss.dependency 'WTR/WTRBase'
  end

  s.subspec 'WTRView' do |ss|
    ss.source_files = "WTR/WTRCollectionLayout.{h,m}",'WTR/WTRImageListShow.{h,m}','WTR/WTRWebView.{h,m}'
    ss.dependency 'WTR/WTRBase'
    ss.dependency 'WTR/WTRHUD'
  end

  s.subspec 'WTRExtension' do |ss|
    ss.source_files = "WTR/NSObject+WTRExtension.{h,m}"
  end

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.resources    = 'WTR/WTRBundle.bundle'

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  s.frameworks = "UIKit", "Foundation", "AVFoundation", "Accelerate","CoreServices"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
