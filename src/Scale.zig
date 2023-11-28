const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const vl = @import("./ViewLocator.zig");
const Shared = @import("Helpers.zig").Shared;
const Helpers = @import("Helpers.zig");
const Locale = @import("Localelizer.zig").Locale;
const Locales = @import("Localelizer.zig").Locales;
const Logger = @import("Logger.zig").Logger;
const Views = @import("ViewLocator.zig").Views;
const Inputs = @import("Inputs.zig").Inputs;
const FontManager = @import("FontManager.zig").FontManager;
const JSController = @import("JSGameController.zig");

pub inline fn main() void {
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

    const _settings = Shared.Settings.GetSettings();

    // Set logging level
    if (_settings.Debug) {
        raylib.setTraceLogLevel(raylib.TraceLogLevel.log_all);
    } else {
        raylib.setTraceLogLevel(raylib.TraceLogLevel.log_info);
    }

    // Create window
    Logger.Info("Creating Window");
    raylib.setConfigFlags(
        @enumFromInt( //@intFromEnum(raylib.ConfigFlags.flag_window_always_run) +
            @intFromEnum(raylib.ConfigFlags.flag_msaa_4x_hint) +
            @intFromEnum(raylib.ConfigFlags.flag_window_resizable)),
    );
    raylib.initWindow(_settings.CurrentResolution.Width, _settings.CurrentResolution.Height, "Scale Game!");
    raylib.setExitKey(.key_null);
    raylib.setTargetFPS(_settings.TargetFPS);
    defer raylib.closeWindow();

    // Default View on startup is the Splash Screen
    var current_view: vl.Views = vl.Views.Raylib_Splash_Screen;

    if (_settings.Debug and _settings.DebugView != null) {
        current_view = @enumFromInt(_settings.DebugView.?);
    }
    defer DeinitViews();

    Logger.Info_Formatted("Platform {}", .{builtin.os.tag});

    // Load locale
    Logger.Info("Load Locale");
    var locale: ?Locale = null;
    locale = Shared.Locale.GetLocale();

    // fallback if locale is not set
    if (locale == null) {
        // For now just set the locale to english since that's the only locale
        Shared.Settings.UpdateSettings(.{
            .UserLocale = Locales.english,
        });

        Logger.Debug("Settings Updated");

        // Refresh locale
        locale = Shared.Locale.RefreshLocale();

        Logger.Debug("Refreshed locale");

        Shared.Settings.UpdatesProcessed();

        Logger.Debug("Updated Processed");
    }

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
            if (new_view != Views.Paused) view.deinit();

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

inline fn DeinitViews() void {
    for (std.enums.values(Views)) |v| {
        const view = vl.ViewLocator.Build(v);
        view.deinit();
    }
}
