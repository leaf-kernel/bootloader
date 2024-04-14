#include <devices/disk/disk.h>
#include <devices/disk/drive_bridge.h>

bool disk_init(DISK *disk, uint8_t driveNumber)
{
    uint8_t driveType;
    uint16_t cylinders, sectors, heads;

    if (!get_drive_parameters(disk->id, &driveType, &cylinders, &sectors, &heads))
        return false;

    disk->id = driveNumber;
    disk->cylinders = cylinders;
    disk->heads = heads;
    disk->sectors = sectors;

    return true;
}

void lba2chs(DISK *disk, uint32_t lba, uint16_t *cylinderOut, uint16_t *sectorOut, uint16_t *headOut)
{
    *sectorOut = lba % disk->sectors + 1;
    *cylinderOut = (lba / disk->sectors) / disk->heads;
    *headOut = (lba / disk->sectors) % disk->heads;
}

bool disk_read_sectors(DISK *disk, uint32_t lba, uint8_t sectors, void *dataOut)
{
    uint16_t cylinder, sector, head;

    lba2chs(disk, lba, &cylinder, &sector, &head);

    for (int i = 0; i < 3; i++)
    {
        if (disk_read(disk->id, cylinder, sector, head, sectors, dataOut))
            return true;

        disk_reset(disk->id);
    }

    return false;
}