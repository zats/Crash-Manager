#
# Crash Manager target
#

platform :ios, '7.0'

# Common pods

target 'CrashManager' do
    inhibit_all_warnings!

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
    pod 'TUSafariActivity', '~> 1.0.0'
    pod 'ARChromeActivity', '~> 1.0.1'

    target 'CrashManager Functional Tests', :exclusive => true do
        pod 'OCMock', '~> 2.2.3'
        pod 'KIF', '~> 2.0.0'
    end

    target 'CrashManager Tests', :exclusive => true do
        pod 'OCMock', '~> 2.2.3'
        pod 'Specta', '~> 0.2.1'
        pod 'Expecta', '~> 0.2.3'
    end
end


post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r("Pods/Pods-CrashManager-acknowledgements.plist", "Crashlytics/Settings.bundle/Acknowledgements.plist", :remove_destination => true)
end