// DJTS; Rom_3D.bin

//import std.core;
import std.io; // not needed?
import std.mem;
import std.string;

#pragma endian little

enum Type : u32 {
    // TODO
    UNK_0       = 0x00000000,
    LZ_MIDI     = 0x00000006, // MIDI file with LZ compression applied
    UNK_4       = 0x00000004,
    UNK_515     = 0x00000203, // d.515
    UNK_1026    = 0x00000402, // d.1026
    UNK_50000305= 0x50000305,
};

// corresponding to TYPE::LZ_MIDI
struct block_lz_midi {
    u32 decompressed_length;
};

// one entry in the file table/list
struct file_table {
    u32 hash; // probably hash ?
    try {
        u32 block_ptr;
        Type type;
        match (type) {
            (Type::LZ_MIDI): block_lz_midi block @ block_ptr;
            (_): u32 block_placeholder @ block_ptr;
        }
    } catch {
        padding[4]; //u32 block_ptr_INVALID;
        Type type;
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
    identify_BMD0_files(file_table, file_count);
};

Rom_3D_bin Rom_3D_bin @ 0x00;

//u32 bookmark1 @ 0x1F9C4;