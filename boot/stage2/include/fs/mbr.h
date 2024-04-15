#ifndef __MBR_H__
#define __MBR_H__

#include <stdint.h>

typedef struct
{
    uint8_t boot_code[440];
    uint32_t signature;
    uint16_t reserved;
    MBR_Table partition_tables[4];
    uint16_t boot_signature;
} __attribute((packed)) MBR;

typedef struct
{
    uint8_t attributes;
    uint8_t chs_first[3];
    uint8_t type;
    uint8_t chs_last[3];
    uint16_t lba_start;
    uint16_t sectors_in_partition;
} __attribute((packed)) MBR_Table;

#endif // __MBR_H__