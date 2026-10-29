#pragma once

#include "qt_fmt.h"

#include <spdlog/spdlog.h>

// Fall back to the default logger while the status-bar logger has not been
// installed yet (e.g. messages emitted during MainWindow construction).
#define ZENNY_STATUSBAR_LOGGER()                                               \
    (spdlog::get("statusbar") ? spdlog::get("statusbar")                       \
                              : spdlog::default_logger())

#define STATUSBAR_TRACE(...)                                                   \
    SPDLOG_LOGGER_CALL(ZENNY_STATUSBAR_LOGGER(), spdlog::level::trace,         \
                       __VA_ARGS__)
#define STATUSBAR_DEBUG(...)                                                   \
    SPDLOG_LOGGER_CALL(ZENNY_STATUSBAR_LOGGER(), spdlog::level::debug,         \
                       __VA_ARGS__)
#define STATUSBAR_INFO(...)                                                    \
    SPDLOG_LOGGER_CALL(ZENNY_STATUSBAR_LOGGER(), spdlog::level::info,          \
                       __VA_ARGS__)
#define STATUSBAR_WARN(...)                                                    \
    SPDLOG_LOGGER_CALL(ZENNY_STATUSBAR_LOGGER(), spdlog::level::warn,          \
                       __VA_ARGS__)
#define STATUSBAR_ERROR(...)                                                   \
    SPDLOG_LOGGER_CALL(ZENNY_STATUSBAR_LOGGER(), spdlog::level::err,           \
                       __VA_ARGS__)
#define STATUSBAR_CRITICAL(...)                                                \
    SPDLOG_LOGGER_CALL(ZENNY_STATUSBAR_LOGGER(), spdlog::level::critical,      \
                       __VA_ARGS__)

class QPlainTextEdit;
class QStatusBar;

namespace zenny
{

void installStatusBarLogger(QStatusBar *statusBar);

void initLogger();

void installLogPanelSink(QPlainTextEdit *textEdit);

} // namespace zenny
