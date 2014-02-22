#
# Crash Manager target
#
target "CrashManager" do
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
	inhibit_all_warnings!
end

post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r("Pods/Pods-CrashManager-acknowledgements.plist", "Crashlytics/Settings.bundle/Acknowledgements.plist", :remove_destination => true)
end