#include "../platform_utils.h"

#include "../logging.h"

#include <QApplication>
#include <QClipboard>
#include <QMimeData>
#include <QThread>

#ifdef ZENNY_HAS_XTEST
#include <X11/XKBlib.h>
#include <X11/Xlib.h>
#include <X11/keysym.h>

extern "C" {
Bool XTestFakeKeyEvent(Display *, unsigned int, Bool, unsigned long);
}
#endif

namespace zenny
{

void pasteTextToActiveWindow(const QString &text, bool useClipboard,
                             bool copyToClipboard, bool restoreClipboard)
{
    if (text.isEmpty()) {
        return;
    }

    QClipboard *clipboard = QApplication::clipboard();
    if (!clipboard) {
        return;
    }

    if (!useClipboard) {
        if (copyToClipboard) {
            clipboard->setText(text);
        }
        SPDLOG_WARN("Direct text input is not available on Linux; "
                    "enable clipboard paste instead");
        return;
    }

#ifdef ZENNY_HAS_XTEST
    Display *display = XOpenDisplay(nullptr);
    if (!display) {
        if (copyToClipboard) {
            clipboard->setText(text);
        }
        SPDLOG_WARN("Cannot open the X11 display; text was copied to the "
                    "clipboard but could not be pasted");
        return;
    }

    QMimeData *originalData = nullptr;
    const bool shouldRestore = restoreClipboard && !copyToClipboard;
    if (shouldRestore) {
        const QMimeData *currentData = clipboard->mimeData();
        if (currentData) {
            originalData = new QMimeData();
            for (const QString &format : currentData->formats()) {
                originalData->setData(format, currentData->data(format));
            }
        }
    }

    clipboard->setText(text);
    QThread::msleep(20);

    const KeyCode control = XKeysymToKeycode(display, XK_Control_L);
    const KeyCode v = XKeysymToKeycode(display, XK_V);
    if (control == 0 || v == 0) {
        XCloseDisplay(display);
        if (copyToClipboard) {
            clipboard->setText(text);
        }
        delete originalData;
        SPDLOG_WARN("Could not resolve X11 Ctrl+V keycodes; text was copied "
                    "to the clipboard but could not be pasted");
        return;
    }

    XTestFakeKeyEvent(display, control, True, CurrentTime);
    XTestFakeKeyEvent(display, v, True, CurrentTime);
    XTestFakeKeyEvent(display, v, False, CurrentTime);
    XTestFakeKeyEvent(display, control, False, CurrentTime);
    XFlush(display);
    XCloseDisplay(display);

    if (shouldRestore && originalData) {
        QThread::msleep(50);
        clipboard->setMimeData(originalData);
    }
#else
    clipboard->setText(text);
    SPDLOG_WARN("XTest support is unavailable; text was copied to the "
                "clipboard but could not be pasted");
#endif
}

SysWindowInfo nativeWindowInfoAtCursor()
{
    return {};
}

} // namespace zenny
