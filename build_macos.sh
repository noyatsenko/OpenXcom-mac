### 0. Install developer software
echo "Installing HomeBrew & CommandLineTools"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [[ $CPUTYPE == arm64 ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

### 1. Prepare environment

brew install cmake pkg-config sdl12-compat sdl_image sdl_gfx sdl_mixer yaml-cpp doxygen
git clone https://github.com/MeridianOXC/OpenXcom.git
mkdir OpenXcom/build && cd OpenXcom/build
cmake .. -DCMAKE_BUILD_TYPE=Release

### 2. Update post-build config OpenXcom/cmake/modules/PostprocessBundle.cmake for link HomeBrew libs

BREWDIR=`brew config | grep HOMEBREW_PREFIX | awk '{print $2}'`
FIND='fixup_bundle("${BUNDLE_PATH}" "${BUNDLE_LIBS}" "")'
REPLACE='fixup_bundle("${BUNDLE_PATH}" "${BUNDLE_LIBS}" "'$BREWDIR'/lib")'
sed -i '' "s,$FIND,$REPLACE," ../cmake/modules/PostprocessBundle.cmake 

### 3. Copy SDL2 to bundle
mkdir -p openxcom.app/Contents/Frameworks/
libSDL2=`brew info SDL2 | grep Cellar | awk '{print $1}'`
cp $libSDL2/lib/libSDL2-2.0.0.dylib openxcom.app/Contents/Frameworks

### 4. Make and install

make -j4
codesign --force --deep --sign - openxcom.app
mv /Applications/openxcom.app /Applications/openxcom_old.app 
mv openxcom.app /Applications

### 5. Clear environment

###remove sources
#cd ../..
#rm -rf ./OpenXcom

#remove developer software
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
#sudo rm -r /opt/homebrew
#sudo rm -r /Library/Developer/CommandLineTools
