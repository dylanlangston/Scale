const std = @import("std");
const raylib = @import("raylib");
const Shared = @import("Helpers.zig").Shared;

pub const TextureManager = struct {
    var LoadedTextures: ?std.AutoHashMap(Textures, raylib.Texture) = null;

    const TextureManagerErrors = error{FailedToAppend};

    pub fn GetTexture(texture: Textures) TextureManagerErrors!raylib.Texture {
        if (LoadedTextures == null) {
            LoadedTextures = std.AutoHashMap(Textures, raylib.Texture).init(Shared.GetAllocator());
        }

        if (LoadedTextures.?.contains(texture)) {
            return LoadedTextures.?.get(texture).?;
        }

        switch (texture) {
            Textures.Brick => {
                const bytes = @embedFile("./Images/brick.png");
                const i = raylib.loadImageFromMemory(".png", bytes);
                const t = raylib.loadTextureFromImage(i);
                raylib.setTextureFilter(
                    t,
                    @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
                );
                LoadedTextures.?.put(Textures.Brick, t) catch return TextureManagerErrors.FailedToAppend;
                return t;
            },
        }
    }

    pub fn deinit() void {
        if (LoadedTextures != null) {
            LoadedTextures.?.deinit();
        }
    }
};

pub const Textures = enum {
    Brick,
};
