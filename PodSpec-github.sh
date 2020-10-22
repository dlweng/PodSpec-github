#!/bin/bash -x
#自动发布基于CocoaPods的GizWifiSDK
PodSpecPath="/Users/danlypro/Desktop/SDK/SDKRelease/github/PodSpecs"
# LibraryPath="/Users/danlypro/Desktop/SDK/SDKRelease/github/GizWifiSDK_library"
WifiSDKLibraryPath="/Users/danlypro/Desktop/SDK/SDKRelease/github/GizWifiSDK_cocoapod"
AepSDKLibraryPath="/Users/danlypro/Desktop/SDK/SDKRelease/github/GizAepWifiSDK_cocoapod"

if [ ! -f GizWifiSDK*.zip ]
then
    echo "\033[31m没有找到SDK，请把SDK的zip包放在当前执行的目录下\033[0m"
    exit 1
fi

#获取当前路径
currentDir=$(pwd)

#获取sdk版本号
wifiSDKVersion=$1
aepSDKVersion=$2

#路径使用的是github还是oschina
prefix="github.com/gizwits";
#prefix="git.oschina.net/dantang"

echo "使用须知："
echo "\033[31m确保本地仓库有相应的git提交权限\033[0m"

if [ ${#wifiSDKVersion} = 0 ]
then
    echo "\033[31m请在执行脚本是输入wifiSDK版本, 执行脚本的正确格式如: PodSpec-github.sh <wifiSDK版本号> <AepWifiSDK版本号> \033[0m"
    exit 2
fi

# 建立新SDK的podSpec配置文件
if [ ${#PodSpecPath} = 0 ]
then
    echo "没有<PodSpecs>源码目录，跳过"
else
    if [ ! -x ${PodSpecPath} ]
    then
        echo "\033[31m找不到目录：${PodSpecPath}\033[0m"
        exit 0
    fi

    #处理第一个仓库的信息，创建目录、生成podspec文件
    echo "正在自动生成WifiSDKPodSpec配置..."
    cd "${PodSpecPath}"
    git pull

    cd "GizWifiSDK"
    mkdir -p "${wifiSDKVersion}"
    cd "${wifiSDKVersion}"

    #填充以下内容
    echo -e "Pod::Spec.new do |s| \n\t\
    s.name         = \"GizWifiSDK\" \n\t\
    s.version      = \"${wifiSDKVersion}\" \n\t\
    s.summary      = \"GizWifiSDK dynamic library for iOS\"  \n\t\
    s.description  = \"GizWifiSDK is a Wi-Fi hardware communication toolkit. Support architechures: armv7, arm64, x86_64, i386.\"\n\t\
    s.homepage     = \"http://dev.gizwits.com\"   \n\t\
    s.license      = { :type => \"MIT\", :file => \"LICENSE\" } \n\t\
    s.author             = { \"danly\" => \"dlweng@gizwits.com\" } \n\t\
    s.ios.deployment_target = \"9.0\"  \n\t\
    s.source       = { :git => \"https://github.com/gizwits/GizWifiSDK_cocoapod.git\", :tag => \"#{s.version}\" } \n\t\
    s.requires_arc = true  \n\t\
    s.source_files  = \"GizWifiSDK/GizWifiSDK.framework/Headers/*.h\" \n\t\
    s.vendored_frameworks = \"GizWifiSDK/GizWifiSDK.framework\" \n\t\
    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' } \n\t\
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' } \n\t\
    end" > "GizWifiSDK.podspec"


    #处理第一个仓库的信息，创建目录、生成podspec文件
    echo "正在自动生成AepWifiSDKPodSpec配置..."

    cd "${PodSpecPath}"
    cd "GizAepWifiSDK"
    mkdir -p "${aepSDKVersion}"
    cd "${aepSDKVersion}"

    #填充以下内容
    echo -e "Pod::Spec.new do |s| \n\t\
    s.name         = \"GizAepWifiSDK\" \n\t\
    s.version      = \"${aepSDKVersion}\" \n\t\
    s.summary      = \"GizAepWifiSDK dynamic library for iOS\"  \n\t\
    s.description  = \"GizAepWifiSDK is a Wi-Fi hardware communication toolkit. Support architechures: armv7, arm64, x86_64, i386。\" \n\t\
    s.homepage     = \"http://dev.gizwits.com\"   \n\t\
    s.license      = { :type => \"MIT\", :file => \"LICENSE\" } \n\t\
    s.author             = { \"danly\" => \"dlweng@gizwits.com\" } \n\t\
    s.ios.deployment_target = \"9.0\"  \n\t\
    s.source       = { :git => \"https://github.com/gizwits/GizAepWifiSDK_cocoapod.git\", :tag => \"#{s.version}\" } \n\t\
    s.requires_arc = true  \n\t\
    s.source_files  = \"GizAepWifiSDK/GizAepWifiSDK.framework/Headers/*.h\" \n\t\
    s.vendored_frameworks = \"GizAepWifiSDK/GizAepWifiSDK.framework\" 
    s.dependency \"GizWifiSDK\", \"${wifiSDKVersion}\" \n\t\
    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' } \n\t\
    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' } \n\t\
    end" > "GizAepWifiSDK.podspec"

    cd "${PodSpecPath}"
    #提交
    git add .
    git commit -m "更新了GizWifiSDK版本号为${wifiSDKVersion}，GizAepWifiSDK版本号为${aepSDKVersion}"
    git push
fi

#上传新的SDK库
for path in ${WifiSDKLibraryPath} ${AepSDKLibraryPath}
do
if [ ${#path} = 0 ]
then
    echo "没有GizWifiSDK framework目录，跳过"
else
    if [ ! -x ${path} ]
    then
        echo "\033[31m找不到目录：${path}\033[0m"
        exit 0
    fi

    #解压当前目录下的SDK到指定的目录
    cd ${path}
    git pull

    rm -rf tmp
    mkdir -p tmp
    cd tmp
    echo "解压缩SDK..."
    unzip "${currentDir}/GizWifiSDK*.zip" > /dev/null

    #查找目录
    dirname=$(find . -iname "GizWifiSDK*" -d 1 -print0 | xargs -0 echo)
    
    SDKName="GizWifiSDK"
    version=${wifiSDKVersion}
    result=$(echo $path | grep "GizWifiSDK")
    if [[ "$result" != "" ]]
    then
        SDKName="GizWifiSDK"
        version=${wifiSDKVersion}
    else
        SDKName="GizAepWifiSDK"
        version=${aepSDKVersion}
    fi

    #复制动态库
    rm -rf ../${SDKName}
    mkdir -p ../${SDKName}
    cp -a ${dirname}/${SDKName}.framework ../${SDKName}/

    #清理
    cd "${path}"
    rm -rf tmp

    #提交
    git add .
    git commit -m "更新了版本号为${version}"
    git push
    git tag ${version}
    git push origin tag ${version}
fi
done 
