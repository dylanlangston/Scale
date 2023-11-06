const std = @import("std");
const raylib = @import("raylib");
const vl = @import("./ViewLocator.zig");
const Shared = @import("Helpers.zig").Shared;
const Locale = @import("Localelizer.zig").Locale;
const Locales = @import("Localelizer.zig").Locales;

pub fn main() void {
    // Cleanup code
    defer Shared.deinit();

    // Create window
    raylib.setConfigFlags(raylib.ConfigFlags.flag_window_transparent);
    raylib.initWindow(Shared.Settings.GetSettings().CurrentResolution.Width, Shared.Settings.GetSettings().CurrentResolution.Height, "Scale Game!");
    raylib.setExitKey(.key_null);
    raylib.setTargetFPS(60);
    defer raylib.closeWindow();

    // Default View on startup is the Splash Screen
    var current_view: vl.Views = vl.Views.Raylib_Splash_Screen;

    // Load locale
    var locale: ?Locale = null;
    locale = Shared.Locale.GetLocale();

    // fallback if locale is not set
    while (locale == null) {
        // For now just set the locale to english since that's the only locale
        Shared.Settings.UpdateSettings(.{
            .UserLocale = Locales.en_us,
        });

        // Refresh locale
        locale = Shared.Locale.RefreshLocale();

        Shared.Settings.UpdatesProcessed();
    }

    raylib.setWindowTitle(locale.?.Title);

    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        if (Shared.Settings.GetSettings().Debug) {
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

        const settings = Shared.Settings.GetSettings();
        if (settings.Updated) {
            // Set Current Resolution
            raylib.setWindowSize(settings.CurrentResolution.Width, settings.CurrentResolution.Height);

            // Refresh locale
            locale = Shared.Locale.RefreshLocale();

            // Set title
            raylib.setWindowTitle(locale.?.Title);

            // Ensure that this code doesn't run again until the settings are updated
            Shared.Settings.UpdatesProcessed();
        }
    }
}
