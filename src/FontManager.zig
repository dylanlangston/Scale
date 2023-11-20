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
                const bytes = @embedFile("./Fonts/EightBitDragon.ttf");
                const f = raylib.loadFontFromMemory(".ttf", bytes, 100, undefined);
                raylib.setTextureFilter(
                    f.texture,
                    @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
                );
                LoadedFonts.?.put(Fonts.EightBitDragon, f) catch return FontManagerErrors.FailedToAppend;
                return f;
            },
            Fonts.TwoLines => {
                const bytes = @embedFile("./Fonts/2Lines.ttf");
                const f = raylib.loadFontFromMemory(".ttf", bytes, 100, undefined);
                raylib.setTextureFilter(
                    f.texture,
                    @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
                );
                LoadedFonts.?.put(Fonts.TwoLines, f) catch return FontManagerErrors.FailedToAppend;
                return f;
            },
            Fonts.EcBricksRegular => {
                const bytes = @embedFile("./Fonts/EcBricksRegular.ttf");
                const f = raylib.loadFontFromMemory(".ttf", bytes, 100, undefined);
                raylib.setTextureFilter(
                    f.texture,
                    @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
                );
                LoadedFonts.?.put(Fonts.EcBricksRegular, f) catch return FontManagerErrors.FailedToAppend;
                return f;
            },
        }
    }

    pub fn deinit() void {
        if (LoadedFonts != null) {
            LoadedFonts.?.deinit();
        }
    }
};

pub const Fonts = enum {
    EightBitDragon,
    TwoLines,
    EcBricksRegular,
};
