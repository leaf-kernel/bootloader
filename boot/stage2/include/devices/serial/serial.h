#ifndef __SERIAL_H__
#define __SERIAL_H__

#include <stdint.h>

#define QEMU_SERIAL_PORT 0x3f8

void outb(uint16_t port, uint8_t value);
void outw(uint16_t port, uint16_t value);
void outl(uint16_t port, uint32_t value);
uint8_t inb(uint16_t port);
uint16_t inw(uint16_t port);
uint32_t inl(uint16_t port);
void iowait();
void serial_flush(uint16_t port);

#endif // __SERIAL_H__