#include "render.h"
#include <raylib.h>

void InitRender(void) {
    InitWindow(1920, 1080, "Arena Shooter");
}

void DrawRender(void) {
    BeginDrawing();
        ClearBackground(BLACK);
        DrawFPS(10, 10);
    EndDrawing();
}

void CloseRender(void) {
    CloseWindow();
}