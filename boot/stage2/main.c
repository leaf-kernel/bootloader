#include <devices/disk/disk.h>
#include <libc/stdio/printf.h>

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
    if (!disk_init(&disk, boot_drive))
    {
        printf("Failed to initialize disk\n");
        hcf();
    }

    printf("Initialized disk (0x%02X)!\n", boot_drive);

    hcf();
}