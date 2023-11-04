const std = @import("std");
const raylib = @import("raylib");
const Settings = @import("./Settings.zig").Settings;
const MenuView = @import("./Views/MenuView.zig").MenuView;

pub fn main() void {
    // Get an allocator
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator: std.mem.Allocator = gp.allocator();

    // Load settings
    var loadedSettings = Settings.load(allocator);
    defer _ = Settings.save(loadedSettings, allocator);

    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = false });
    raylib.InitWindow(loadedSettings.CurrentResolution.Width, loadedSettings.CurrentResolution.Height, "Scale Game!");
    raylib.SetTargetFPS(60);

    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        if (raylib.IsKeyDown(raylib.KeyboardKey.KEY_ESCAPE)) {
            std.debug.print("Escape pressed", .{});
        }

        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);

        raylib.DrawText("Scale Game", 100, 100, 20, raylib.YELLOW);
    }
}
