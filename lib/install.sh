#!/bin/sh

tracy_version="v0.10"
# sdk_version="vulkan-sdk-1.3.275.0"

git submodule add https://github.com/wolfpld/tracy.git
# git submodule add https://github.com/KhronosGroup/SPIRV-Headers.git
# git submodule add https://github.com/KhronosGroup/SPIRV-Tools.git
# git submodule add https://github.com/KhronosGroup/Vulkan-Headers.git
# git submodule add https://github.com/KhronosGroup/Vulkan-Loader.git

cd tracy/
git reset --hard $tracy_version
cd ../
# cd SPIRV-Headers/
# git reset --hard $sdk_version
# cd ../
# cd SPIRV-Tools/
# git reset --hard $sdk_version
# # cmake
# cd ../
# cd Vulkan-Headers/
# git reset --hard $sdk_version
# cd ../
# cd Vulkan-Loader/
# git reset --hard $sdk_version
# # cmake
# cd ../
