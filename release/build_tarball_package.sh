#!/usr/bin/sh
#
# This is a build script that will build the lazarus desktop application and
# package it into RPM packages for qt5 and qt6 on the x86_64 and aarch64
# Linux RPM-based distributions.
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
ICON=desktop-shortcut-editor.png
LAZBUILD=${HOME}/fpcupdeluxe/files/lazarus/lazbuild
PCP=${HOME}/fpcupdeluxe/files/config_lazarus

rm ${PROJECT_PATH}/src/bin/* # Delete all build files
rm -rf ${PROJECT_PATH}/release/tarball # Delete all existing 


for CPU in "amd64" "arm64"; do
    # Map Lazarus CPU names to Debian architecture names
    case "$CPU" in
        amd64) CPU_NAME="x86_64" ;;
        arm64) CPU_NAME="aarch64" ;;
    esac

    RELEASE_PATH="${PROJECT_PATH}/release/tarball/${NAME}-${VERSION}-${CPU_NAME}"

    mkdir -p ${RELEASE_PATH}

    for WIDGET in "gtk2" "qt5" "qt6"; do
        echo "--------------------------------------------------------------------\n"
        echo "Building Project for ${CPU} architecture with ${WIDGET} widget set\n"
        echo "--------------------------------------------------------------------\n"
        
        $LAZBUILD ${PROJECT_PATH}/src/${PROJECT} -B --pcp=${PCP} --bm=linux_${CPU}-${WIDGET}
    done

    cp ${PROJECT_PATH}/src/bin/*${CPU_NAME}* ${RELEASE_PATH}
    cp ${PROJECT_PATH}/src/icons/${ICON} ${RELEASE_PATH}

    cat > "${RELEASE_PATH}/readme" <<EOF
${TITLE}

${DESCRIPTION}

Requirements:

To use gtk2 you need the gtk2 libraries installed on the computer.

To use qt5 you need the qt5 libraries and the libqt5pas library installed on your computer.

To use qt6 you need the qt6 libraries and the libqt6pas library installed on your computer.

Each linux distribution has different package names so do a search in a search engine to find out how to install these libraries on your system.
EOF


    tar czf ${PROJECT_PATH}/release/${NAME}-${VERSION}-${CPU_NAME}-all.tar.gz -C ${PROJECT_PATH}/release/tarball ${NAME}-${VERSION}-${CPU_NAME}
done
