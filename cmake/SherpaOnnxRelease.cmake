set(ZENNY_SHERPA_ONNX_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_parties/sherpa-onnx")

if(CMAKE_BUILD_TYPE MATCHES "Debug")
    set(ZENNY_SHERPA_ONNX_CONFIG "Debug")
else()
    set(ZENNY_SHERPA_ONNX_CONFIG "Release")
endif()

# Only the Windows package is split by build configuration; the Linux
# package is a single static archive set.
if(WIN32)
    set(ZENNY_SHERPA_ONNX_PACKAGE_NAME
        "sherpa-onnx-v1.13.3-win-x64-static-MD-${ZENNY_SHERPA_ONNX_CONFIG}-lib")
elseif(APPLE)
    set(ZENNY_SHERPA_ONNX_PACKAGE_NAME
        "sherpa-onnx-v1.13.3-osx-universal-static-lib")
else()
    set(ZENNY_SHERPA_ONNX_PACKAGE_NAME
        "sherpa-onnx-v1.13.3-linux-x64-static-lib")
endif()

set(ZENNY_SHERPA_ONNX_PACKAGE
    "${ZENNY_SHERPA_ONNX_DIR}/${ZENNY_SHERPA_ONNX_PACKAGE_NAME}.tar.bz2")
set(ZENNY_SHERPA_ONNX_EXTRACT_DIR
    "${CMAKE_BINARY_DIR}/third_parties/sherpa-onnx")
set(ZENNY_SHERPA_ONNX_ROOT
    "${ZENNY_SHERPA_ONNX_EXTRACT_DIR}/${ZENNY_SHERPA_ONNX_PACKAGE_NAME}")
set(ZENNY_SHERPA_ONNX_LIB_DIR
    "${ZENNY_SHERPA_ONNX_ROOT}/lib")
set(ZENNY_SHERPA_ONNX_INCLUDE_DIR
    "${ZENNY_SHERPA_ONNX_DIR}/include")

if(NOT EXISTS "${ZENNY_SHERPA_ONNX_PACKAGE}")
    set(ZENNY_SHERPA_ONNX_URL
        "https://github.com/k2-fsa/sherpa-onnx/releases/download/v1.13.3/${ZENNY_SHERPA_ONNX_PACKAGE_NAME}.tar.bz2")
    message(STATUS "Downloading sherpa-onnx from ${ZENNY_SHERPA_ONNX_URL}")
    file(DOWNLOAD "${ZENNY_SHERPA_ONNX_URL}"
         "${ZENNY_SHERPA_ONNX_PACKAGE}"
         SHOW_PROGRESS)
    message(STATUS "Downloaded to ${ZENNY_SHERPA_ONNX_PACKAGE}")
endif()

if(NOT EXISTS "${ZENNY_SHERPA_ONNX_ROOT}")
    message(STATUS "Extracting ${ZENNY_SHERPA_ONNX_PACKAGE}")
    file(MAKE_DIRECTORY "${ZENNY_SHERPA_ONNX_EXTRACT_DIR}")
    file(ARCHIVE_EXTRACT
        INPUT "${ZENNY_SHERPA_ONNX_PACKAGE}"
        DESTINATION "${ZENNY_SHERPA_ONNX_EXTRACT_DIR}"
    )
endif()

if(NOT EXISTS "${ZENNY_SHERPA_ONNX_INCLUDE_DIR}/sherpa-onnx/c-api/c-api.h")
    message(FATAL_ERROR "Missing sherpa-onnx C API header under ${ZENNY_SHERPA_ONNX_INCLUDE_DIR}")
endif()

if(WIN32)
    set(ZENNY_SHERPA_ONNX_LIB_SUFFIX ".lib")
else()
    set(ZENNY_SHERPA_ONNX_LIB_SUFFIX ".a")
endif()

if(WIN32)
    set(ZENNY_SHERPA_ONNX_LIB_PREFIX "")
else()
    set(ZENNY_SHERPA_ONNX_LIB_PREFIX "lib")
endif()

set(ZENNY_SHERPA_ONNX_LIBS
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}sherpa-onnx-c-api${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}sherpa-onnx-cxx-api${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}sherpa-onnx-core${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}sherpa-onnx-kaldifst-core${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}sherpa-onnx-fstfar${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}sherpa-onnx-fst${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}kaldi-decoder-core${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}kaldi-native-fbank-core${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}ssentencepiece_core${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}kissfft-float${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}onnxruntime${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}espeak-ng${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}piper_phonemize${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
    # libespeak-ng.a references ucd symbols, so libucd.a must come after it
    # for GNU ld's single-pass archive resolution.
    "${ZENNY_SHERPA_ONNX_LIB_DIR}/${ZENNY_SHERPA_ONNX_LIB_PREFIX}ucd${ZENNY_SHERPA_ONNX_LIB_SUFFIX}"
)

foreach(lib IN LISTS ZENNY_SHERPA_ONNX_LIBS)
    if(NOT EXISTS "${lib}")
        message(FATAL_ERROR "Missing sherpa-onnx library: ${lib}")
    endif()
endforeach()

if(WIN32)
    set(ZENNY_SHERPA_ONNX_SYSTEM_LIBS
        ws2_32
        bcrypt
        advapi32
        userenv
    )
else()
    find_package(Threads REQUIRED)
    set(ZENNY_SHERPA_ONNX_SYSTEM_LIBS
        Threads::Threads
        ${CMAKE_DL_LIBS}
        m
    )
endif()

add_library(sherpa-onnx-c-api INTERFACE IMPORTED GLOBAL)
target_include_directories(sherpa-onnx-c-api INTERFACE
    "${ZENNY_SHERPA_ONNX_INCLUDE_DIR}"
)
target_link_libraries(sherpa-onnx-c-api INTERFACE
    ${ZENNY_SHERPA_ONNX_LIBS}
    ${ZENNY_SHERPA_ONNX_SYSTEM_LIBS}
)
