#include "bridge.h"


void mark_socket(void *interface, int id, int fd) {
    mark_socket_func func = (mark_socket_func)(interface);
    func(id, fd);
}
