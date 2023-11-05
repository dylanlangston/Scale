const std = @import("std");
const raylib = @import("raylib");
const SettingsManager = @import("./Settings.zig").Settings;
const Resolutions = @import("./Settings.zig").Resolutions;
const BaseView = @import("./Views/View.zig").View;
const vl = @import("./ViewLocator.zig");
const LocalelizerLocale = @import("Localelizer.zig").Locale;
const Locales = @import("Localelizer.zig").Locales;
const Localelizer = @import("Localelizer.zig").Localelizer;

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

    pub const Settings = struct {
        pub fn GetSettings() SettingsManager {
            if (loaded_settings == null) {
                loaded_settings = SettingsManager.load(Shared.GetAllocator());
            }
            return loaded_settings.?;
        }

        pub fn UpdateSettings(newValue: anytype) void {
            loaded_settings = SettingsManager.update(GetSettings(), newValue);
        }

        pub fn UpdatesProcessed() void {
            loaded_settings = SettingsManager.UpdatesProcessed(GetSettings());
        }
    };

    pub const Locale = struct {
        var locale: ?LocalelizerLocale = null;
        fn GetLocale_Internal() ?LocalelizerLocale {
            const user_locale = Shared.Settings.GetSettings().UserLocale;
            if (user_locale == null) return null;

            if (locale == null) {
                locale = Localelizer.get(user_locale.?, Shared.GetAllocator()) catch return null;
            }

            return locale;
        }

        pub fn GetLocale() ?LocalelizerLocale {
            return GetLocale_Internal();
        }

        pub fn RefreshLocale() ?LocalelizerLocale {
            if (locale != null) {
                locale = null;
            }
            return GetLocale_Internal();
        }
    };

    pub fn deinit() void {
        // GeneralPurposeAllocator
        defer _ = gp.deinit();

        // Localelizer
        defer Localelizer.deinit();

        // Settings
        _ = loaded_settings.?.save(Shared.GetAllocator());
    }
};

pub fn main() void {
    // Cleanup code
    defer Shared.deinit();

    // Create window
    raylib.initWindow(Shared.Settings.GetSettings().CurrentResolution.Width, Shared.Settings.GetSettings().CurrentResolution.Height, "Scale Game!");
    raylib.setExitKey(.key_null);
    raylib.setTargetFPS(60);
    defer raylib.closeWindow();

    // Default View on startup is the Splash Screen
    var current_view: vl.Views = vl.Views.Splash_Screen;

    // Load locale
    var locale: ?LocalelizerLocale = null;
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
