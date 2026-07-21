// A2M NuTek engine (for Nintendo DS) - Rom_3D.bin parser
// Copyright (c) 2026 ChainSwordCS
// open-source license: MIT

//import std.core;
import std.io; // not needed?
import std.mem;
import std.string;
import type.base;
using Hex<T> = type::Hex<T>;

#pragma endian little

enum Filetype : u8 {
    // TODO
    UNK_00      = 0x00,
    BMD0        = 0x01, // BMD0 (NSBMD) file; LZ compression
    UNK_02      = 0x02,
    BCA0        = 0x03, // BCA (Nitro joint animation) file (?)
    UNK_04      = 0x04,
    SNDARC      = 0x05, // sound file container (.bin/.bin.lz) - contains SBNK file and SWAR file
    MIDI        = 0x06, // MIDI file; LZ compression
};

bitfield FileAttributes {
    Filetype filetype : 7;
    unk_flags_1 : 1;
    unk_flags_2 : 8;
    unk_flags_3 : 8;
    unk_flags_4 : 8;
};



/** corresponding to Filetype::UNK_00
 *  
 *  if using this, defining (u32) parent.metadata_size is recommended but not required.
 */
struct file_unk00 {
    // not known to have any leading metadata, IIRC.
    try {
        if (parent.metadata_size > 0) {
            u8 leading_metadata_section[parent.metadata_size] [[sealed]];
            //$ = $ - parent.metadata_size;
        }
    } catch {}
    u32 magic; // 01 01 01 01
    /* TODO */
};



/** substruct of struct file_bmd0
 */
struct file_bmd0_leading_metadata {
    // metadata
    u32 metadata_model_count;
    Hex<u32> metadata_model_hashes[metadata_model_count];
    u8 metadata_model_hash_order[metadata_model_count];
    // pad to 32-bit alignment
    if ($ % 4 != 0)
        padding[4 - ($ % 4)];
};
/** corresponding to Filetype::BMD0
 *  
 *  if using this, defining (u32) parent.metadata_size is recommended but not required.
 */
struct file_bmd0 {
    try {
        if (parent.metadata_size > 0) {
            u8 leading_metadata_section[parent.metadata_size] [[sealed]];
            $ = $ - parent.metadata_size;
        }
    } catch {}
    file_bmd0_leading_metadata leading_metadata;
    
    u32 leading_metadata_LZ_decompressed_length;
    // the remainder is an LZ compressed archive.
    // we're not gonna bother decompressing that here...
    u8 LZ_header[4];
    padding[1];
    char magic[4];
    // etc.
};



/** substruct of struct file_unk02
 */
struct file_unk02_leading_metadata {
    u32 metadata_hash_count;
    Hex<u32> metadata_hashes[metadata_hash_count];
    u8 metadata_hash_order[metadata_hash_count];
    // pad to 32-bit alignment
    if ($ % 4 != 0)
        padding[4 - ($ % 4)];
};
/** corresponding to Filetype::UNK_02
 *  
 *  if using this, defining (u32) parent.metadata_size is recommended but not required.
 */
struct file_unk02 {
    try {
        if (parent.metadata_size > 0) {
            u8 leading_metadata_section[parent.metadata_size] [[sealed]];
            $ = $ - parent.metadata_size;
        }
    } catch {}
    file_unk02_leading_metadata leading_metadata;
    
    u32 leading_metadata_LZ_decompressed_length;
    // the remainder appears to be an LZ compressed archive.
    // we're not gonna bother decompressing that here...
    u8 LZ_header[4];
    // etc.
};



/** substruct of struct file_bca0
 */
struct file_bca0_leading_metadata {
    u32 metadata_hash_count;
    Hex<u32> metadata_hashes[metadata_hash_count];
    u8 metadata_hash_order[metadata_hash_count];
    // pad to 32-bit alignment
    if ($ % 4 != 0)
        padding[4 - ($ % 4)];
};
/** corresponding to Filetype::BCA0
 *  
 *  if using this, defining (u32) parent.metadata_size is recommended but not required.
 */
struct file_bca0 {
    try {
        if (parent.metadata_size > 0) {
            u8 leading_metadata_section[parent.metadata_size] [[sealed]];
            $ = $ - parent.metadata_size;
        }
    } catch {}
    file_bca0_leading_metadata leading_metadata;
    
    /* TODO */
};



/** substruct of struct file_unk04
 */
struct unk04_entry {
    u32 type;
    u32 refA;
    u32 refB;
    u32 aux;
};
/** substruct of struct file_unk04
 */
struct unk04_record {
    u32 key;
    u32 entry_cnt;
    u32 var3[entry_cnt];
    unk04_entry entry[entry_cnt];
};
/** corresponding to Filetype::UNK_04
 *  
 *  if using this, defining (u32) parent.metadata_size is recommended but not required.
 */
struct file_unk04 {
    try {
        if (parent.metadata_size > 0) {
            u8 leading_metadata_section[parent.metadata_size] [[sealed]];
            //$ = $ - parent.metadata_size;
        }
    } catch {}
    
    u32 base_offset = $;
    u32 n;
    //unk04_struct1 struct1[n];
    u32 offsets[n];
    unk04_record records[n];
};



/** substruct of struct file_sbnkswar
 */
struct file_sbnkswar_leading_metadata {
    u32 offs = $;
    u32 count;
    u32 unk_list_1[count]; // hash list, maybe?
    u64 unk_list_2[count];
    
    // pad to nearest 32-byte boundary
    if($ % 32 > 0) {
        padding[32 - ($ % 32)];
    }
};
/** corresponding to Filetype::SNDARC
 *  
 *  if using this, defining (u32) parent.metadata_size is recommended but not required.
 */
struct file_sbnkswar {
    u32 offs = $;
    try {
        if (parent.metadata_size > 0) {
            u8 leading_metadata_section[parent.metadata_size] [[sealed]];
            $ = $ - parent.metadata_size;
        }
    } catch {}
    file_sbnkswar_leading_metadata leading_metadata;
    
    /*  code infrastructure thing;
        this is for the "smart" detection of whether the file is lz compressed,
        as i want to not require the parent struct to define metadata_size...
        like, i want these filetype structs to work fine without that,
        (or at least not raise an exception...)
        partly cuz there's no need for it to be a hard requirement anyway.
     */
    bool is_parent_metadata_size_defined = true;
    u32 metadata_size = 0;
    try {
        metadata_size = parent.metadata_size;
        is_parent_metadata_size_defined = true;
    } catch {
        is_parent_metadata_size_defined = false;
    }
    if (is_parent_metadata_size_defined) {
        if ($ == offs+metadata_size-4) {
            // probably lz compressed, seems like?
            // i'm not implementing an lz decompression routine in ImHex are you crazy
            u32 leading_metadata_LZ_decompressed_length;
            u8 LZ_header[4];
        } else {
            u32 offs2 = $;
            u32 sound_file_count;
            Hex<u32> sound_file_ptrs[sound_file_count];
            if (sound_file_count >= 1)
                u32 sound_file_placeholder_0 @ (offs2 + sound_file_ptrs[0]);
            if (sound_file_count >= 2)
                u32 sound_file_placeholder_1 @ (offs2 + sound_file_ptrs[1]);
        }
    } else {
        u32 placeholder;
    }
};



/** corresponding to Filetype::MIDI
 *  
 *  if using this, defining (u32) parent.metadata_size is recommended but not required.
 */
struct file_midi {
    try {
        if (parent.metadata_size > 0) {
            u8 leading_metadata_section[parent.metadata_size] [[sealed]];
            $ = $ - parent.metadata_size;
        }
    } catch {}
    
    u32 leading_metadata_LZ_decompressed_length;
    // the remainder is an LZ compressed archive.
    // we're not gonna bother decompressing that here...
    u8 LZ_header[4];
    padding[1];
    char magic[4];
    // etc.
};



// one entry in the file table/list
struct file_table_entry {
    Hex<u32> hash; // probably hash ?
    Hex<u32> ptr;
    if (ptr < std::mem::size()-1)
        u8 PLACEHOLDER_file_marker @ ptr;
    FileAttributes attributes;
    u32 delta; // block_len_x2
};



/** globals are necessary for the way we're doing this here.
 *  (sorry for bad code.)
 *  
 *  there are less roundabout ways to do this, but i don't want the file
 *  stuck in the file_table_entry struct, defined at a distant offset
 *  from the main data in said struct. because in that case, if you click
 *  on the bytes in the Hex Editor view, it won't highlight the whole
 *  file_table_entry struct in the Pattern Data view, which sucks.
 */
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
        (Filetype::UNK_00): file_unk00 unk00;
        (Filetype::BMD0): file_bmd0 bmd0;
        (Filetype::UNK_02): file_unk02 unk02;
        (Filetype::BCA0): file_bca0 bca0;
        (Filetype::UNK_04): file_unk04 unk04;
        (Filetype::SNDARC): file_sbnkswar sbnkswar;
        (Filetype::MIDI): file_midi midi;
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

/** for research and debugging.
 */
fn identify_BMD0_files(file_table_entry file_table, u32 count) {
    for (u32 i = 0, i < count, i = i + 1) {
        try {
            u32 ptr = file_table[i].ptr;
            u32 entries = std::mem::read_unsigned(ptr, 4);
            ptr = ptr + (entries * 4) + entries + 4;
            
            // pad to 4-byte alignment
            for (u32 z = 0, z < 4, z = z + 1) {
                if (std::mem::read_unsigned(ptr, 1) == 0x00) {
                    ptr = ptr + 1;
                }
            }
            ptr = ptr + 4; // u32 decompressed_length;
            ptr = ptr + 5; // LZ header
            if (std::string::contains(std::mem::read_string(ptr,4), "BMD0")) {
                std::print("file="+std::string::to_string(i));
                //std::print("type="+std::format("%X8", u32(file_table[i].type)));
                std::print("type="+std::string::to_string(u32(file_table[i].attributes)));
                std::print(std::mem::read_string(ptr,4));
            }
        } catch {
            continue;
        }
    }
    return;
};

struct Rom_3D_bin {
    u32 file_count;
    file_table_entry file_table[file_count];
    
    if ($ < file_table[0].ptr) {
        padding[file_table[0].ptr - $];
    }
    _i = 0; // global
    /* if ImHex is crashing, try commenting-out the line below */
    _file files[file_count];
    
    //identify_BMD0_files(file_table, file_count);
};

Rom_3D_bin Rom_3D_bin @ 0x00;

//u32 bookmark1 @ 0x1F9C4;