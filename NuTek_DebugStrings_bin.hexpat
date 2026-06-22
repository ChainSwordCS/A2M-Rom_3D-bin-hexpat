// A2M NuTek engine (for Nintendo DS) . . .
// Drake & Josh: Talent Showdown - DebugStrings.bin file parser
// Copyright (c) 2026 ChainSwordCS
// open-source license: MIT

#pragma endian little

//import std.core;
//import std.io;
import std.mem;
//import std.string;
import type.base;
using Hex<T> = type::Hex<T>;

fn determine_str_len(u8 c) {
    u32 cursor_pos = $;
    u32 len = 1;
    while (true) {
        if (std::mem::eof()) {
            len = len - 1;
            break;
        } else if (std::mem::read_unsigned($,1) == c) {
            break;
        }
        $ = $ + 1;
        len = len + 1;
    }
    $ = cursor_pos;
    return len;
};

struct string_struct {
    if (!std::mem::eof()) {
        Hex<u32> hash_id;
        u16 str_len;
        char s[str_len]; //char s[determine_str_len('\n')];
    }
};

struct list_entry {
    u32 hash_id; // hash?
    Hex<u16> ptr; // u32?
    padding[2];
};

struct file {
    u32 placeholder;
    padding[4];
    padding[2];
    u16 count; // probably a u16, i imagine
    padding[2];
    list_entry list[count];
    string_struct strings[count];
};

file file @ 0x00;
//string_struct strings[99] @ 0x0326;