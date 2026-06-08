// DJTS; Rom_3D.bin

//import std.core;
import std.io; // not needed?
import std.mem;
import std.string;

#pragma endian little

enum Filetype : u8 {
    // TODO
    UNK_00      = 0x00,
    BMD0        = 0x01, // BMD0 (NSBMD) file (with metadata?); LZ compression
    UNK_02      = 0x02,
    UNK_03      = 0x03,
    UNK_04      = 0x04,
    UNK_05      = 0x05,
    MIDI        = 0x06, // MIDI file; LZ compression
};

bitfield FileAttributes {
    Filetype filetype : 7;
    unk_flags_1 : 1;
    unk_flags_2 : 8;
    unk_flags_3 : 8;
    unk_flags_4 : 8;
};

// corresponding to Filetype::BMD0
struct file_bmd0 {
    // TODO
    u32 var1;
};

// corresponding to Filetype::MIDI
struct file_midi {
    // TODO
    u32 decompressed_length;
};

// one entry in the file table/list
struct file_table {
    u32 hash; // probably hash ?
    try {
        u32 ptr;
        FileAttributes attributes;
        match (attributes.filetype) {
            (Filetype::BMD0): file_bmd0 file_bmd0 @ ptr;
            (Filetype::MIDI): file_midi file_midi @ ptr;
            (_): u32 file_placeholder @ ptr;
        }
    } catch {
        padding[4]; //u32 block_ptr_INVALID;
        FileAttributes attributes;
    }
    u32 delta; // block_len_x2
};

/** for research and debugging.
 *  at the end of this function, the cursor returns to the position where it was.
 */
fn identify_BMD0_files(file_table file_table, u32 count) {
    u32 file_cursor_stored_position = $;
    for (u32 i = 0, i < count, i = i + 1) {
        try {
            u32 ptr = file_table[i].block_ptr;
            //$ = ptr;
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
                std::print("type="+std::string::to_string(u32(file_table[i].type)));
                std::print(std::mem::read_string(ptr,4));
            }
        } catch {
            continue;
        }
    }
    $ = file_cursor_stored_position;
    return;
};

struct Rom_3D_bin {
    u32 file_count;
    file_table file_table[file_count];
    //identify_BMD0_files(file_table, file_count);
};

Rom_3D_bin Rom_3D_bin @ 0x00;

//u32 bookmark1 @ 0x1F9C4;