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
DESCRIPTION="Desktop Shortcut Editor makes it very easy to add, search and edit desktop entry files in desktop environments and application launchers that use the free desktop entry file specification."
MAINTAINER="Anthony Irwin"
ICON=desktop-shortcut-editor.png
LAZBUILD=${HOME}/fpcupdeluxe/files/lazarus/lazbuild
PCP=${HOME}/fpcupdeluxe/files/config_lazarus
# RPM Spec specific
RPM_DIR=${PROJECT_PATH}/release/rpm
RPM_GTK2=gtk2
RPM_QT5=qt5pas
RPM_QT6=qt6pas
RPM_DEPENDS="polkit"
RPM_SECTION="Applications/Utilities"
RPM_SUMMARY="Utility to manage desktop entries"
RPM_LICENSE="MIT"
RPM_URL="https://desktopshortcuteditor.anthonyirwin.com" # Replace with actual project URL

rm ${PROJECT_PATH}/src/bin/* # Delete all build files

rm -rf ${RPM_DIR} # Delete all existing files

CPU_NAME=""
RPM_ARCH=""
RPM_DEPENDS_ON=""
for CPU in "amd64" "arm64"; do
  # Map Lazarus CPU names to RPM architecture names
  case "$CPU" in
    amd64)
      CPU_NAME="x86_64"
      RPM_ARCH="x86_64"
      ;;
    arm64)
      CPU_NAME="aarch64"
      RPM_ARCH="aarch64"
      ;;
  esac

  for WIDGET in "gtk2" "qt5" "qt6"; do
      RPM_DEPENDS_ON=""
      # Add Qt/Gtk dependencies
      case "$WIDGET" in
         qt5)
            RPM_DEPENDS_ON="${RPM_QT5}, ${RPM_DEPENDS}"
            ;;
         qt6)
            RPM_DEPENDS_ON="${RPM_QT6}, ${RPM_DEPENDS}"
            ;;
         gtk2)
            RPM_DEPENDS_ON="${RPM_GTK2}, ${RPM_DEPENDS}"
            ;;
         *)
            RPM_DEPENDS_ON="${RPM_DEPENDS}"
            ;;
      esac

      echo "--------------------------------------------------------------------"
      echo "Building Project for ${CPU} architecture with ${WIDGET} widget set"
      echo "--------------------------------------------------------------------"

      $LAZBUILD ${PROJECT_PATH}/src/${PROJECT} -B --pcp=${PCP} --bm=linux_${CPU}-${WIDGET}

      echo "Preparing RPM directory structure for ${WIDGET}"
      BUILDROOT=${RPM_DIR}/${NAME}-${VERSION}-${CPU_NAME}-${WIDGET}/BUILDROOT
      RPMBUILD_DIR=${RPM_DIR}/${NAME}-${VERSION}-${CPU_NAME}-${WIDGET}/rpmbuild

      mkdir -p ${BUILDROOT}/usr/share/{applications,pixmaps}
      mkdir -p ${BUILDROOT}/usr/bin
      mkdir -p ${RPMBUILD_DIR}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
      mkdir -p ${RPMBUILD_DIR}/SOURCE_TEMP/${NAME}-${VERSION}

      # Copy icon
      cp ${PROJECT_PATH}/src/icons/${ICON} ${BUILDROOT}/usr/share/pixmaps

      # Copy application binary
      cp ${PROJECT_PATH}/src/bin/*${CPU_NAME}-linux-${WIDGET} ${BUILDROOT}/usr/bin/${NAME}

      # Create desktop file
      cat > "${BUILDROOT}/usr/share/applications/${NAME}.desktop" <<EOF
[Desktop Entry]
Name=${TITLE}
Exec=/usr/bin/${NAME}
Icon=/usr/share/pixmaps/${ICON}
Type=Application
Categories=Utility;
EOF

      # Create source tarball (rpmbuild requires this)
      
      cp -a ${BUILDROOT}/* ${RPMBUILD_DIR}/SOURCE_TEMP/${NAME}-${VERSION}/
      tar czf ${RPMBUILD_DIR}/SOURCES/${NAME}-${VERSION}.tar.gz -C ${RPMBUILD_DIR}/SOURCE_TEMP ${NAME}-${VERSION}


      # Create spec file
SPECFILE=${RPMBUILD_DIR}/SPECS/${NAME}-${CPU_NAME}-${WIDGET}.spec
cat > "${SPECFILE}" <<EOF
Name:           ${NAME}
Version:        ${VERSION}
Release:        1.%{widget}
Summary:        ${RPM_SUMMARY}
License:        ${RPM_LICENSE}
URL:            ${RPM_URL}
Packager:       ${MAINTAINER}
Requires:       ${RPM_DEPENDS_ON}
BuildArch:      ${RPM_ARCH}
Source0:        ${NAME}-${VERSION}.tar.gz

%define debug_package %{nil}

%description
${DESCRIPTION}

%prep
%setup -q

%build
# Nothing to build since binaries are precompiled

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/pixmaps

cp -a usr/bin/${NAME} %{buildroot}/usr/bin/
cp -a usr/share/applications/${NAME}.desktop %{buildroot}/usr/share/applications/
cp -a usr/share/pixmaps/${ICON} %{buildroot}/usr/share/pixmaps/

%files
%attr(0755,root,root) /usr/bin/${NAME}
/usr/share/applications/${NAME}.desktop
/usr/share/pixmaps/${ICON}

%changelog
* $(date "+%a %b %d %Y") ${MAINTAINER} - ${VERSION}-1
- Initial RPM release for ${CPU_NAME} ${WIDGET}
EOF


      echo "Building RPM for ${CPU_NAME} ${WIDGET}"
      rpmbuild -bb --target=${RPM_ARCH} \
         --define "widget ${WIDGET}" \
         --define "_topdir ${RPMBUILD_DIR}" \
         --define "_sourcedir ${RPMBUILD_DIR}/SOURCES" \
         --define "_specdir ${RPMBUILD_DIR}/SPECS" \
         --define "_rpmdir ${RPMBUILD_DIR}/RPMS" \
         --define "_builddir ${RPMBUILD_DIR}/BUILD" \
         --define "_srcrpmdir ${RPMBUILD_DIR}/SRPMS" \
         "${SPECFILE}"


  done
done

echo "Collecting built RPM packages..."
find ${RPM_DIR} -name "*.rpm" -exec mv {} ${PROJECT_PATH}/release/ \;

echo "RPM package build completed."
