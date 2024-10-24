// Copyright (C) 2024 Jean "Pixfri" Letessier 
// This file is part of the Basalte programming language.
// For conditions of distribution and use, see copyright notice in LICENSE

// Not necessary yet, will probably required in the future when we add .cpp files.

#pragma once

#ifndef BASALTE_COMMON_EXPORT_HPP
#define BASALTE_COMMON_EXPORT_HPP

#include <Basalte/Common/Prerequisites.hpp>

#ifdef BASALTE_COMMON_BUILD
    #define BASALTE_COMMON_API BASALTE_EXPORT
#else
    #define BASALTE_COMMON_API BASALTE_IMPORT
#endif

#endif // BASALTE_COMMON_EXPORT_HPP
