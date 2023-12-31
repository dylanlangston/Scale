const std = @import("std");
const raylib = @import("raylib");
const Shared = @import("Helpers.zig").Shared;
const Logger = @import("Logger.zig").Logger;

pub const FontManager = struct {
    var LoadedFonts: ?std.AutoHashMap(Fonts, raylib.Font) = null;

    const FontManagerErrors = error{ FailedToAppend, NotFound };

    pub inline fn GetFont(font: Fonts) FontManagerErrors!raylib.Font {
        if (LoadedFonts == null) {
            LoadedFonts = std.AutoHashMap(Fonts, raylib.Font).init(Shared.GetAllocator());
        }

        if (LoadedFonts.?.contains(font)) {
            return LoadedFonts.?.get(font).?;
        }

        // Source - https://www.fontspace.com/
        switch (font) {
            Fonts.EightBitDragon => {
                return SaveFontToCache(Fonts.EightBitDragon, ".ttf", EightBitDragon);
            },
            Fonts.TwoLines => {
                return SaveFontToCache(Fonts.TwoLines, ".ttf", _2Lines);
            },
            Fonts.EcBricksRegular => {
                return SaveFontToCache(Fonts.EcBricksRegular, ".ttf", bricks);
            },
            else => {
                return FontManagerErrors.NotFound;
            },
        }
    }

    inline fn SaveFontToCache(key: Fonts, fileType: [:0]const u8, bytes: [:0]const u8) FontManagerErrors!raylib.Font {
        var fontChars: [95]i32 = .{};
        inline for (0..fontChars.len) |i| fontChars[i] = @as(i32, @intCast(i)) + 32;
        const f = raylib.loadFontFromMemory(fileType, bytes, 100, &fontChars);
        raylib.setTextureFilter(
            f.texture,
            @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
        );
        LoadedFonts.?.put(key, f) catch return FontManagerErrors.FailedToAppend;
        return f;
    }

    pub inline fn deinit() void {
        if (LoadedFonts != null) {
            LoadedFonts.?.deinit();
        }
    }
};

// Fonts
const EightBitDragon: [:0]const u8 = @embedFile("./Fonts/EightBitDragon.ttf");
const _2Lines: [:0]const u8 = @embedFile("./Fonts/2Lines.ttf");
const bricks: [:0]const u8 = @embedFile("./Fonts/EcBricksRegular.ttf");

pub const Fonts = enum {
    EightBitDragon,
    TwoLines,
    EcBricksRegular,
    Unknown,
};
