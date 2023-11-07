const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const vl = @import("./ViewLocator.zig");
const Shared = @import("Helpers.zig").Shared;
const Locale = @import("Localelizer.zig").Locale;
const Locales = @import("Localelizer.zig").Locales;
const Logger = @import("Logger.zig").Logger;

pub fn main() void {
    // Cleanup code
    defer Shared.deinit();

    // Set logging level
    if (Shared.Settings.GetSettings().Debug) {
        raylib.setTraceLogLevel(raylib.TraceLogLevel.log_all);
    } else {
        raylib.setTraceLogLevel(raylib.TraceLogLevel.log_info);
    }

    // Create window
    Logger.Info("Creating Window");
    raylib.setConfigFlags(raylib.ConfigFlags.flag_window_transparent);
    raylib.initWindow(Shared.Settings.GetSettings().CurrentResolution.Width, Shared.Settings.GetSettings().CurrentResolution.Height, "Scale Game!");
    raylib.setExitKey(.key_null);
    raylib.setTargetFPS(60);
    defer raylib.closeWindow();

    // Default View on startup is the Splash Screen
    var current_view: vl.Views = vl.Views.Raylib_Splash_Screen;

    Logger.Info_Formatted("Platform {}", .{builtin.os.tag});

    // Load locale
    Logger.Info("Load Locale");
    var locale: ?Locale = null;
    locale = Shared.Locale.GetLocale();

    // fallback if locale is not set
    if (locale == null) {
        // For now just set the locale to english since that's the only locale
        Shared.Settings.UpdateSettings(.{
            .UserLocale = Locales.en_us,
        });

        Logger.Debug("Settings Updated");

        // Refresh locale
        locale = Shared.Locale.RefreshLocale();

        Logger.Debug("Refreshed locale");

        Shared.Settings.UpdatesProcessed();

        Logger.Debug("Updated Processed");
    }

    Logger.Debug_Formatted("Title: {s}", .{"test"});

    if (builtin.os.tag != .wasi) {
        raylib.setWindowTitle(locale.?.Title);
    }

    Logger.Info("Begin Game Loop");
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
