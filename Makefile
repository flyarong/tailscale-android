DEBUG_APK=tailscale-debug.apk
RELEASE_AAB=tailscale-release.aab
APPID=com.tailscale.ipn
AAR=android/libs/ipn.aar
KEYSTORE=tailscale.jks
KEYSTORE_ALIAS=tailscale

all: $(APK)

aar:
	mkdir -p android/libs
	go run gioui.org/cmd/gogio -buildmode archive -target android -appid $(APPID) -o $(AAR) tailscale.com/tailscale-android/cmd/tailscale

$(DEBUG_APK): aar
	(cd android && ./gradlew assembleDebug)
	mv android/build/outputs/apk/debug/android-debug.apk $@
	
$(RELEASE_AAB): aar
	(cd android && ./gradlew bundleRelease)
	mv ./android/build/outputs/bundle/release/android-release.aab $@

release: $(RELEASE_AAB)
	jarsigner -sigalg SHA256withRSA -digestalg SHA-256 -keystore $(KEYSTORE) $(RELEASE_AAB) $(KEYSTORE_ALIAS)

install: $(DEBUG_APK)
	adb install -r $(DEBUG_APK)

clean:
	rm -rf android/build $(RELEASE_AAB) $(DEBUG_APK) $(AAR)

.PHONY: all clean install aar release
