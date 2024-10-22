set_xmakever("2.8.3")

set_project("BasalteLang")
set_license("Apache-2.0")

includes("xmake/**.lua")

-- Don't link system-installed libraries in CI
if os.getenv("CI") then
  add_requireconfs("*", {system = false})
end

-- Global configuration
add_rules("mode.debug", "mode.release")
add_rules("plugin.vsxmake.autoupdate")

set_allowedplats("windows", "linux", "macosx")
set_allowedmodes("debug", "release")

set_encodings("utf-8")
set_exceptions("cxx")
set_languages("clatest")
set_rundir("./bin/$(plat)_$(arch)_$(mode)")
set_targetdir("./bin/$(plat)_$(arch)_$(mode)")
set_warnings("allextra")

add_includedirs("Include")

if is_mode("debug") then
  add_defines("FL_DEBUG")
else
  set_symbols("debug", "hidden")
end

add_cxflags("-Wno-missing-field-initializers -Werror=vla", {tools = {"clang", "gcc"}})

option("override_runtime", {description = "Override VS runtime to MD in release and MDd in debug.", default = true})

if is_plat("windows") then
  if has_config("override_runtime") then
    set_runtimes(is_mode("debug") and "MDd" or "MD")
  end
end

-- Platform detection
if is_plat("windows") then 
  add_defines("BASALTE_PLATFORM_WINDOWS")
elseif is_plat("linux") then
  add_defines("BASALTE_PLATFORM_LINUX")
elseif is_plat("macosx") then
  add_defines("BASALTE_PLATFORM_MACOS")
end

target("BasalteCommon")
  set_kind("shared")

  for _, ext in ipairs({".h", ".hpp", ".inl"}) do
    add_headerfiles("Include/(BasalteCommon/**" .. ext .. ")")
    add_headerfiles("Source/(BasalteCommon/**" .. ext .. ")", {install = false})
  end

  add_files("Source/BasalteCommon/**.cpp")

  add_defines("BASALTE_COMMON_BUILD")

  add_rpathdirs("$ORIGIN")

target("BasalteCompiler")
  set_kind("binary")

  for _, ext in ipairs({".h", ".hpp", ".inl"}) do
    add_headerfiles("Include/(BasalteCompiler/**" .. ext .. ")")
    add_headerfiles("Source/(BasalteCompiler/**" .. ext .. ")", {install = false})
  end

  add_files("Source/BasalteCompiler/**.cpp")

  add_rpathdirs("$ORIGIN")