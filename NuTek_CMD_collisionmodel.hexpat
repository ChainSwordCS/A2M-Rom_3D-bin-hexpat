// blah

#pragma endian little

//import std.core;
//import std.io;
import std.mem;
//import std.string;
import type.base;
using Hex<T> = type::Hex<T>;

struct chunk_generic {
    char magic[4];
    u32 length;
    if (length != 0) {
        u8 data[length] [[sealed]];
    }
    u32 footer;
};

u32 _g_remaining_len = 0;
struct CBOX_dat_36byte {
    u8 d[36];
    _g_remaining_len -= 36;
};
struct chunk_CBOX {
    char magic[4];
    u32 length;
    u32 offs = $;
    _g_remaining_len = length;
    CBOX_dat_36byte data[while(_g_remaining_len >= 36)];
    //if ($ < offs+length) {
    if (_g_remaining_len > 0) {
        //u8 data2[offs+length-$];
        u8 data2[_g_remaining_len];
        _g_remaining_len = 0;
    }
    u32 footer;
};

struct chunk {
    match(std::mem::read_unsigned($, 4)) {
    /* CMD header and footer */
    (0x48444F43): /* CMDH */ chunk_generic chunk;
    (0x46444D43): /* CMDF */ chunk_generic chunk;
    /* data */
    (0x43424F58): /* CBOX / XOBC */ chunk_CBOX chunk;
    (0x43434150): /* CCAP / PACC */ chunk_generic chunk;
    (0x434D4154): /* CMAT / TAMC */ chunk_generic chunk;
    (0x43514144): /* CQAD / DAQC */ chunk_generic chunk;
    (0x43535048): /* CSPH / HPSC */ chunk_generic chunk;
    (0x43535350): /* CSSP / PSSC */ chunk_generic chunk; // ?
    (0x43545249): /* CTRI / IRTC */ chunk_generic chunk;
    (0x56455253): /* VERS / SREV */ chunk_generic chunk;
    (_): chunk_generic chunk;
    }
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