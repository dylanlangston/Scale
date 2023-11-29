const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const BaseView = @import("./Views/View.zig").View;
const SettingsManager = @import("./Settings.zig").Settings;
const LocalelizerLocale = @import("Localelizer.zig").Locale;
const Locales = @import("Localelizer.zig").Locales;
const Localelizer = @import("Localelizer.zig").Localelizer;
const FontManager = @import("FontManager.zig").FontManager;
const Fonts = @import("FontManager.zig").Fonts;
const TextureManager = @import("TextureManager.zig").TextureManager;
const Textures = @import("TextureManager.zig").Textures;
const Logger = @import("Logger.zig").Logger;
const PausedViewModel = @import("./ViewModels/PausedViewModel.zig").PausedViewModel;
const Views = @import("ViewLocator.zig").Views;

pub const Shared = struct {
    var gp: std.heap.GeneralPurposeAllocator(.{}) = GetGPAllocator();
    inline fn GetGPAllocator() std.heap.GeneralPurposeAllocator(.{}) {
        if (builtin.mode == .Debug) {
            return std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
        }

        return undefined;
    }

    const allocator: std.mem.Allocator = InitAllocator();
    pub fn InitAllocator() std.mem.Allocator {
        if (builtin.os.tag == .wasi) {
            return std.heap.raw_c_allocator;
        } else if (builtin.mode == .Debug) {
            return gp.allocator();
        } else {
            return std.heap.c_allocator;
        }
    }

    pub fn GetAllocator() std.mem.Allocator {
        return allocator;
    }

    pub fn GetFont(font: Fonts) raylib.Font {
        return FontManager.GetFont(font) catch |err| {
            Logger.Debug_Formatted("Failed to get font: {}", .{err});
            return raylib.getFontDefault();
        };
    }

    pub fn GetTexture(font: Textures) raylib.Texture {
        return TextureManager.GetTexture(font) catch |err| {
            Logger.Debug_Formatted("Failed to get texture: {}", .{err});
            return raylib.loadTextureFromImage(raylib.loadImageFromScreen());
        };
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

            if (builtin.target.os.tag == .wasi) {
                SaveNow();
            }
        }

        pub fn UpdatesProcessed() void {
            loaded_settings = SettingsManager.UpdatesProcessed(GetSettings());
        }

        pub fn SaveNow() void {
            _ = loaded_settings.?.save(Shared.GetAllocator());
        }
    };

    pub const Locale = struct {
        var locale: ?LocalelizerLocale = null;
        inline fn GetLocale_Internal() ?LocalelizerLocale {
            const user_locale = Shared.Settings.GetSettings().UserLocale;
            if (user_locale == Locales.unknown) return null;

            if (locale == null) {
                locale = Localelizer.get(user_locale, Shared.GetAllocator()) catch return null;
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

    pub fn Pause(view: Views) Views {
        const paused_vm = PausedViewModel.GetVM();
        paused_vm.PauseView(view);
        return Views.Paused;
    }

    pub inline fn deinit() void {
        // GeneralPurposeAllocator
        defer _ = gp.deinit();

        // Localelizer
        defer Localelizer.deinit();

        // Fonts
        defer FontManager.deinit();

        // Textures
        defer TextureManager.deinit();

        // Settings
        _ = loaded_settings.?.save(Shared.GetAllocator());
    }
};
