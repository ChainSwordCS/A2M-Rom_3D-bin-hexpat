// A2M NuTek engine (for Nintendo DS) - Rom_2D.bin parser
// Copyright (c) 2026 ChainSwordCS
// open-source license: MIT

// VERY unfinished

//import std.core;
import std.io; // not needed?
import std.mem;
import std.string;
import type.base;
using Hex<T> = type::Hex<T>;

#pragma endian little

enum Filetype : u8 {
    // TODO
    UNK         = 0x00,
};

struct file_unk {
    u32 magic;
    /* TODO */
};

// one entry in the file table/list
struct file_table_entry {
    Hex<u32> hash; // probably hash ?
    Hex<u32> ptr;
    if (ptr < std::mem::size()-1)
        u8 PLACEHOLDER_file_marker @ ptr;
    //FileAttributes attributes;
    u32 delta; // block_len_x2
};

u32 _i = 0; // global
/** not designed to be used by other code using this hexpat as a library, sorry. */
struct _file {
    // calculate file size intelligently
    u32 total_size = 0;
    if (_i < parent.file_count - 1) {
        total_size = parent.file_table[_i+1].ptr - parent.file_table[_i].ptr;
    } else {
        total_size = std::mem::size() - parent.file_table[_i].ptr;
    }
    
    // calculate size of metadata
    u32 metadata_size = total_size - (parent.file_table[_i].delta / 2);
    if (metadata_size < 0) { // bad data
        metadata_size = 0;
    }
    
    u32 start_pos = $;
    match (parent.file_table[_i].attributes.filetype) {
        //(Filetype::UNK_00): file_unk00 unk00;
        //(Filetype::BMD0): file_bmd0 bmd0;
        //(Filetype::UNK_02): file_unk02 unk02;
        //(Filetype::BCA0): file_bca0 bca0;
        //(Filetype::UNK_04): file_unk04 unk04;
        //(Filetype::SBNK): file_sbnk sbnk;
        //(Filetype::MIDI): file_midi midi;
        (_): u32 placeholder;
    }
    if ($ < start_pos+total_size) {
        padding[(start_pos+total_size)-$];
    } else if ($ > start_pos+total_size) {
        std::print("Warning: file of type "+std::string::to_string(parent.file_table[_i].attributes.filetype)
            +" at position "+std::string::to_string(start_pos)+" is too long. (Code logic bug?)");
        $ = start_pos+total_size;
    }
    
    
    _i = _i + 1;
};

struct Rom_2D_bin {
    u32 ptr1;
    u32 ptr2;
    u32 ptr3;
    u32 ptr4;
    u32 ptr5;
    u32 ptr6;
    u32 ptr7;
    u32 ptr8;
    u32 unk9;
    u32 ptr10;
    u32 ptr11;
    u32 ptr12;
    u32 ptr13;
    u32 ptr14;
    u32 ptr15;
    
    u32 data1 @ ptr1; // mid ptr table
    u32 data2 @ ptr2; // mid ptr table
    u32 data3 @ ptr3; // start of a ptr table
    u32 data4 @ ptr4; // start of a ptr table
    u32 data5 @ ptr5; // start of a ptr table?
    u32 data6 @ ptr6; // start of a ptr(?) table
    u32 data7 @ ptr7; // start of a ptr table
    u32 data8 @ ptr8; // start of a ptr table
    u32 data10 @ ptr10; // start of file 1?
    u32 data11 @ ptr11; // end? of file 1?
    u32 data12 @ ptr12; // start of a ptr table?
    u32 data13 @ ptr13;
    //u32 data14 @ ptr14;
    u32 data15 @ ptr15; // ?
    

    //u32 file_count;
    //file_table_entry file_table[file_count];
    /*
    if ($ < file_table[0].ptr) {
        padding[file_table[0].ptr - $];
    }
    _i = 0; // global
    // if ImHex is crashing, try commenting-out the line below
    _file files[file_count];
    */
};

Rom_2D_bin Rom_2D_bin @ 0x00;

u32 bookmark1 @ 0x001AE9F8;
u32 bookmark2 @ 0x001AED10;
u32 bookmark3 @ 0x001AF398;
u32 bookmark4 @ 0x001AF688;