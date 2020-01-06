# SPDX-License-Identifier: Apache-2.0

if(NOT CONFIG_EXTERNAL_LIBC)
add_subdirectory(libc)
endif()
add_subdirectory(os)
