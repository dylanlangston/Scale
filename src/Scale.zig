const std = @import("std");
const raylib = @import("raylib");

pub fn main() void {
    std.debug.print("Scale Game!\n", .{});

    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.InitWindow(800, 800, "Scale Game!");
    raylib.SetTargetFPS(60);

    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);

        raylib.DrawText("Scale Game", 100, 100, 20, raylib.YELLOW);
    }
}
