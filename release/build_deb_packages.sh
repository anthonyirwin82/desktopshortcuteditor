#!/usr/bin/sh
#
# This is a build script that will build the lazarus desktop application and
# package it into Debian .deb packages for qt5 and qt6 on the amd64 and arm64
# Debian cpu architectures.
# It relies on the Lazarus Project Options - Build Modes to work.
# You need to have the following build mode names:
# linux_amd64-qt5, linux_amd64-qt6, linux_arm64-qt5, linux_arm64-qt6
# You also need to be building the target file as: 
# bin/AppName-$(TargetCPU)-$(TargetOS)-WidgetSet

VERSION=1.0.0
PROJECT=DesktopShortcutEditor.lpi
PROJECT_PATH=${HOME}/repos/pascal/DesktopShortcutEditor
NAME=desktop-shortcut-editor
TITLE="Desktop Shortcut Editor"
DESCRIPTION="Desktop Shortcut Editor makes it very easy to add, search and edit desktop entry files in desktop environments and application launchers that uses the free desktop entry file specification."
MAINTAINER="Anthony Irwin"
ICON=desktop-shortcut-editor.png
LAZBUILD=${HOME}/fpcupdeluxe/files/lazarus/lazbuild
PCP=${HOME}/fpcupdeluxe/files/config_lazarus
# Debian Control file Specfic
DEB_DIR=${PROJECT_PATH}/release/deb
DEB_QT5=libqt5pas1
DEB_QT6=libqt6pas6
DEB_DEPENDS=""
DEB_SECTION="utils"

rm ${PROJECT_PATH}/src/bin/* # Delete all build files

# Build binary files. --bm names come from lazarus project options build modes
$LAZBUILD ${PROJECT_PATH}/src/${PROJECT} -B --pcp=${PCP} --bm=linux_amd64-qt5
$LAZBUILD ${PROJECT_PATH}/src/${PROJECT} -B --pcp=${PCP} --bm=linux_amd64-qt6
$LAZBUILD ${PROJECT_PATH}/src/${PROJECT} -B --pcp=${PCP} --bm=linux_arm64-qt5
$LAZBUILD ${PROJECT_PATH}/src/${PROJECT} -B --pcp=${PCP} --bm=linux_arm64-qt6

rm -rf ${DEB_DIR} # Delete all existing files

for CPU in "amd64" "arm64"
do
   # Lazarus cpu architecture names differ from Debian Architecture names
   CPU_NAME=""
   if [ "$CPU" = "amd64" ]; then
      CPU_NAME="x86_64"
   fi

   if [ "$CPU" = "arm64" ]; then
      CPU_NAME="aarch64"
   fi

   echo "Building Deb Directories for the ${CPU} architecture"
   for WIDGET in "qt5" "qt6"
   do
      DEB_DEPENDS_ON=""
      # Add Qt dependencies
      if [ "$WIDGET" = "qt5" ]; then
         DEB_DEPENDS_ON="${DEB_QT5} ${DEB_DEPENDS}"
      fi

      if [ "$WIDGET" = "qt6" ]; then
         DEB_DEPENDS_ON="${DEB_QT6} ${DEB_DEPENDS}"
      fi

      echo "Building Deb directories for the ${WIDGET} widget set"
      mkdir -p ${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/DEBIAN
      mkdir -p ${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/usr/share/applications
      mkdir -p ${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/usr/bin
      mkdir -p ${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/usr/share/pixmaps

      # Copy the icon
      cp ${PROJECT_PATH}/src/icons/${ICON} ${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/usr/share/pixmaps
      # Copy application binary
      cp ${PROJECT_PATH}/src/bin/*${CPU_NAME}-linux-${WIDGET} ${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/usr/bin/${NAME}

      # Create the desktop file
      cat > "${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/usr/share/applications/${NAME}.desktop" <<EOF
[Desktop Entry]
Name=${TITLE}
Exec=/usr/bin/${NAME}
Icon=/usr/share/pixmaps/${ICON}
Type=Application
Categories=Utility;
EOF

      # Create the Debain control file
      cat > "${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/DEBIAN/control" <<EOF
Package: ${NAME}
Version: ${VERSION}
Section: ${DEB_SECTION}
Priority: optional
Architecture: ${CPU}
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
Depends: ${DEB_DEPENDS_ON}
EOF

      # Build the debian package
      dpkg-deb --build --root-owner-group "${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}"
   done
done

mv ${DEB_DIR}/*.deb ${PROJECT_PATH}/release