#include <raylib.h>

int main(int argc, char* argv[]) {
    InitWindow(800, 600, "My Game");

    while (!WindowShouldClose()) {
        BeginDrawing();
            ClearBackground(BLACK);
            DrawFPS(10, 10);
        EndDrawing();
    }

    CloseWindow();
    return 0;
}