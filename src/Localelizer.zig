const std = @import("std");
const Allocator = std.mem.Allocator;
const Logger = @import("Logger.zig").Logger;

pub const Localelizer = struct {
    inline fn get_locale_file(locale: Locales) [:0]const u8 {
        switch (locale) {
            Locales.english => {
                return @embedFile("./Locales/english.json");
            },
            Locales.spanish => {
                return @embedFile("./Locales/spanish.json");
            },
            Locales.french => {
                return @embedFile("./Locales/french.json");
            },
            else => {
                // English as fallback
                return @embedFile("./Locales/english.json");
            },
        }
    }

    const LocalelizerError = error{ FileNotFound, FileReadError, InvalidFileFormat };

    var loaded_locale: ?std.json.Parsed(Locale) = null;
    pub inline fn get(locale: Locales, allocator: Allocator) LocalelizerError!Locale {
        const locale_file = get_locale_file(locale);
        // Deinit old locale if needed
        deinit();

        // Parse JSON
        loaded_locale = std.json.parseFromSlice(Locale, allocator, locale_file, .{}) catch return LocalelizerError.InvalidFileFormat;

        return loaded_locale.?.value;
    }

    pub inline fn deinit() void {
        if (loaded_locale != null) {
            defer loaded_locale.?.deinit();
        }
    }

    pub inline fn getDisplayName(locale: Locales) [:0]const u8 {
        switch (locale) {
            Locales.english => {
                return "English (US)";
            },
            Locales.spanish => {
                return "Spanish";
            },
            Locales.french => {
                return "French";
            },
            else => {
                return "Unknown";
            },
        }
    }
};

pub const Locale = struct {
    Dylan_Splash_Text: [:0]const u8,
    Title: [:0]const u8,
    Menu_StartGame: [:0]const u8,
    Menu_Settings: [:0]const u8,
    Menu_Quit: [:0]const u8,
    Paused: [:0]const u8,
    Continue: [:0]const u8,
    Quit: [:0]const u8,
    Settings: [:0]const u8,
    Missing_Text: [:0]const u8,
};

pub const Locales = enum {
    unknown,
    english,
    spanish,
    french,
};
