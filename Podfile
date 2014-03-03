#
# Crash Manager target
#

platform :ios, '7.0'

inhibit_all_warnings!

# Common pods

pod 'AFNetworking'
pod 'CocoaLumberjack'
pod 'ColorArt'
pod 'GoogleAnalytics-iOS-SDK'
pod 'GroundControl'
pod 'MagicalRecord'
pod 'PBWebViewController'
pod 'ProtobufObjC'
pod 'ReactiveCocoa'
pod 'SHUIKitBlocks'
pod 'SSKeychain'
pod 'TTTLocalizedPluralString'


link_with [ 'CrashManager Functional Tests', 'CrashManager Tests' ]
    pod 'OCMock', '~> 2.2.3'

target 'CrashManager Functional Tests' do
    pod 'KIF', '~> 2.0.0'
end

target 'CrashManager Tests' do
    pod 'Specta', '~> 0.2.1'
    pod 'Expecta', '~> 0.2.3'
end

post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r("Pods/Pods-acknowledgements.plist", "Crashlytics/Settings.bundle/Acknowledgements.plist", :remove_destination => true)
end