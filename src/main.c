#include <raylib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <enet/enet.h>

#include "server/server.h"
#include "client/client.h"

int main(int argc, char *argv[]) {
    if (enet_initialize() != 0) {
        printf("enet initialization didnt work\n");
        return EXIT_FAILURE;
    }    
    atexit(enet_deinitialize);

    // default to client
    if (argc < 2) {
        return RunClient();
    }

    if (strcmp(argv[1], "-server") == 0 || strcmp(argv[1], "-s") == 0)
        return RunServer();
    else if (strcmp(argv[1], "-client") == 0 || strcmp(argv[1], "-c") == 0)
        return RunClient();
    else {
        printf("invalid argument, usage: %s [-server|-client] or [-s|-c]\n", argv[0]);
        return EXIT_FAILURE;
    }
}