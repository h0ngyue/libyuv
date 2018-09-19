#!/usr/bin/env bash
# 这个脚本主要用来做build + cdep发布

version="1.0.0"
artifactId="libyuv"
groupId="com.github.h0ngyue" 

ndk-build -j8

mkdir upload
mkdir staging

# zip -X是为了不附带extradata，这样每次打包同样的文件出来的 md5是一致的，不会加入动态的timestamp等信息
# 打包include
cp -Rp jni/include/ staging/include
pushd staging
zip -rX ../upload/libyuv-headers.zip include
popd

# 打包 armeabi-v7a.zip
mkdir -p staging/lib/armeabi-v7a
cp obj/local/armeabi-v7a/libyuv.a staging/lib/armeabi-v7a
pushd staging
zip -rX ../upload/libyuv-armeabi-v7a.zip lib
popd

# only for debug
# rm upload/cdep-manifest.yml

printf "%s\r\n" "coordinate:" > upload/cdep-manifest.yml
printf "  %s\r\n" "groupId: ${groupId}" >> upload/cdep-manifest.yml
printf "  %s\r\n" "artifactId: ${artifactId}" >> upload/cdep-manifest.yml
printf "  %s\r\n" "version: ${version} " >> upload/cdep-manifest.yml

printf "%s\r\n" "license:" >> upload/cdep-manifest.yml
printf "  %s\r\n" "url: git@github.com:h0ngyue/libyuv.git"  >> upload/cdep-manifest.yml


printf "%s\r\n" "interfaces:" >> upload/cdep-manifest.yml
printf "  %s\r\n" "headers:" >> upload/cdep-manifest.yml
printf "    %s\r\n" "file: libyuv-headers.zip" >> upload/cdep-manifest.yml
printf "    %s\r\n" "include: include" >> upload/cdep-manifest.yml
printf "    sha256: " >> upload/cdep-manifest.yml
shasum -a 256 upload/libyuv-headers.zip | awk '{print $1}' >> upload/cdep-manifest.yml
printf "    size: " >> upload/cdep-manifest.yml
ls -l upload/libyuv-headers.zip | awk '{print $5}' >> upload/cdep-manifest.yml


printf "%s\r\n" "android:" >> upload/cdep-manifest.yml
printf "  %s\r\n" "archives:" >> upload/cdep-manifest.yml
printf "    %s\r\n" "- file: libyuv-armeabi-v7a.zip" >> upload/cdep-manifest.yml
printf "      sha256: " >> upload/cdep-manifest.yml
shasum -a 256 upload/libyuv-armeabi-v7a.zip | awk '{print $1}' >> upload/cdep-manifest.yml
printf "      size: " >> upload/cdep-manifest.yml
ls -l upload/libyuv-armeabi-v7a.zip | awk '{print $5}' >> upload/cdep-manifest.yml

printf "    %s\r\n" "  abi: armeabi-v7a" >> upload/cdep-manifest.yml
printf "    %s\r\n" "  platform: 14" >> upload/cdep-manifest.yml
printf "      libs: [libyuv.a]\r\n" >> upload/cdep-manifest.yml
