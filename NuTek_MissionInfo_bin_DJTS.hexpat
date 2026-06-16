// A2M NuTek engine (for Nintendo DS) . . .
// Drake & Josh: Talent Showdown - MissionInfo.bin file parser
// Copyright (c) 2026 ChainSwordCS
// open-source license: MIT

//import std.core;
import std.io;
import std.mem;
//import std.string;
import type.base;
using Hex<T> = type::Hex<T>;

#pragma endian little

// (some variable names and types are taken from hints in leftover debug strings)
struct MissionDescriptor {
    u16 name_len;
    char Name[name_len];
    Hex<u16> var1; // maybe an offset of some kind?
    u16; // ?
    Hex<u16> var2; // maybe "resource_id" or something, or perhaps "LevelName" id?
    u16; // ?
    u8; // ?
};

// the layout is wrong, but i'm not sure exactly how.
// (variable names and types are taken from hints in leftover debug strings)
struct MissionData {
    Hex<u16> UID;
    Hex<u32> MMLSceneCRC;
    Hex<u32> FXSoundBankCRC;
    Hex<u32> SequenceCRC;
    Hex<u32> SequenceSoundBankCRC;
    Hex<u16> RelatedGuitarMission;
    s16 CollectibleThreshold;
    s16 CollectibleTriggerID;
    s16 AvatarAvailability;
    s16 StartingWaterAmmo;
    s16 StartingExtinguisherAmmo;
    s16 StartingPowderAmmo;
    s16 DefaultMagicGroup;
};

// the layout is wrong, but i'm not sure exactly how.
// (variable names and types are taken from hints in leftover debug strings)
struct GuitarData {
    Hex<u16> ID;
    Hex<u32> MML;
    Hex<u32> SequenceCRC;
    Hex<u32> SoundBankCRC;
    s16 OffsetMS;
    s16 Length; // (in seconds)
    s16 GuitarChannel;
    s16 NormalChannel;
    s16 HardChannel;
    s16 NormalTrack;
    s16 HardTrack;
    s16 RatingRequirements[10];
    Hex<u16> IntroID;
    Hex<u16> NextMissionID; // unclear
};

struct section_sub_list_data {
    u16 id; // MissionID ?
    u16 var2;
    if(std::mem::read_unsigned($, 2) < 24) {
        // normal string length; probably a MissionDescriptor (?)
        MissionDescriptor MissionDescriptor;
    } else {
        // then it's probably not a string (????)
        MissionData MissionData;
        //GuitarData GuitarData;
    }
};

struct section_sub_list {
    u32 id;
    Hex<u32> data_ptr;
    section_sub_list_data data @ data_ptr;
};

struct Section {
    section_sub_list list[parent.list_cnt];
};

struct section_list_entry {
    u32 id;
    Hex<u32> section_ptr;
    u32 list_cnt;
    Section section @ section_ptr;
};

struct MissionInfo_bin {
    u16 section_cnt;
    section_list_entry section_list[section_cnt];
};

MissionInfo_bin MissionInfo_bin @ 0x00;