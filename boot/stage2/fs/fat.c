#include <fs/fat.h>

FAT_BootRecord boot_record;

bool fat_read_boot_sector(DISK *disk)
{
    if (disk_read_sectors(disk, 0, 1, &boot_record))
        return true;
    else
        return false;
}

uint16_t calculate_total_sectors()
{
    return boot_record.total_sectors;
}

uint16_t calculate_fat_size()
{
    return 0;
}

bool init_fat(DISK *disk)
{
    if (!fat_read_boot_sector(disk))
    {
        printf("FAT: Failed to boot sector!\n");
        return false;
    }

    printf("Bytes per Sector: %d\n", boot_record.bytes_per_sector);
    printf("Sectors per Cluster: %d\n", boot_record.sectors_per_cluster);
    printf("Reserved Sectors: %d\n", boot_record.reserved_sectors);
    printf("Number of FATs: %d\n", boot_record.numbers_of_fats);
    printf("Root Directory Entries: %d\n", boot_record.root_dir_entries);
    printf("Total Sectors: %d\n", boot_record.total_sectors);
    printf("Media Descriptor Type: 0x%X\n", boot_record.media_descriptor_type);
    printf("Sectors per FAT: %d\n", boot_record.sectors_per_fat);
    printf("Sectors per Track: %d\n", boot_record.sectors_per_track);
    printf("Number of Heads: %d\n", boot_record.number_of_heads);
    printf("Number of Hidden Sectors: %u\n", boot_record.number_of_hidden_sectors);
    printf("Total Sectors (Large): %u\n", boot_record.total_sectors_large);
    printf("Drive Number: 0x%X\n", boot_record.drive_number);
    printf("Signature: 0x%X\n", boot_record.signature);
    printf("Volume ID: 0x%X\n", boot_record.volume_id);
    printf("Volume Label: %.11s\n", boot_record.volume_label);
    printf("System ID: %.8s\n", boot_record.system_id);
    printf("Boot Signature: 0x%X\n", boot_record.boot_signature);

    return true;
}