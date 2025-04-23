#!/bin/bash
#

# build-wtr-whisper 创建iOS平台语音识别库(whisper.cpp)

IOS_MIN_OS_VERSION=13.1

WTRToDir="build-wtr-whisper"

buildlist=(
    "iphoneos"
    "maccatalyst_x86_64"
    "maccatalyst_arm64"
    "iphonesimulator_x86_64"
    "iphonesimulator_arm64"
    )

# 使用 https://github.com/leetal/ios-cmake
# -DPLATFORM: OS64 SIMULATOR64COMBINED MAC_CATALYST_UNIVERSAL
CMAKE_TOOLCHAIN_FILE="ios-cmake-master/ios.toolchain.cmake"

get_toolchain_make_name() {
    case $1 in
        iphoneos) echo "OS64" ;;
        maccatalyst_x86_64) echo "MAC_CATALYST" ;;
        maccatalyst_arm64) echo "MAC_CATALYST_ARM64" ;;
        iphonesimulator_x86_64) echo "SIMULATOR64" ;;
        iphonesimulator_arm64) echo "SIMULATORARM64" ;;
    esac
}

# get_arch_name() {
#     case $1 in
#         iphoneos) echo "arm64" ;;
#         maccatalyst_x86_64) echo "x86_64" ;;
#         maccatalyst_arm64) echo "arm64" ;;
#         iphonesimulator_x86_64) echo "x86_64" ;;
#         iphonesimulator_arm64) echo "arm64" ;;
#     esac
# }

# get_sdk_name() {
#     case $1 in
#         iphoneos) echo "iphoneos" ;;
#         maccatalyst_x86_64) echo "macosx" ;;
#         maccatalyst_arm64) echo "macosx" ;;
#         iphonesimulator_x86_64) echo "iphonesimulator" ;;
#         iphonesimulator_arm64) echo "iphonesimulator" ;;
#     esac
# }

BUILD_SHARED_LIBS=OFF
WHISPER_BUILD_EXAMPLES=OFF
WHISPER_BUILD_TESTS=OFF
WHISPER_BUILD_SERVER=OFF
GGML_METAL=ON
GGML_METAL_EMBED_LIBRARY=ON
GGML_BLAS_DEFAULT=ON
GGML_METAL_USE_BF16=ON
GGML_OPENMP=OFF

# Common options for all builds
COMMON_CMAKE_ARGS=(
    -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    -DWHISPER_BUILD_EXAMPLES=${WHISPER_BUILD_EXAMPLES}
    -DWHISPER_BUILD_TESTS=${WHISPER_BUILD_TESTS}
    -DWHISPER_BUILD_SERVER=${WHISPER_BUILD_SERVER}
    -DGGML_METAL_EMBED_LIBRARY=${GGML_METAL_EMBED_LIBRARY}
    -DGGML_BLAS_DEFAULT=${GGML_BLAS_DEFAULT}
    -DGGML_METAL=${GGML_METAL}
    -DGGML_METAL_USE_BF16=${GGML_METAL_USE_BF16}
    -DGGML_NATIVE=OFF
    -DGGML_OPENMP=${GGML_OPENMP}
    -DWHISPER_COREML="ON"
    -DWHISPER_COREML_ALLOW_FALLBACK="ON"
)

# Setup the xcframework build directory structure
setup_framework_structure() {
    local build_dir=$1
    local min_os_version=$IOS_MIN_OS_VERSION
    local framework_name="whisper"

    echo "Creating framework structure for ${build_dir}"

    mkdir -p ${build_dir}/framework/${framework_name}.framework/Headers

        # Remove any existing structure to ensure clean build
    rm -rf ${build_dir}/framework/${framework_name}.framework/Versions

    # Set header and module paths
    local header_path=${build_dir}/framework/${framework_name}.framework/Headers/

    # Copy all required headers (common for all platforms)
    cp include/whisper.h           ${header_path}
    cp ggml/include/ggml.h         ${header_path}
    cp ggml/include/ggml-alloc.h   ${header_path}
    cp ggml/include/ggml-backend.h ${header_path}
    cp ggml/include/ggml-metal.h   ${header_path}
    cp ggml/include/ggml-cpu.h     ${header_path}
    cp ggml/include/ggml-blas.h    ${header_path}
    cp ggml/include/gguf.h         ${header_path}


    # Platform-specific settings for Info.plist
    local  supported_platform="iPhoneOS"
    local plist_path="${build_dir}/framework/${framework_name}.framework/Info.plist"

    # Create Info.plist
    cat > ${plist_path} << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>whisper</string>
    <key>CFBundleIdentifier</key>
    <string>org.ggml.whisper</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>whisper</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>MinimumOSVersion</key>
    <string>${min_os_version}</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>${supported_platform}</string>
    </array>
</dict>
</plist>
EOF
}

# Create dynamic libraries from static libraries.
combine_static_libraries() {
    local build_dir="$1"
    local base_dir="$(pwd)"
    local framework_name="whisper"

    # Determine output path based on platform
    local output_lib="${build_dir}/framework/${framework_name}.framework/${framework_name}"

    local libs=(
        "${base_dir}/${build_dir}/src/libwhisper.a"
        "${base_dir}/${build_dir}/ggml/src/libggml.a"
        "${base_dir}/${build_dir}/ggml/src/libggml-base.a"
        "${base_dir}/${build_dir}/ggml/src/libggml-cpu.a"
        "${base_dir}/${build_dir}/ggml/src/ggml-metal/libggml-metal.a"
        "${base_dir}/${build_dir}/ggml/src/ggml-blas/libggml-blas.a"
        # "${base_dir}/${build_dir}/src/libwhisper.coreml.a"
    )

    # Create temporary directory for processing
    local temp_dir="${base_dir}/${build_dir}/temp"
    echo "Creating temporary directory: ${temp_dir}"
    mkdir -p "${temp_dir}"

    # Since we have multiple architectures libtool will find object files that do not
    # match the target architecture. We suppress these warnings.
    libtool -static -o "${temp_dir}/combined.a" "${libs[@]}"

    echo "完成combined.a"

    echo "生成framework"

    # lipo -create "${temp_dir}/combined.a" -output "${base_dir}/${output_lib}"

    cp "${temp_dir}/combined.a" "${base_dir}/${output_lib}"

    echo "生成framework 结束"
}


for platform in "${buildlist[@]}"; do
    build_dir="build-$platform"
    DPLATFORM="$(get_toolchain_make_name $platform)"
    rm -rf "$build_dir"
    echo "构建：$platform DPLATFORM:$DPLATFORM"

    setup_framework_structure "$build_dir"

    cmake -B "$build_dir" \
        "${COMMON_CMAKE_ARGS[@]}" \
        -DCMAKE_TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE" \
        -DPLATFORM="$DPLATFORM" \
        -DSDK_VERSION="$IOS_MIN_OS_VERSION" \
        -DENABLE_BITCODE=YES \
        -S .
    cmake --build "$build_dir" --config Release

    combine_static_libraries "$build_dir"

done

echo "合并库"
rm -rf "$WTRToDir"
mkdir "$WTRToDir"


echo "合并 maccatalyst_x86_64 到 maccatalyst_arm64"
rm build-maccatalyst_arm64/framework/whisper.framework/whisper
lipo -create build-maccatalyst_x86_64/temp/combined.a build-maccatalyst_arm64/temp/combined.a -output build-maccatalyst_arm64/framework/whisper.framework/whisper

echo "合并 iphonesimulator_x86_64 到 iphonesimulator_arm64"
rm build-iphonesimulator_arm64/framework/whisper.framework/whisper
lipo -create build-iphonesimulator_x86_64/temp/combined.a build-iphonesimulator_arm64/temp/combined.a -output build-iphonesimulator_arm64/framework/whisper.framework/whisper


echo "生成xcframework"

TO_PATH=$WTRToDir/whisper.xcframework

BUILD_COMMAND="xcodebuild -create-xcframework "

buildlistXC=(
    "iphoneos"
    "maccatalyst_arm64"
    "iphonesimulator_arm64"
    )

for platform in "${buildlistXC[@]}"; do
    build_dir="build-$platform"
    BUILD_COMMAND+=" -framework $build_dir/framework/whisper.framework"
done

BUILD_COMMAND+=" -output ${TO_PATH}"

${BUILD_COMMAND}

echo "完成"



