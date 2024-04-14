#include <devices/disk/disk.h>
#include <libc/stdio/printf.h>

#include <fs/fat.h>

static void hcf(void)
{
    asm("cli");
    for (;;)
    {
        asm("hlt");
    }
}

void start(uint8_t boot_drive)
{
    terminal_initialize();
    disable_cursor();

    DISK disk;
    if (!init_disk(&disk, boot_drive))
    {
        printf("Failed to initialize disk\n");
        hcf();
    }

    if (!init_fat(&disk))
    {
        printf("Failed to initialize FAT\n");
        hcf();
    }

    hcf();
}