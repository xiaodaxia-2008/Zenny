# Prebuilt ONNX Runtime for the PP-OCRv6 recognizer (no vcpkg, no sherpa
# coupling). Downloads the official release package from GitHub and exposes
# an imported target named `onnxruntime` (shared library + headers).

set(ZENNY_ONNXRUNTIME_VERSION "1.29.0")
set(ZENNY_ONNXRUNTIME_DIR
    "${CMAKE_CURRENT_SOURCE_DIR}/third_parties/onnxruntime")
set(ZENNY_ONNXRUNTIME_EXTRACT
    "${CMAKE_BINARY_DIR}/third_parties/onnxruntime")

if(WIN32)
    set(ZENNY_ONNXRUNTIME_PACKAGE_NAME
        "onnxruntime-win-x64-${ZENNY_ONNXRUNTIME_VERSION}")
    set(ZENNY_ONNXRUNTIME_ARCHIVE_EXT "zip")
elseif(APPLE)
    set(ZENNY_ONNXRUNTIME_PACKAGE_NAME
        "onnxruntime-osx-universal-${ZENNY_ONNXRUNTIME_VERSION}")
    set(ZENNY_ONNXRUNTIME_ARCHIVE_EXT "tgz")
else()
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(ZENNY_ONNXRUNTIME_ARCH "aarch64")
    else()
        set(ZENNY_ONNXRUNTIME_ARCH "x64")
    endif()
    set(ZENNY_ONNXRUNTIME_PACKAGE_NAME
        "onnxruntime-linux-${ZENNY_ONNXRUNTIME_ARCH}-${ZENNY_ONNXRUNTIME_VERSION}")
    set(ZENNY_ONNXRUNTIME_ARCHIVE_EXT "tgz")
endif()

set(ZENNY_ONNXRUNTIME_PACKAGE
    "${ZENNY_ONNXRUNTIME_DIR}/${ZENNY_ONNXRUNTIME_PACKAGE_NAME}.${ZENNY_ONNXRUNTIME_ARCHIVE_EXT}")
set(ZENNY_ONNXRUNTIME_ROOT
    "${ZENNY_ONNXRUNTIME_EXTRACT}/${ZENNY_ONNXRUNTIME_PACKAGE_NAME}")
set(ZENNY_ONNXRUNTIME_INCLUDE "${ZENNY_ONNXRUNTIME_ROOT}/include")

if(NOT EXISTS "${ZENNY_ONNXRUNTIME_PACKAGE}")
    file(MAKE_DIRECTORY "${ZENNY_ONNXRUNTIME_DIR}")
    set(ZENNY_ONNXRUNTIME_URL
        "https://github.com/microsoft/onnxruntime/releases/download/v${ZENNY_ONNXRUNTIME_VERSION}/${ZENNY_ONNXRUNTIME_PACKAGE_NAME}.${ZENNY_ONNXRUNTIME_ARCHIVE_EXT}")
    message(STATUS "Downloading ONNX Runtime ${ZENNY_ONNXRUNTIME_VERSION} from ${ZENNY_ONNXRUNTIME_URL}")
    file(DOWNLOAD "${ZENNY_ONNXRUNTIME_URL}" "${ZENNY_ONNXRUNTIME_PACKAGE}"
         SHOW_PROGRESS)
endif()

if(NOT EXISTS "${ZENNY_ONNXRUNTIME_ROOT}/include/onnxruntime_cxx_api.h")
    file(MAKE_DIRECTORY "${ZENNY_ONNXRUNTIME_EXTRACT}")
    file(ARCHIVE_EXTRACT INPUT "${ZENNY_ONNXRUNTIME_PACKAGE}"
         DESTINATION "${ZENNY_ONNXRUNTIME_EXTRACT}")
endif()

if(WIN32)
    set(ZENNY_ONNXRUNTIME_LIB
        "${ZENNY_ONNXRUNTIME_ROOT}/lib/onnxruntime.lib")
    set(ZENNY_ONNXRUNTIME_DLL
        "${ZENNY_ONNXRUNTIME_ROOT}/lib/onnxruntime.dll")
    # Some releases put the dll next to the providers dll — handle both.
    if(NOT EXISTS "${ZENNY_ONNXRUNTIME_DLL}"
       AND EXISTS "${ZENNY_ONNXRUNTIME_ROOT}/lib/onnxruntime_providers_shared.dll")
        set(ZENNY_ONNXRUNTIME_DLL
            "${ZENNY_ONNXRUNTIME_ROOT}/lib/onnxruntime_providers_shared.dll")
    endif()
    set(ZENNY_ONNXRUNTIME_PROVIDERS_SHARED_DLL
        "${ZENNY_ONNXRUNTIME_ROOT}/lib/onnxruntime_providers_shared.dll")
else()
    set(ZENNY_ONNXRUNTIME_LIB
        "${ZENNY_ONNXRUNTIME_ROOT}/lib/libonnxruntime.so")
endif()

if(NOT EXISTS "${ZENNY_ONNXRUNTIME_LIB}" OR
   (WIN32 AND NOT EXISTS "${ZENNY_ONNXRUNTIME_DLL}"))
    message(WARNING "ONNX Runtime prebuilt not found at ${ZENNY_ONNXRUNTIME_ROOT} — PP-OCRv6 ONNX test will be stub")
else()
    add_library(onnxruntime SHARED IMPORTED GLOBAL)
    if(WIN32)
        set_target_properties(onnxruntime PROPERTIES
            IMPORTED_LOCATION "${ZENNY_ONNXRUNTIME_DLL}"
            IMPORTED_IMPLIB "${ZENNY_ONNXRUNTIME_LIB}"
            INTERFACE_INCLUDE_DIRECTORIES "${ZENNY_ONNXRUNTIME_INCLUDE}"
        )
    else()
        set_target_properties(onnxruntime PROPERTIES
            IMPORTED_LOCATION "${ZENNY_ONNXRUNTIME_LIB}"
            INTERFACE_INCLUDE_DIRECTORIES "${ZENNY_ONNXRUNTIME_INCLUDE}"
        )
    endif()
    message(STATUS "ONNX Runtime ${ZENNY_ONNXRUNTIME_VERSION} ready: ${ZENNY_ONNXRUNTIME_ROOT}")
endif()
