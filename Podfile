#
# Crash Manager target
#
platform :ios, '7.0'
inhibit_all_warnings!

link_with ['CrashManager', 'CrashManager β']

pod 'AFNetworking', '2.2.0'
pod 'AFNetworking-RACExtensions', :git => 'https://github.com/CodaFi/AFNetworking-RACExtensions'
pod 'ARChromeActivity', :git => 'https://github.com/alextrob/ARChromeActivity/'
pod 'CocoaLumberjack', '1.8.1'
pod 'ColorArt', '0.1.1'
pod 'GoogleAnalytics-iOS-SDK', '3.0.3'
pod 'GroundControl', '2.0.0'
pod 'MagicalRecord', '2.2'
pod 'PBWebViewController', '0.1'
pod 'ProtobufObjC', '0.0.1'
pod 'ReactiveCocoa', '2.2.4'
pod 'SHUIKitBlocks', '2.3.0'
pod 'SSKeychain', '1.2.1'
pod 'TTTLocalizedPluralString', '0.0.9'
pod 'TUSafariActivity', '1.0.0'
pod 'Parse-iOS-SDK', '~> 1.2.18'

target 'CrashManager Unit Tests' do
    pod 'Expecta', '~> 0.3.0'
    pod 'Specta', '~> 0.2.1'
    pod 'OCMock', '~> 2.2.3'
end

post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r("Pods/Pods-acknowledgements.plist", "Crashlytics/Settings.bundle/Acknowledgements.plist", :remove_destination => true)
end
