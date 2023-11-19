const builtin = @import("builtin");
const std = @import("std");
const Allocator = std.mem.Allocator;
const Locales = @import("Localelizer.zig").Locales;
const Logger = @import("Logger.zig").Logger;
const Shared = @import("Helpers.zig").Shared;

pub const Settings = struct {
    CurrentResolution: Resolution,
    Debug: bool,
    DebugView: ?i32,
    UserLocale: Locales,
    Updated: bool = false,

    pub fn save(self: Settings, allocator: Allocator) bool {
        var settings = std.ArrayList(u8).init(allocator);
        defer settings.deinit();

        std.json.stringify(self, .{}, settings.writer()) catch |err| {
            std.debug.print("Unable to serialize settings: {}\n", .{err});
            return false;
        };

        if (builtin.target.os.tag == .wasi) {
            SaveWasmSettings(settings.items);
            return true;
        }

        var settings_file = std.fs.cwd().createFile(settingsFile, .{ .read = true }) catch |err| {
            std.debug.print("Unable to create settings file: {}\n", .{err});
            return false;
        };
        defer settings_file.close();

        _ = settings_file.write(settings.items) catch |err| {
            std.debug.print("Unable to save settings: {}\n", .{err});
            return false;
        };

        return true;
    }
    pub fn load(allocator: Allocator) Settings {
        Logger.Info("Load settings");
        if (builtin.target.os.tag == .wasi) {
            const wasm_settings = GetWasmSettings();
            var settings = std.json.parseFromSlice(Settings, allocator, wasm_settings.?, .{}) catch return default_settings;
            defer settings.deinit();

            return NormalizeSettings(settings.value);
        }

        // Open file
        var settings_file = std.fs.cwd().openFile(settingsFile, .{}) catch return default_settings;
        defer settings_file.close();

        // Read the contents
        const max_bytes = 10000;
        const file_buffer = settings_file.readToEndAlloc(allocator, max_bytes) catch return default_settings;
        defer allocator.free(file_buffer);

        // Parse JSON
        var settings = std.json.parseFromSlice(Settings, allocator, file_buffer, .{}) catch return default_settings;
        defer settings.deinit();

        return NormalizeSettings(settings.value);
    }

    pub fn update(base: Settings, diff: anytype) Settings {
        var updated = base;
        inline for (std.meta.fields(@TypeOf(diff))) |f| {
            @field(updated, f.name) = @field(diff, f.name);
        }
        @field(updated, "Updated") = true;
        return updated;
    }

    pub fn UpdatesProcessed(base: Settings) Settings {
        var updated = base;
        @field(updated, "Updated") = false;
        return updated;
    }

    fn NormalizeSettings(settings: Settings) Settings {
        return Settings{
            .CurrentResolution = Resolution{ .Width = @max(Resolutions[0].Width, settings.CurrentResolution.Width), .Height = @max(Resolutions[0].Height, settings.CurrentResolution.Height) },
            .Debug = settings.Debug,
            .DebugView = settings.DebugView,
            .UserLocale = settings.UserLocale,
        };
    }

    const settingsFile = "settings.json";

    const default_settings = Settings{
        .CurrentResolution = Resolutions[0],
        .Debug = false,
        .DebugView = null,
        .UserLocale = Locales.unknown,
    };
};

const Resolution = struct {
    Width: i16,
    Height: i16,
};

pub const Resolutions = [_]Resolution{
    Resolution{ .Width = 800, .Height = 600 },
    Resolution{ .Width = 800, .Height = 1280 },
    Resolution{ .Width = 1280, .Height = 720 },
    Resolution{ .Width = 1280, .Height = 800 },
    Resolution{ .Width = 1280, .Height = 1024 },
    Resolution{ .Width = 1360, .Height = 768 },
    Resolution{ .Width = 1366, .Height = 768 },
    Resolution{ .Width = 1440, .Height = 900 },
    Resolution{ .Width = 1600, .Height = 900 },
    Resolution{ .Width = 1680, .Height = 1050 },
    Resolution{ .Width = 1920, .Height = 1080 },
    Resolution{ .Width = 1920, .Height = 1200 },
    Resolution{ .Width = 2560, .Height = 1440 },
    Resolution{ .Width = 2560, .Height = 1600 },
    Resolution{ .Width = 2560, .Height = 1080 },
    Resolution{ .Width = 3440, .Height = 1440 },
    Resolution{ .Width = 3840, .Height = 2160 },
};

fn GetWasmSettings() ?([:0]const u8) {
    // We load the settings via arguments passed emscripten on startup
    var args = std.process.ArgIterator.initWithAllocator(Shared.GetAllocator()) catch {
        return null;
    };
    defer args.deinit();
    _ = args.skip();
    const settings = args.next();
    return settings;
}

export fn updateWasmResolution(width: i16, height: i16) void {
    Shared.Settings.UpdateSettings(.{
        .CurrentResolution = Resolution{ .Width = width, .Height = height },
    });
}

var wasm_settings_buf: std.ArrayList(u8) = undefined;
export fn getSettingsVal(int: usize) u8 {
    return wasm_settings_buf.items[int];
}
export fn getSettingsSize() u32 {
    return @intCast(wasm_settings_buf.items.len);
}
fn SaveWasmSettings(settings: []u8) void {
    wasm_settings_buf.deinit();
    wasm_settings_buf = std.ArrayList(u8).init(Shared.GetAllocator());

    wasm_settings_buf.appendSlice(settings) catch {
        Logger.Error("Failed to save settings");
    };

    // This is a bit of a hack, we just post a message saying "save-settings" right now to trigger the save
    // We should call a JS function from ZIG but I've failed to get that to work for too long and need to move on...
    std.log.default.info("{s}", .{"save-settings"});
}
