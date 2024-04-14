#ifndef __DRIVE_BRIDGE_H__
#define __DRIVE_BRIDGE_H__

#include <stdint.h>
#include <stdbool.h>

bool __attribute__((cdecl)) get_drive_parameters(uint8_t drive, uint8_t *driveTypeOut, uint16_t *cylindersOut, uint16_t *sectorsOut, uint16_t *headsOut);
bool __attribute__((cdecl)) disk_reset(uint8_t drive);
bool __attribute__((cdecl)) disk_read(uint8_t drive, uint16_t cylinder, uint16_t sector, uint16_t head, uint8_t count, void *lowerDataOut);

#endif // __DRIVE_BRIDGE_H__