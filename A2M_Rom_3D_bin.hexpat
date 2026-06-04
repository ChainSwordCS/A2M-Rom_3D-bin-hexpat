// DJTS; Rom_3D.bin

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

struct unk_struct_1 {
    u32 var1; // pointer(????) to something idk
    //u32 var1 @ var1_ptr;
    u32 block_ptr;
    Type type;
    u32 delta_x2; // block_len_x2
    
    match (type) {
        (Type::LZ_MIDI): block_lz_midi block @ block_ptr;
        (_): u32 block_placeholder @ block_ptr;
    }
};

struct Rom_3D_bin {
    u32 count_1;
    unk_struct_1 mystruct[count_1];
};

Rom_3D_bin Rom_3D_bin @ 0x00;