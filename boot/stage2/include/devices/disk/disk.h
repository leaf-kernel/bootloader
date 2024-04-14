#ifndef __DISK_H__
#define __DISK_H__

#include <stdint.h>
#include <stdbool.h>

typedef struct
{
    uint8_t id;
    uint16_t cylinders;
    uint16_t sectors;
    uint16_t heads;
} DISK;

bool disk_init(DISK *disk, uint8_t driveNumber);
bool disk_read_sectors(DISK *disk, uint32_t lba, uint8_t sectors, void *lowerDataOut);

#endif // __DISK_H__