pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland

/**
 * Manages a HyprlandFocusGrab that's to be shared by all windows.
 * "Persistent" is for windows that should always be included but not closed on dismiss, like bar and onscreen keyboard.
 * "Dismissable" is for stuff like sidebars
 */ 
Singleton {
    id: root

    signal dismissed()

    property list<var> persistent: []
    property list<var> dismissable: []

    function dismiss() {
        root.dismissable = [];
        root.dismissed();
    }

    Component.onCompleted: {
        console.log("[GlobalFocusGrab] Initialized");
    }

    function addPersistent(window) {
        if (root.persistent.indexOf(window) === -1) {
            root.persistent.push(window);
        }
    }

    function removePersistent(window) {
        var index = root.persistent.indexOf(window);
        if (index !== -1) {
            root.persistent.splice(index, 1);
        }
    }

    function addDismissable(window) {
        if (root.dismissable.indexOf(window) === -1) {
            root.dismissable.push(window);
        }
    }

    function removeDismissable(window) {
        var index = root.dismissable.indexOf(window);
        if (index !== -1) {
            root.dismissable.splice(index, 1);
        }
    }

    function hasActive(element) {
        return element?.activeFocus || Array.from(
            element?.children
        ).some(
            (child) => hasActive(child)
        );
    }

    // Debounce timer to prevent immediate dismiss on transient cleared events.
    // When windows list changes during content load, HyprlandFocusGrab can be
    // cleared and re-activated rapidly. Without debounce this causes sidebars
    // to "blink" (open then immediately close).
    Timer {
        id: dismissDebounce
        interval: 100
        onTriggered: {
            if (!grab.active) {
                root.dismiss();
            }
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: root.dismissable.every(w => !w?.focusable) || root.dismissable.some(w => hasActive(w?.contentItem)) ? [...root.dismissable, ...root.persistent] : [...root.dismissable]
        active: root.dismissable.length > 0
        onCleared: () => {
            dismissDebounce.restart();
        }
    }

}
