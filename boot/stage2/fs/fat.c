#include <fs/fat.h>

FAT_Data data;

bool fat_read_boot_sector(DISK *disk)
{
    if (disk_read_sectors(disk, 0, 1, data.boot_sector))
        return true;
    else
        return false;
}

uint16_t fat_get_total_sectors()
{
    if (data.boot_sector->total_sectors != 0)
    {
        return data.boot_sector->total_sectors;
    }
    else
    {
        return data.boot_sector->total_sectors_large;
    }
}

uint16_t fat_get_fat_size()
{
    uint16_t bytes_per_sector = data.boot_sector->bytes_per_sector;
    uint16_t sectors_per_fat = data.boot_sector->sectors_per_fat;
    uint32_t fat_size_bytes = sectors_per_fat * bytes_per_sector;
    uint16_t fat_size_sectors = fat_size_bytes / bytes_per_sector;
    return fat_size_sectors;
}

uint16_t fat_get_root_dir_sectors()
{
    uint16_t bytes_per_sector = data.boot_sector->bytes_per_sector;
    uint16_t root_dir_entries = data.boot_sector->root_dir_entries;

    uint32_t root_dir_size_bytes = (uint32_t)root_dir_entries * 32;
    uint16_t root_dir_size_sectors = (root_dir_size_bytes + bytes_per_sector - 1) / bytes_per_sector;

    return root_dir_size_sectors;
}

uint16_t fat_get_first_data_sector()
{
    return data.boot_sector->reserved_sectors + (data.boot_sector->numbers_of_fats * fat_get_fat_size()) + fat_get_root_dir_sectors();
}

uint16_t fat_get_first_fat_sector()
{
    return data.boot_sector->reserved_sectors;
}

uint16_t fat_get_data_sectors()
{
    return fat_get_total_sectors() - (data.boot_sector->reserved_sectors + (data.boot_sector->numbers_of_fats * fat_get_fat_size()) + fat_get_root_dir_sectors());
}

uint16_t fat_get_total_clusters()
{
    return fat_get_data_sectors() / data.boot_sector->sectors_per_cluster;
}

uint16_t fat_get_first_root_dir_sector()
{
    return fat_get_first_data_sector() - fat_get_root_dir_sectors();
}

uint16_t fat_get_first_sector_of_cluster(uint16_t cluster)
{
    return ((cluster - 2) * data.boot_sector->sectors_per_cluster) + fat_get_first_data_sector();
}

void print_bs()
{
    dprintf("Bytes per Sector: %d\n", data.boot_sector->bytes_per_sector);
    dprintf("Sectors per Cluster: %d\n", data.boot_sector->sectors_per_cluster);
    dprintf("Reserved Sectors: %d\n", data.boot_sector->reserved_sectors);
    dprintf("Number of FATs: %d\n", data.boot_sector->numbers_of_fats);
    dprintf("Root Directory Entries: %d\n", data.boot_sector->root_dir_entries);
    dprintf("Total Sectors: %d\n", data.boot_sector->total_sectors);
    dprintf("Media Descriptor Type: 0x%X\n", data.boot_sector->media_descriptor_type);
    dprintf("Sectors per FAT: %d\n", data.boot_sector->sectors_per_fat);
    dprintf("Sectors per Track: %d\n", data.boot_sector->sectors_per_track);
    dprintf("Number of Heads: %d\n", data.boot_sector->number_of_heads);
    dprintf("Number of Hidden Sectors: %u\n", data.boot_sector->number_of_hidden_sectors);
    dprintf("Total Sectors (Large): %u\n", data.boot_sector->total_sectors_large);
    dprintf("Drive Number: 0x%X\n", data.boot_sector->drive_number);
    dprintf("Signature: 0x%X\n", data.boot_sector->signature);
    dprintf("Volume ID: 0x%X\n", data.boot_sector->volume_id);
    dprintf("Volume Label: %.11s\n", data.boot_sector->volume_label);
    dprintf("System ID: %.8s\n", data.boot_sector->system_id);
    dprintf("Boot Signature: 0x%X\n", data.boot_sector->boot_signature);
}

bool init_fat(DISK *disk)
{
    if (!fat_read_boot_sector(disk))
    {
        printf("FAT: Failed to boot sector!\n");
        return false;
    }

    return true;
}