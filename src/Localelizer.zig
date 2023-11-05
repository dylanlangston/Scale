const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Localelizer = struct {
    fn get_locale_file(locale: Locales) [:0]const u8 {
        switch (locale) {
            Locales.en_us => {
                return @embedFile("./Locales/en_us.json");
            },
        }
    }

    const LocalelizerError = error{ FileNotFound, FileReadError, InvalidFileFormat };

    var loaded_locale: ?std.json.Parsed(Locale) = null;
    pub fn get(locale: Locales, allocator: Allocator) LocalelizerError!Locale {
        const locale_file = get_locale_file(locale);

        // Deinit old locale if needed
        deinit();

        // Parse JSON
        loaded_locale = std.json.parseFromSlice(Locale, allocator, locale_file, .{}) catch return LocalelizerError.InvalidFileFormat;

        return loaded_locale.?.value;
    }

    pub fn deinit() void {
        if (loaded_locale != null) {
            defer loaded_locale.?.deinit();
        }
    }

    pub fn getDisplayName(locale: Locales) [:0]const u8 {
        switch (locale) {
            Locales.en_us => {
                return "English (US)";
            },
        }
    }
};

pub const Locale = struct {
    Title: [:0]const u8,
};

pub const Locales = enum { en_us };
