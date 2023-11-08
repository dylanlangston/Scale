const std = @import("std");
const raylib = @import("raylib");
const Shared = @import("Helpers.zig").Shared;

pub const FontManager = struct {
    var LoadedFonts: ?std.AutoHashMap(Fonts, raylib.Font) = null;

    const FontManagerErrors = error{FailedToAppend};

    pub fn GetFont(font: Fonts) FontManagerErrors!raylib.Font {
        if (LoadedFonts == null) {
            LoadedFonts = std.AutoHashMap(Fonts, raylib.Font).init(Shared.GetAllocator());
        }

        if (LoadedFonts.?.contains(font)) {
            return LoadedFonts.?.get(font).?;
        }

        switch (font) {
            Fonts.SpaceMeatball => {
                const bytes = @embedFile("./Fonts/Space Meatball.otf");
                const f = raylib.loadFontFromMemory(".otf", bytes, 100, undefined);
                LoadedFonts.?.put(Fonts.SpaceMeatball, f) catch return FontManagerErrors.FailedToAppend;
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

pub const Fonts = enum { SpaceMeatball };
