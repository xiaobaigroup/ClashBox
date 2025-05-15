#pragma once

#include <malloc.h>
#include <stddef.h>
#include <stdint.h>

#define TAG "FlClash"

typedef const char *c_string;

typedef void (*mark_socket_func)(int id, int fd);

// cgo
extern void mark_socket(void *interface, int id, int fd);