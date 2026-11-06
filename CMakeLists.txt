# WIN Infinite Desktop - infinite canvas for Windows 11
# SPDX-FileCopyrightText: 2026 WIN Infinite Desktop contributors
# SPDX-License-Identifier: GPL-3.0-or-later

cmake_minimum_required(VERSION 3.22)

project(win-infinite-desktop VERSION 0.3.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# The canvas logic (src/core) is shared with KDE Infinite Desktop and needs Qt Core.
# The Win32 layer (src/platform) and the diagnostic tool (tools/wid-probe) only need
# the Windows SDK, so they also build without Qt (e.g. a quick MinGW check on Linux).
option(WID_WITH_QT "Build the Qt based parts (canvas core and its unit tests)" ON)
option(WID_BUILD_PROBE "Build the diagnostic tool wid-probe (Windows only)" ON)
option(WID_BUILD_APPS "Build the notes app and the settings app (Qt Quick)" ON)
option(WID_ASAN "Build with AddressSanitizer (MSVC /fsanitize=address, development only)" OFF)

set(QT_MIN_VERSION "6.8.0" CACHE STRING "Oldest Qt version the project builds with")
add_compile_definitions(WID_VERSION_STRING=\"${PROJECT_VERSION}\")

if(MSVC)
    add_compile_options(/W4 /utf-8 /permissive- /Zc:__cplusplus)
    if(WID_ASAN)
        add_compile_options(/fsanitize=address /Zi)
        add_link_options(/INCREMENTAL:NO /DEBUG)
    endif()
else()
    add_compile_options(-Wall -Wextra)
endif()

if(WIN32)
    add_compile_definitions(UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0A00 NTDDI_VERSION=0x0A000010)
endif()

if(WID_WITH_QT)
    find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Core)
    add_compile_definitions(QT_NO_KEYWORDS QT_NO_CAST_FROM_ASCII QT_NO_URL_CAST_FROM_STRING)
    add_subdirectory(src/core)
    if(WID_BUILD_APPS)
        # Their platform-neutral parts also build on Linux, for the unit tests.
        add_subdirectory(src/shared)
        add_subdirectory(src/notes)
        add_subdirectory(src/settings)
    endif()
endif()

if(WIN32)
    add_subdirectory(src/platform)
    if(WID_BUILD_PROBE)
        add_subdirectory(tools/wid-probe)
    endif()
    add_subdirectory(tools/wid-testwindow)
    add_subdirectory(tools/wid-media)
    if(WID_WITH_QT)
        add_subdirectory(src/service)
        add_subdirectory(tools/wid-ctl)
    endif()
endif()

include(CTest)
if(BUILD_TESTING AND WID_WITH_QT)
    find_package(Qt6 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Test)
    add_subdirectory(tests)
endif()
