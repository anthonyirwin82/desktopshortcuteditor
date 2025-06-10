---
title: Using Desktop Shortcut Editor
permalink: /docs/getting-started/home/
redirect_from: /docs/index.html
order: 1
---
Desktop Shortcut Editor makes it very easy to add, search and edit desktop entry files in desktop environments and application launchers that uses the free desktop specification. 

![Desktop Shortcut Editor Main Screen]({{ site.baseurl }}/assets/img/desktopshortcuteditor-main.png "Desktop Shortcut Editor Main Screen")

## Searching for exising Desktop Entry Files
You can search for desktop files by using the search box above the list of desktop file entries.

![Desktop Shortcut Editor Search Screen]({{ site.baseurl }}/assets/img/desktopshortcuteditor-search.png "Desktop Shortcut Editor Search Screen")

## Changing the applications directory being shown
You can change the applications directory being shown by clicking the location buttons at the top of the screen. You can also use alt + 1, alt + 2 and alt + 3 to change directories using the keyboard shortcuts.

![Desktop Shortcut Editor Changing the applications directory shown]({{ site.baseurl }}/assets/img/desktopshortcuteditor-change-directories.png "Desktop Shortcut Editor Changing the applications directory shown")

## Editing Desktop Entry Files
You can edit desktop entry files by either double clicking it in the list or by clicking the 'Edit File in Text Editor' button. If there are no desktop entry files to edit then the 'Edit File in Text Editor' button will be disabled.

If you require root access to edit the desktop entry file then a password dialog will popup to edit the file with elevated privileges.

![Desktop Shortcut Editor Edit Screen]({{ site.baseurl }}/assets/img/desktopshortcuteditor-edit.png "Desktop Shortcut Editor Edit Screen")

## Adding New Desktop Entry Files

To add a new desktop entry file you enter the filename with the .desktop extension then click the 'Add' button. If the 'Add' button is disabled then the file name is not valid.

If you need root access to create the file then a password dialog will popup to create the file with elevated privileges.

![Desktop Shortcut Editor Add Screen]({{ site.baseurl }}/assets/img/desktopshortcuteditor-add.png "Desktop Shortcut Editor Add Screen")

## Warning About Overwriting Existing Desktop Entry Files

If the desktop entry filename already exists then you will get a warning dialog pop up. In most cases you should click the 'No' button because overwriting the file will create a blank new template for creating new desktop entry files and all existing information in the file will be lost.

![Desktop Shortcut Editor Overwrite Screen]({{ site.baseurl }}/assets/img/desktopshortcuteditor-overwrite.png "Desktop Shortcut Editor Overwrite Screen")

## Information About the Desktop Entry file

If you want more information on what can be put inside a desktop entry file then you can check the official desktop entry file specification at the [Desktop Entry Specification](https://specifications.freedesktop.org/desktop-entry-spec/latest/).