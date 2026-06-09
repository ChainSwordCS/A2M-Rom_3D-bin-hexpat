// NuTek engine URFAT file (.urf)

#pragma endian little

const char CONST_MAGIC_NUTK[4] = {'K','T','U','N'}; // NUTK; URFAT file
const char CONST_MAGIC_NMFR[4] = {'R','F','M','N'}; // NMFR; Master FAT Record
const char CONST_MAGIC_NLOC[4] = {'C','O','L','N'}; // NLOC; Localisation Information
const char CONST_MAGIC_NFAT[4] = {'T','A','F','N'}; // NFAT; File Attribute Table
const char CONST_MAGIC_MD[2] = {'D','M'}; // MD; Metadata

struct NMFR_struct {
    u32 var1;
    u32 var2;
    u32 var3;
};

struct NLOC_struct_B {
    char NFAT_magic[4];
    u32 var1;
    u32 var2;
    u32 var3;
};

struct NLOC_struct_A {
    u32 var1;
    u32 ptr;
    NLOC_struct_B @ ptr;
};

struct urf_file {
    char magic_NUTK[4];
    u32 unk1;
    u32 unk2;
    char magic_NMFR[4];
    u32 unk3;
    u32 NMFR_list_count;
    NMFR_struct NMFR_struct[NMFR_list_count];
    char magic_NLOC[4];
    u32 NLOC_list_count;
    NLOC_struct_A NLOC_struct_A[NLOC_list_count];
};

urf_file urf_file @ 0x00;