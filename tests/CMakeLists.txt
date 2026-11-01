find_package(Catch2 3 QUIET)

include(CTest)
include(Catch)

add_executable(ZennyTests
    audio_utils_test.cpp
    ${PROJECT_SOURCE_DIR}/src/audio_utils.cpp
)

target_link_libraries(ZennyTests
    PRIVATE
    Catch2::Catch2WithMain
    Qt6::Core
    Qt6::Multimedia
    spdlog::spdlog_header_only
)
target_compile_definitions(ZennyTests PRIVATE SPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_TRACE)
target_include_directories(ZennyTests PRIVATE
    ${PROJECT_SOURCE_DIR}/src
    ${PROJECT_SOURCE_DIR}/third_parties/KDToolBox
)

if(WIN32)
    add_custom_command(TARGET ZennyTests
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_RUNTIME_DLLS:ZennyTests>
        $<TARGET_FILE_DIR:ZennyTests>
        COMMAND_EXPAND_LISTS
    )
endif()

catch_discover_tests(ZennyTests)
