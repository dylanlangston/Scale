const std = @import("std");
const raylib = @import("raylib");
const Shared = @import("Helpers.zig").Shared;
const Logger = @import("Logger.zig").Logger;

pub const FontManager = struct {
    var LoadedFonts: ?std.AutoHashMap(Fonts, raylib.Font) = null;

    const FontManagerErrors = error{FailedToAppend};

    pub fn Init() void {
        for (std.enums.values(Fonts)) |font| {
            _ = GetFont(font) catch {
                Logger.Error("Failed to init font");
            };
        }
    }

    pub fn GetFont(font: Fonts) FontManagerErrors!raylib.Font {
        if (LoadedFonts == null) {
            LoadedFonts = std.AutoHashMap(Fonts, raylib.Font).init(Shared.GetAllocator());
        }

        if (LoadedFonts.?.contains(font)) {
            return LoadedFonts.?.get(font).?;
        }

        // https://www.fontspace.com/
        switch (font) {
            Fonts.EightBitDragon => {
                const bytes = EightBitDragon;
                const f = raylib.loadFontFromMemory(".ttf", bytes, 100, undefined);
                raylib.setTextureFilter(
                    f.texture,
                    @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
                );
                LoadedFonts.?.put(Fonts.EightBitDragon, f) catch return FontManagerErrors.FailedToAppend;
                return f;
            },
            Fonts.TwoLines => {
                const bytes = _2Lines;
                const f = raylib.loadFontFromMemory(".ttf", bytes, 100, undefined);
                raylib.setTextureFilter(
                    f.texture,
                    @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
                );
                LoadedFonts.?.put(Fonts.TwoLines, f) catch return FontManagerErrors.FailedToAppend;
                return f;
            },
            Fonts.EcBricksRegular => {
                return SaveFontToCache(Fonts.EcBricksRegular, bricks);
            },
        }
    }

    fn SaveFontToCache(key: Fonts, bytes: [:0]u8) raylib.Font {
        const f = raylib.loadFontFromMemory(".ttf", bytes, 100, undefined);
        raylib.setTextureFilter(
            f.texture,
            @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
        );
        LoadedFonts.?.put(key, f) catch return FontManagerErrors.FailedToAppend;
        return f;
    }

    pub fn deinit() void {
        if (LoadedFonts != null) {
            LoadedFonts.?.deinit();
        }
    }
};

// Fonts
const EightBitDragon: [:0]u8 = @embedFile("./Fonts/EightBitDragon.ttf");
const _2Lines = @embedFile("./Fonts/2Lines.ttf");
const bricks = @embedFile("./Fonts/EcBricksRegular.ttf");

pub const Fonts = enum {
    EightBitDragon,
    TwoLines,
    EcBricksRegular,
};
