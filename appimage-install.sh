#!/usr/bin/env bash
name=$1 # path to appimage

# Verify the path passed in actually exists
if [[ ! -f ${name} ]]; then
  echo "File ${name} not found"
  echo "Please input the ful path to the appimage"
  echo "example: ./app-image-install.sh  ~/Downloads/my-appimage.AppImage"
  exit 1
fi

# Create the Applications directory if it doesn't exist
echo "Checking for ~/Applications"
if [[ ! -d ~/Applications ]]; then
  echo "Creating ~/Applications"
  mkdir -p ~/Applications
else
  echo "Found ~/Applications/ ... continuing"
fi

# Set some variables
appname=$(basename $name)
finalapp=~/Applications/${appname}
desk_dir=~/.local/share/applications/ # This is where the .desktop file goes
squash_dir=squashfs-root/ # this is the extracted appimage

cp ${name} ${finalapp}
# Creating staging environment
echo "Creating staging environment in /var/tmp/${appname}"
mkdir -p /var/tmp/${appname}
# Enter staging environment for things
cd /var/tmp/${appname}
echo "Preparing to install ${appname}."
# make the appimage executable
chmod 755 ${finalapp}
## Extract Desktop file and icon from appimage.
echo "Extracting appimage files"
${finalapp} --appimage-extract >>/dev/null 2>&1
app_desk_name=$(basename squashfs-root/*.desktop)

app_icon_location=$(find ${squash_dir} -type f -iname *.png)
app_desk_location=$(find ${squash_dir} -type f -iname *.desktop)
app_icon_name=$(basename ${app_icon_location})

## copy the icon file to ~/.local/share/icons/
cp ${app_icon_location} ~/.local/share/icons/${app_icon_name}

## Edit the app.desktop file
cp ${app_desk_location} ${desk_dir}/${app_desk_name}
sed -i -e "s/Exec=.*/Exec=\/home\/$USER\/Applications\/${appname}/g" ${desk_dir}/${app_desk_name}
cd /var/tmp/
echo "So far so good! Cleaning up staging environment"
rm -rf /var/tmp/${appname}
echo "${appname} has been installed."
