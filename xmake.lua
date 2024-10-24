-- Copyright (C) 2024 Jean "Pixfri" Letessier 
-- This file is part of the Basalte programming language.
-- For conditions of distribution and use, see copyright notice in LICENSE

------------------------- Modules -------------------------
local modules = {
  Common = {
    Custom = function()
      add_defines("BASALTE_COMMON_BUILD")
    end,
    Kind = "shared"
  },
  Compiler = {
    Kind = "binary",
    Deps = "BasalteCommon"
  }
}

BasalteModules = modules

set_xmakever("2.8.3")

set_project("BasalteLang")
set_license("Apache-2.0")

includes("xmake/**.lua")

-- Don't link system-installed libraries in CI
if os.getenv("CI") then
  add_requireconfs("*", {system = false})
end

-- Global configuration
add_rules("mode.coverage", "mode.debug", "mode.releasedbg", "mode.release")
add_rules("plugin.vsxmake.autoupdate")
add_rules("natvis")

set_allowedplats("windows", "mingw", "linux", "macosx")
set_allowedmodes("coverage", "debug", "releasedbg", "release")

set_encodings("utf-8")
set_exceptions("cxx")
set_languages("clatest", "cxx20")
set_rundir("./bin/$(plat)_$(arch)_$(mode)")
set_targetdir("./bin/$(plat)_$(arch)_$(mode)")
set_warnings("allextra")

add_includedirs("Include")

if is_mode("debug") then
  add_rules("debug.suffix")
  add_defines("FL_DEBUG")
elseif is_mode("coverage") then
  if not is_plat("windows") then
    add_links("gcov")
  end
elseif is_mode("releasedbg", "release") then
  set_fpmodels("fast")
end

if not is_mode("release") then
  set_symbols("debug", "hidden")
end

add_cxflags("-Wno-missing-field-initializers -Werror=vla", {tools = {"clang", "gcc"}})

option("override_runtime", {description = "Override VS runtime to MD in release and MDd in debug.", default = true})

if is_plat("windows") then
	if has_config("override_runtime") then
		set_runtimes(is_mode("debug") and "MDd" or "MD")
	end
elseif is_plat("mingw") then
	-- Use some optimizations even in debug for MinGW to reduce object size
	if is_mode("debug") then
		add_cxflags("-Og")
	end
	add_cxflags("-Wa,-mbig-obj")
end

-- Sanitizers
local sanitizers = {
	asan = "address",
	lsan = "leak",
	tsan = "thread",
}

for opt, policy in table.orderpairs(sanitizers) do
	option(opt, { description = "Enable " .. opt, default = false })

	if has_config(opt) then
		add_defines("BASALTE_WITH_" .. opt:upper())
		set_policy("build.sanitizer." .. policy, true)
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

------------------------- Modules -------------------------

function ModuleTargetConfig(name, module)
  add_defines("FL_" .. name:upper() .. "_BUILD")
  if is_mode("debug") then
    add_defines("FL_" .. name:upper() .. "_DEBUG")
  end

  -- Add header and source files
  for _, ext in ipairs({".h", ".hpp", ".inl"}) do 
    add_headerfiles("Include/(Basalte/" .. name .. "/**" .. ext .. ")")
    add_headerfiles("Include/Basalte/" .. name .. "/**" .. ext, {install = false})
  end

  -- Add extra files
	for _, ext in ipairs({".natvis"}) do
		add_extrafiles("include/Basalte/" .. name .. "/**" .. ext)
		add_extrafiles("src/Basalte/" .. name .. "/**" .. ext)
	end

  add_files("Source/Basalte/" .. name .. "/**.cpp")

  -- Remove platform-specific files
	if not is_plat("windows", "mingw") then
		remove_headerfiles("src/Basalte/" .. name .. "/Win32/**")
		remove_files("src/Basalte/" .. name .. "/Win32/**")
	end

	if not is_plat("linux") then
		remove_headerfiles("src/Basalte/" .. name .. "/Linux/**")
		remove_files("src/Basalte/" .. name .. "/Linux/**")
	end

	if not is_plat("macosx") then
		remove_headerfiles("src/Basalte/" .. name .. "/Darwin/**")
		remove_files("src/Basalte/" .. name .. "/Darwin/**")
	end

	if not is_plat("linux", "macosx") then
		remove_headerfiles("src/Basalte/" .. name .. "/Posix/**")
		remove_files("src/Basalte/" .. name .. "/Posix/**")
	end

  if module.Deps then
    add_deps(table.unpack(module.Deps))
  end

  if module.Packages then
    add_packages(table.unpack(module.Packages))
  end

  if module.PublicPackages then
    for _, pkg in ipairs(module.PublicPackages) do 
      add_packages(pkg, {public = true})
    end
  end

  if module.Custom then
    module.Custom()
  end
end

for name, module in pairs(modules) do 
  target("Basalte" .. name, function()
    set_group("Modules")
    
    set_kind(module.Kind and module.Kind or "binary")
    
    add_defines("BASALTE_BUILD")
    add_includedirs("Source")
    add_rpathdirs("$ORIGIN")
    
    ModuleTargetConfig(name, module)
    
  end)
end