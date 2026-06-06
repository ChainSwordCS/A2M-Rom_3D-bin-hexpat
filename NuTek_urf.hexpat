// .urf 

#pragma endian little

const char CONST_MAGIC_KTUN[4] = {'K','T','U','N'}; // NUTK ?
const char CONST_MAGIC_RFMN[4] = {'R','F','M','N'}; // NMFR ?
const char CONST_MAGIC_COLN[4] = {'C','O','L','N'}; // NLOC ?
const char CONST_MAGIC_TAFN[4] = {'T','A','F','N'}; // NFAT ?

struct RFMN_struct {
    u32 var1;
    u32 var2;
    u32 var3;
};

struct COLN_struct_B {
    char TAFN_magic[4];
    u32 var1;
    u32 var2;
    u32 var3;
};

struct COLN_struct_A {
    u32 var1;
    u32 ptr;
    COLN_struct_B @ ptr;
};

struct urf_file {
    char magic_KTUN[4];
    u32 unk1;
    u32 unk2;
    char magic_RFMN[4];
    u32 unk3;
    u32 RFMN_list_count;
    RFMN_struct RFMN_struct[RFMN_list_count];
    char magic_COLN[4];
    u32 COLN_list_count;
    COLN_struct_A COLN_struct_A[COLN_list_count];
};

urf_file urf_file @ 0x00;