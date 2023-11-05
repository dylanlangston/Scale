const std = @import("std");
const raylib = @import("raylib");
const SettingsManager = @import("./Settings.zig").Settings;
const BaseView = @import("./Views/View.zig").View;
const vl = @import("./ViewLocator.zig");

pub const Shared = struct {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};

    var allocator: ?std.mem.Allocator = null;
    pub fn GetAllocator() std.mem.Allocator {
        if (allocator == null) {
            allocator = gp.allocator();
        }
        return allocator.?;
    }

    var loaded_settings: ?SettingsManager = null;
    pub fn GetSettings() SettingsManager {
        if (loaded_settings == null) {
            loaded_settings = SettingsManager.load(Shared.GetAllocator());
        }
        return loaded_settings.?;
    }

    pub fn deinit() void {
        // GeneralPurposeAllocator
        defer _ = gp.deinit();

        // Settings
        _ = loaded_settings.?.save(Shared.GetAllocator());
    }
};

pub fn main() void {
    defer Shared.deinit();

    raylib.initWindow(Shared.GetSettings().CurrentResolution.Width, Shared.GetSettings().CurrentResolution.Height, "Scale Game!");
    raylib.setExitKey(.key_null);
    raylib.setTargetFPS(60);
    defer raylib.closeWindow();

    // Default View on startup is the Splash Screen
    var current_view: vl.Views = vl.Views.Splash_Screen;

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        if (Shared.GetSettings().Debug) {
            raylib.drawFPS(10, 10);
        }

        // Get the current view
        const view = vl.ViewLocator.Build(current_view);

        // Draw the current view
        const new_view = view.DrawRoutine();

        if (new_view != current_view) {
            current_view = new_view;
            std.debug.print("New View: {}\n", .{current_view});
        }
    }
}
