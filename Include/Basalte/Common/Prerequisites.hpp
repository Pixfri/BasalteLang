// Copyright (C) 2024 Jean "Pixfri" Letessier 
// This file is part of the Basalte programming language.
// For conditions of distribution and use, see copyright notice in LICENSE

#pragma once

#ifndef BASALTE_COMMON_PREREQUISITES_HPP
#define BASALTE_COMMON_PREREQUISITES_HPP

#ifdef BASALTE_PLATFORM_WIN32
    #define BASALTE_EXPORT __declspec(dllexport)
    #define BASALTE_IMPORT __declspec(dllimport)
#else
    #define BASALTE_EXPORT __attribute__((visibility("default")))
    #define BASALTE_IMPORT __attribute__((visibility("default")))
#endif

#include <cstddef>
#include <cstdint>
#include <climits>

static_assert(CHAR_BIT == 8, "CHAR_BIT is expected to be 8");

static_assert(sizeof(int8_t)  == 1, "int8_t is not of the correct size" );
static_assert(sizeof(int16_t) == 2, "int16_t is not of the correct size");
static_assert(sizeof(int32_t) == 4, "int32_t is not of the correct size");
static_assert(sizeof(int64_t) == 8, "int64_t is not of the correct size");

static_assert(sizeof(uint8_t)  == 1, "uint8_t is not of the correct size" );
static_assert(sizeof(uint16_t) == 2, "uint16_t is not of the correct size");
static_assert(sizeof(uint32_t) == 4, "uint32_t is not of the correct size");
static_assert(sizeof(uint64_t) == 8, "uint64_t is not of the correct size");

namespace Basalte {
    using Int8 = int8_t;
	using UInt8 = uint8_t;

	using Int16 = int16_t;
	using UInt16 = uint16_t;

	using Int32 = int32_t;
	using UInt32 = uint32_t;

	using Int64 = int64_t;
	using UInt64 = uint64_t;

	using USize = size_t;

}

#endif // BASALTE_COMMON_PREREQUISITES_HPP
