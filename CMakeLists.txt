cmake_minimum_required(VERSION 3.21)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

project(Zenny VERSION 0.15.0 DESCRIPTION "Voice input method")

find_package(Qt6 CONFIG REQUIRED COMPONENTS Widgets Core Gui Multimedia Network Svg Sql WebSockets LinguistTools)
find_package(LibArchive REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
# Clipper2 is only needed by the PP-OCRv6 polygon post-processing path,
# which is enabled when both onnxruntime and OpenCV are available.
find_package(Clipper2 CONFIG QUIET)

if(WIN32)
    include(cmake/OnnxRuntimeRelease.cmake OPTIONAL)
    include(cmake/OpenCvRelease.cmake OPTIONAL)
else()
    find_package(onnxruntime CONFIG QUIET)
    if(NOT TARGET onnxruntime
       AND NOT TARGET onnxruntime::onnxruntime
       AND NOT TARGET ONNXRuntime::onnxruntime)
        include(cmake/OnnxRuntimeRelease.cmake OPTIONAL)
    endif()
    find_package(OpenCV QUIET COMPONENTS core imgproc)
endif()

# Normalize package-specific dependency names for the cross-platform provider.
set(ZENNY_PPOCRV6_ORT_TARGET "")
if(TARGET onnxruntime)
    set(ZENNY_PPOCRV6_ORT_TARGET onnxruntime)
elseif(TARGET onnxruntime::onnxruntime)
    set(ZENNY_PPOCRV6_ORT_TARGET onnxruntime::onnxruntime)
elseif(TARGET ONNXRuntime::onnxruntime)
    set(ZENNY_PPOCRV6_ORT_TARGET ONNXRuntime::onnxruntime)
elseif(onnxruntime_FOUND AND onnxruntime_LIBRARIES)
    add_library(zenny_onnxruntime INTERFACE)
    if(onnxruntime_INCLUDE_DIRS)
        target_include_directories(zenny_onnxruntime INTERFACE
            ${onnxruntime_INCLUDE_DIRS})
    endif()
    target_link_libraries(zenny_onnxruntime INTERFACE
        ${onnxruntime_LIBRARIES})
    set(ZENNY_PPOCRV6_ORT_TARGET zenny_onnxruntime)
endif()

if(NOT ZENNY_PPOCRV6_OPENCV_TARGETS)
    if(ZENNY_OPENCV_FOUND)
        set(ZENNY_PPOCRV6_OPENCV_TARGETS zenny_opencv_world)
    elseif(TARGET OpenCV::opencv_core AND TARGET OpenCV::opencv_imgproc)
        set(ZENNY_PPOCRV6_OPENCV_TARGETS
            OpenCV::opencv_core OpenCV::opencv_imgproc)
    elseif(TARGET opencv_core AND TARGET opencv_imgproc)
        set(ZENNY_PPOCRV6_OPENCV_TARGETS opencv_core opencv_imgproc)
    elseif(OpenCV_FOUND AND OpenCV_LIBS)
        add_library(zenny_opencv INTERFACE)
        if(OpenCV_INCLUDE_DIRS)
            target_include_directories(zenny_opencv INTERFACE
                ${OpenCV_INCLUDE_DIRS})
        endif()
        target_link_libraries(zenny_opencv INTERFACE ${OpenCV_LIBS})
        set(ZENNY_PPOCRV6_OPENCV_TARGETS zenny_opencv)
    endif()
endif()

include(FetchContent)
FetchContent_Declare(QHotkey
    URL https://github.com/Skycoder42/QHotkey/archive/refs/tags/1.5.0.zip
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
set(QT_DEFAULT_MAJOR_VERSION 6 CACHE STRING "Qt version to use (6)" FORCE)
set(QHOTKEY_INSTALL OFF CACHE BOOL "Disable install" FORCE)
set(QHOTKEY_EXAMPLES OFF CACHE BOOL "Disable examples" FORCE)
FetchContent_MakeAvailable(QHotkey)

FetchContent_Declare(QCoro
    GIT_REPOSITORY https://github.com/qcoro/qcoro.git
    GIT_TAG v0.12.0
)
set(QCORO_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(QCORO_BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(QCORO_WITH_QTDBUS OFF CACHE BOOL "" FORCE)
set(QCORO_WITH_QTWEBSOCKETS OFF CACHE BOOL "" FORCE)
set(QCORO_WITH_QTNETWORK ON CACHE BOOL "" FORCE)
set(QCORO_WITH_QTQUICK OFF CACHE BOOL "" FORCE)
set(QCORO_WITH_QTQML OFF CACHE BOOL "" FORCE)
set(QCORO_WITH_QML OFF CACHE BOOL "" FORCE)
set(QCORO_WITH_QTTEST OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(QCoro)

# Clipper2 is required by PP-OCRv6 polygon post-processing. Prefer a system
# package (vcpkg on Windows); otherwise fetch the upstream sources.
if(ZENNY_PPOCRV6_ORT_TARGET AND ZENNY_PPOCRV6_OPENCV_TARGETS
   AND NOT TARGET Clipper2::Clipper2)
    FetchContent_Declare(Clipper2
        URL https://codeload.github.com/AngusJohnson/Clipper2/zip/refs/tags/Clipper2_1.5.4
        SOURCE_SUBDIR CPP
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    )
    set(CLIPPER2_TESTS OFF CACHE BOOL "" FORCE)
    set(CLIPPER2_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(CLIPPER2_UTILS OFF CACHE BOOL "" FORCE)
    set(CLIPPER2_USINGZ OFF CACHE STRING "" FORCE)
    FetchContent_MakeAvailable(Clipper2)
    if(TARGET Clipper2 AND NOT TARGET Clipper2::Clipper2)
        add_library(Clipper2::Clipper2 ALIAS Clipper2)
    endif()
endif()

include(cmake/QtDeploy.cmake)
include(cmake/SherpaOnnxRelease.cmake)
include(cmake/GitInfo.cmake)
include(cmake/ModelDownload.cmake)

if(MSVC)
    add_compile_options(/utf-8)
endif()

add_subdirectory(src)
add_subdirectory(tests)
add_subdirectory(examples)

include(InstallRequiredSystemLibraries)

set(CPACK_GENERATOR "NSIS")
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VENDOR "Zenny")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_STRIP_FILES TRUE)

set(CPACK_NSIS_LANGUAGE "SimpChinese")
set(CPACK_NSIS_DISPLAY_NAME "Zenny")
set(CPACK_NSIS_PACKAGE_NAME "Zenny")
set(CPACK_NSIS_CONTACT "support@zenny.local")
set(CPACK_NSIS_MODIFY_PATH ON)

set(CPACK_NSIS_MENU_LINKS
    "bin/Zenny.exe" "Zenny"
)

set(CPACK_NSIS_CREATE_ICONS_EXTRA
    "CreateShortCut '$DESKTOP\\\\Zenny.lnk' '$INSTDIR\\\\bin\\\\Zenny.exe'"
)
set(CPACK_NSIS_DELETE_ICONS_EXTRA
    "Delete '$DESKTOP\\\\Zenny.lnk'"
)

set(CPACK_COMPONENTS_ALL Runtime)
include(CPack)
