const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const vl = @import("./ViewLocator.zig");
const Shared = @import("Helpers.zig").Shared;
const Locale = @import("Localelizer.zig").Locale;
const Locales = @import("Localelizer.zig").Locales;
const Logger = @import("Logger.zig").Logger;
const Views = @import("ViewLocator.zig").Views;
const Inputs = @import("Inputs.zig").Inputs;

pub fn main() void {
    // Check that we can allocate memory
    const alloc = Shared.GetAllocator();
    if (alloc.create(u1)) |f| {
        defer alloc.destroy(f);
    } else |err| {
        std.debug.print("Failed to allocate!! {}", .{err});
        return;
    }

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

    raylib.setWindowTitle(locale.?.Title);

    Logger.Info("Begin Game Loop");
    while (!raylib.windowShouldClose()) {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        // Get the current view
        const view = vl.ViewLocator.Build(current_view);
        view.init();

        // Draw the current view
        const new_view = view.DrawRoutine();
        defer current_view = new_view;

        if (Shared.Settings.GetSettings().Debug) {
            raylib.drawFPS(10, 10);
        }

        if (new_view != current_view) {
            view.deinit();

            Logger.Debug_Formatted("New View: {}", .{current_view});
        }

        // Quit main loop
        if (new_view == Views.Quit) break;

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
