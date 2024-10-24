set(qt_version 6.4.2)
string(REPLACE "." "" qt_version_dotless "${qt_version}")

if (WIN32)
  set(url_os "windows_x86")
  set(qt_package_arch_suffix "win64_msvc2019_64")
  set(qt_dir_prefix "${qt_version}/msvc2019_64")
  set(qt_package_suffix "-Windows-Windows_10_21H2-MSVC2019-Windows-Windows_10_21H2-X86_64")
elseif(APPLE)
  set(url_os "mac_x64")
  set(qt_package_arch_suffix "clang_64")
  set(qt_dir_prefix "${qt_version}/macos")
  set(qt_package_suffix "-MacOS-MacOS_12-Clang-MacOS-MacOS_12-X86_64-ARM64")
else()
  set(url_os "linux_x64")
  set(qt_package_arch_suffix "gcc_64")
  set(qt_dir_prefix "${qt_version}/gcc_64")
  set(qt_package_suffix "-Linux-RHEL_8_4-GCC-Linux-RHEL_8_4-X86_64")
endif()

set(qt_base_url "https://download.qt.io/online/qtsdkrepository/${url_os}/desktop/qt6_${qt_version_dotless}")
set(qt_examples_base_url "https://download.qt.io/online/qtsdkrepository/${url_os}/desktop/qt6_${qt_version_dotless}_src_doc_examples")

file(DOWNLOAD "${qt_base_url}/Updates.xml" ./Updates.xml SHOW_PROGRESS)
file(READ ./Updates.xml updates_xml)
string(REGEX MATCH "<Name>qt.qt6.*<Version>([0-9+-.]+)</Version>" updates_xml_output "${updates_xml}")
set(qt_package_version ${CMAKE_MATCH_1})

file(DOWNLOAD "${qt_examples_base_url}/Updates.xml" ./UpdatesExamples.xml SHOW_PROGRESS)
file(READ ./UpdatesExamples.xml updates_examples_xml)
string(REGEX MATCH "<Name>qt.qt6.*<Version>([0-9+-.]+)</Version>" updates_examples_xml_output "${updates_examples_xml}")
set(qt_examples_package_version ${CMAKE_MATCH_1})

set(download_dir qt6-download-${qt_package_version})

file(MAKE_DIRECTORY Qt)
file(MAKE_DIRECTORY ${download_dir})

file(RENAME ./Updates.xml ${download_dir}/Updates.xml)
file(RENAME ./UpdatesExamples.xml ${download_dir}/UpdatesExamples.xml)

function(downloadAndExtract url archive)
  message("Downloading ${url}")
  file(DOWNLOAD "${url}" ./${download_dir}/${archive} SHOW_PROGRESS)
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf ../${download_dir}/${archive} WORKING_DIRECTORY Qt)
endfunction()

foreach(package qtbase qtdeclarative qttools qtsvg qttranslations)
  downloadAndExtract(
    "${qt_base_url}/qt.qt6.${qt_version_dotless}.${qt_package_arch_suffix}/${qt_package_version}${package}${qt_package_suffix}.7z"
    ${package}.7z
  )
  downloadAndExtract(
    "${qt_examples_base_url}/qt.qt6.${qt_version_dotless}.examples/${qt_examples_package_version}${package}-examples-${qt_version}.7z"
    ${package}-examples.7z
  )

endforeach()

foreach(package qtimageformats qtserialport)
  downloadAndExtract(
    "${qt_base_url}/qt.qt6.${qt_version_dotless}.addons.${package}.${qt_package_arch_suffix}/${qt_package_version}${package}${qt_package_suffix}.7z"
    ${package}.7z
  )
  downloadAndExtract(
    "${qt_examples_base_url}/qt.qt6.${qt_version_dotless}.examples.${package}/${qt_examples_package_version}${package}-examples-${qt_version}.7z"
    ${package}-examples.7z
  )
endforeach()


foreach(package qtquicktimeline qtquick3d qt5compat qtshadertools)
  downloadAndExtract(
    "${qt_base_url}/qt.qt6.${qt_version_dotless}.${package}.${qt_package_arch_suffix}/${qt_package_version}${package}${qt_package_suffix}.7z"
    ${package}.7z
  )
endforeach()

# uic depends on libicu56.so
if (NOT WIN32 AND NOT APPLE)
  downloadAndExtract(
    "${qt_base_url}/qt.qt6.${qt_version_dotless}.${qt_package_arch_suffix}/${qt_package_version}icu-linux-Rhel7.2-x64.7z"
    icu.7z
  )
endif()

file(READ "Qt/${qt_dir_prefix}/mkspecs/qconfig.pri" qtconfig)
string(REPLACE "Enterprise" "OpenSource" qtconfig "${qtconfig}")
string(REPLACE "licheck.exe" "" qtconfig "${qtconfig}")
string(REPLACE "licheck64" "" qtconfig "${qtconfig}")
string(REPLACE "licheck_mac" "" qtconfig "${qtconfig}")
file(WRITE "Qt/${qt_dir_prefix}/mkspecs/qconfig.pri" "${qtconfig}")
