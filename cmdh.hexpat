// blah

#pragma endian little

//import std.core;
//import std.io;
import std.mem;
//import std.string;
import type.base;
using Hex<T> = type::Hex<T>;

struct chunk {
    char CMDH_magic[4];
    u32 length;
    if (length != 0) {
        u8 data[length] [[sealed]];
    }
    u32 footer;
};

struct CMD {
    chunk CMDH_chunk;
    // stops at chunk with "CMDF" magic
    chunk chunk[while(std::mem::read_unsigned($, 4) != 0x46444D43)];
    chunk CMDF_chunk;
};

struct file_unk02 {
    u32 count;
    Hex<u32> ptr[count];
    CMD CMD[count];
};

file_unk02 file_unk02 @ 0x00;