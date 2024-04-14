#ifndef __FAT_H__
#define __FAT_H__

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <devices/disk/disk.h>
#include <sys/memdefs.h>
#include <libc/stdio/printf.h>

typedef struct
{
    uint8_t jmp[3];
    uint8_t oem_identifier[8];
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t numbers_of_fats;
    uint16_t root_dir_entries;
    uint16_t total_sectors;
    uint8_t media_descriptor_type;
    uint16_t sectors_per_fat;
    uint16_t sectors_per_track;
    uint16_t number_of_heads;
    uint32_t number_of_hidden_sectors;
    uint32_t total_sectors_large;

    // Extended Boot Record
    uint8_t drive_number;
    uint8_t reserved;
    uint8_t signature;
    uint32_t volume_id;
    uint8_t volume_label[11];
    uint8_t system_id[8];
    uint8_t boot_code[448];
    uint16_t boot_signature;
} __attribute((packed)) FAT_BootRecord;

typedef struct
{
    char filename[8];
    uint8_t attributes;
    uint8_t reserved1;
    uint8_t creation_time_cs;
    uint16_t creation_time;
    uint16_t creation_date;
    uint16_t last_access_date;
    uint16_t high_cluster;
    uint16_t modification_time;
    uint16_t modification_date;
    uint16_t low_cluster;
    uint32_t file_size;
} __attribute((packed)) FAT_Entry;

bool init_fat(DISK *disk);

#endif // __FAT_H__