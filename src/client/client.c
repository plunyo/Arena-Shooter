#include <raylib.h>
#include <stdlib.h>
#include "network/network.h"
#include "render/render.h"

int RunClient(void) {
    InitRender();

    ENetHost* host = InitNetwork();
    ConnectNetwork(host, "127.0.0.1", 1234);

    while (!WindowShouldClose()) {
        UpdateNetwork(host);
        DrawRender();
    }

    CloseNetwork(host);
    CloseRender();

    return EXIT_SUCCESS;
}