-- Copyright (C) 2024 Jean "Pixfri" Letessier 
-- This file is part of the Basalte programming language.
-- For conditions of distribution and use, see copyright notice in LICENSE

local modules = BasalteModules

local headerTemplate, inlineTemplate, sourceTemplate

task("create-class")

set_menu({
    usage = "xmake create-class [options] name",
    description = "Task to help class creation.",
    options = {
        {nil, "nocpp", "k", nil, "Set this to create a header-only class."},
        {nil, "name", "v", nil, "Class name" },
        {nil, "module", "v", nil, "Module to create the class into" }
    } 
})

on_run(function()
    import("core.base.option")

    local classPath = option.get("name")
    if not classPath then
        os.raise("Missing class name")
    end

    local moduleName = option.get("module")
    if not moduleName then
        os.raise("Missing module name")
    end

    local className = path.basename(classPath)

    local files = {
        { TargetPath = path.join("Include/Basalte", moduleName, classPath) .. ".hpp", Template = headerTemplate },
        { TargetPath = path.join("Include/Basalte", moduleName, classPath) .. ".inl", Template = inlineTemplate }
    }

    if not option.get("nocpp") then
        table.insert(files, { TargetPath = path.join("Source/Basalte", moduleName, classPath) .. ".cpp", Template = sourceTemplate })
    end

    local replacements = {
        CLASS_NAME = className,
        CLASS_PATH = classPath,
        COPYRIGHT = os.date("%Y") .. [[ Jean "Pixfri" Letessier ]],
        HEADER_GUARD = "BASALTE_" .. moduleName:upper() .. "_" .. classPath:gsub("[/\\]", "_"):upper() .. "_HPP",
        MODULE_NAME = moduleName
    }

    for _, file in pairs(files) do
        local content = file.Template:gsub("%%([%u_]+)%%", function (kw)
            local r = replacements[kw]
            if not r then
                os.raise("Missing replacement for " .. kw)
            end

            return r
        end)

        io.writefile(file.TargetPath, content)
    end
end)

headerTemplate = [[
// Copyright (C) %COPYRIGHT%
// This file is part of the Basalte programming language.
// For conditions of distribution and use, see copyright notice in LICENSE

#pragma once

#ifndef %HEADER_GUARD%
#define %HEADER_GUARD%

#include <Basalte/Common/Prerequisites.hpp>

namespace Basalte::%MODULE_NAME% {
    class %CLASS_NAME% {
    public:
        %CLASS_NAME%() = default;
        ~%CLASS_NAME%() = default;
        
        %CLASS_NAME%(const %CLASS_NAME%&) = delete;
        %CLASS_NAME%(%CLASS_NAME%&&) = delete;
        
        %CLASS_NAME%& operator=(const %CLASS_NAME%&) = delete;
        %CLASS_NAME%& operator=(%CLASS_NAME%&&) = delete;

    private:
    };
}

#include <Basalte/%MODULE_NAME%/%CLASS_PATH%.inl>

#endif // %HEADER_GUARD%
]]

inlineTemplate = [[
// Copyright (C) %COPYRIGHT%
// This file is part of the Basalte programming language.
// For conditions of distribution and use, see copyright notice in LICENSE

#pragma once

namespace Basalte::%MODULE_NAME% {
}
]]

sourceTemplate = [[
// Copyright (C) %COPYRIGHT%
// This file is part of the Basalte programming language.
// For conditions of distribution and use, see copyright notice in LICENSE

#include <Basalte/%MODULE_NAME%/%CLASS_PATH%.hpp>

namespace Basalte::%MODULE_NAME% {
}
]]