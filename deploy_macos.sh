### x86_64 on arm
# softwareupdate --install-rosetta --agree-to-license
# arch -x86_64 zsh

### 0. Install developer software
echo "Installing HomeBrew & CommandLineTools"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [[ `uname -p` == arm ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi

### 1. Prepare environment

# Mojave compatibility
brew install curl

brew install cmake pkg-config sdl12-compat sdl_image sdl_gfx sdl_mixer yaml-cpp doxygen

cd ~
git clone https://github.com/MeridianOXC/OpenXcom.git
mkdir OpenXcom/build && cd OpenXcom/build
cmake .. -DCMAKE_BUILD_TYPE=Release 
# -DCMAKE_OSX_DEPLOYMENT_TARGET=12

### 2. Copy SDL2 to bundle
mkdir -p openxcom.app/Contents/Frameworks/
libSDL2=`brew info SDL2 | grep Cellar | awk '{print $1}'`
cp $libSDL2/lib/libSDL2-2.0.0.dylib openxcom.app/Contents/Frameworks

### 3. Make and install

make -j4
# fix SDL distribute
sudo xattr -cr openxcom.app
codesign --force --deep --sign - openxcom.app
mv /Applications/openxcom.app /Applications/openxcom_old.app 
mv openxcom.app /Applications

### 4. Clean environment
# sources
cd ../..
rm -rf ./OpenXcom

# remove developer software
read -q "REPLY?Remove HomeBrew and free 1Gb? (y/n) "
read -p "Remove HomeBrew and free 1Gb? (y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    echo "Clean HomeBrew data"
    sudo rm -r /opt/homebrew
    sudo rm -r /usr/local/homebrew
fi

read -q "REPLY?Remove CommandLineTools and free 4Gb? (y/n) "
read -p "Remove CommandLineTools and free 4Gb? (y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -r /Library/Developer/CommandLineTools
fi
echo
