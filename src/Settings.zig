const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Settings = struct {
    CurrentResolution: Resolution,

    pub fn save(self: Settings, allocator: Allocator) bool {
        var settings = std.ArrayList(u8).init(allocator);
        defer settings.deinit();

        std.json.stringify(self, .{}, settings.writer()) catch |err| {
            std.debug.print("Unable to serialize settings: {}\n", .{err});
            return false;
        };

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
        // Open file
        var settings_file = std.fs.cwd().openFile(settingsFile, .{}) catch return default_settings;
        defer settings_file.close();

        // Read the contents
        const buffer_size = 2000;
        const file_buffer = settings_file.readToEndAlloc(allocator, buffer_size) catch return default_settings;
        defer allocator.free(file_buffer);

        var settings = std.json.parseFromSlice(Settings, allocator, file_buffer, .{}) catch return default_settings;
        return settings.value;
    }

    const settingsFile = "settings.json";

    const default_settings = Settings{ .CurrentResolution = Resolutions[0] };
};

const Resolution = struct {
    Width: i16,
    Height: i16,
};

const Resolutions = [_]Resolution{
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
