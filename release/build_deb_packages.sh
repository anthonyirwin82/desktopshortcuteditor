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
PROJECT_PATH=${HOME}/repos/pascal/desktopshortcuteditor
NAME=desktop-shortcut-editor
TITLE="Desktop Shortcut Editor"
DESCRIPTION="Desktop Shortcut Editor makes it very easy to add, search and edit desktop entry files in desktop environments and application launchers that uses the free desktop entry file specification."
MAINTAINER="Anthony Irwin"
ICON=desktop-shortcut-editor.png
LAZBUILD=${HOME}/fpcupdeluxe/files/lazarus/lazbuild
PCP=${HOME}/fpcupdeluxe/files/config_lazarus
# Debian Control file Specfic
DEB_DIR=${PROJECT_PATH}/release/deb
DEB_GTK2=libgtk2.0-0
DEB_QT5=libqt5pas1
DEB_QT6=libqt6pas6
DEB_DEPENDS="policykit-1"
DEB_SECTION="utils"

rm ${PROJECT_PATH}/src/bin/* # Delete all build files

rm -rf ${DEB_DIR} # Delete all existing files

CPU_NAME=""
DEB_DEPENDS_ON=""
for CPU in "amd64" "arm64"; do
  # Map Lazarus CPU names to Debian architecture names
  case "$CPU" in
    amd64) CPU_NAME="x86_64" ;;
    arm64) CPU_NAME="aarch64" ;;
  esac

  for WIDGET in "gtk2" "qt5" "qt6"; do
      DEB_DEPENDS_ON=""
      # Add Qt dependencies
      case "$WIDGET" in
         qt5)
            DEB_DEPENDS_ON="${DEB_QT5}, ${DEB_DEPENDS}"
            ;;
         qt6)
            DEB_DEPENDS_ON="${DEB_QT6}, ${DEB_DEPENDS}"
            ;;
         gtk2)
            DEB_DEPENDS_ON="${DEB_GTK2}, ${DEB_DEPENDS}"
            ;;
         *)
            DEB_DEPENDS_ON="${DEB_DEPENDS}"
            ;;
      esac

      echo "--------------------------------------------------------------------\n"
      echo "Building Project for ${CPU} architecture with ${WIDGET} widget set\n"
      echo "--------------------------------------------------------------------\n"
      
      $LAZBUILD ${PROJECT_PATH}/src/${PROJECT} -B --pcp=${PCP} --bm=linux_${CPU}-${WIDGET}

      echo "Building Deb directories for the ${WIDGET} widget set"
      mkdir -p ${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/DEBIAN
      mkdir -p ${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/usr/share/{applications,pixmaps}
      mkdir -p ${DEB_DIR}/${NAME}-${VERSION}-${CPU}-${WIDGET}/usr/bin

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