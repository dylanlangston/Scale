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

    raylib.initWindow(loadedSettings.CurrentResolution.Width, loadedSettings.CurrentResolution.Height, "Scale Game!");
    raylib.setTargetFPS(60);

    raylib.setExitKey(.key_null);

    defer raylib.closeWindow();

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        const key_press = raylib.getKeyPressed();
        if (key_press != raylib.KeyboardKey.key_null) {
            std.debug.print("Keycode: {}\n", .{key_press});
        }

        raylib.clearBackground(raylib.Color.black);
        raylib.drawFPS(10, 10);

        raylib.drawText("Scale Game", 100, 100, 20, raylib.Color.yellow);
    }
}
