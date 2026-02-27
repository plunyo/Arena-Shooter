#include "client/client.h"
#include <raylib.h>
#include <stdlib.h>

int RunClient() {
    InitWindow(1920, 1080, "Arena Shooter");

    while (!WindowShouldClose()) {
        BeginDrawing();
            ClearBackground(BLACK);
            DrawFPS(10, 10);
        EndDrawing();
    }

    CloseWindow();
    return EXIT_SUCCESS;
}