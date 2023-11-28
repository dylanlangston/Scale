const std = @import("std");
const raylib = @import("raylib");
const Shared = @import("Helpers.zig").Shared;

pub const TextureManager = struct {
    var LoadedTextures: ?std.AutoHashMap(Textures, raylib.Texture) = null;

    const TextureManagerErrors = error{ FailedToAppend, NotFound };

    pub inline fn GetTexture(texture: Textures) TextureManagerErrors!raylib.Texture {
        if (LoadedTextures == null) {
            LoadedTextures = std.AutoHashMap(Textures, raylib.Texture).init(Shared.GetAllocator());
        }

        if (LoadedTextures.?.contains(texture)) {
            return LoadedTextures.?.get(texture).?;
        }

        switch (texture) {
            Textures.Brick => {
                return SaveTextureToCache(Textures.Brick, ".png", brick);
            },
            else => {
                return TextureManagerErrors.NotFound;
            },
        }
    }

    inline fn SaveTextureToCache(key: Textures, fileType: [:0]const u8, bytes: [:0]const u8) TextureManagerErrors!raylib.Texture {
        const i = raylib.loadImageFromMemory(fileType, bytes);
        const t = raylib.loadTextureFromImage(i);
        raylib.setTextureFilter(
            t,
            @intFromEnum(raylib.TextureFilter.texture_filter_trilinear),
        );
        LoadedTextures.?.put(key, t) catch return TextureManagerErrors.FailedToAppend;
        return t;
    }

    pub inline fn deinit() void {
        if (LoadedTextures != null) {
            LoadedTextures.?.deinit();
        }
    }
};

// Textures
const brick: [:0]const u8 = @embedFile("./Images/brick.png");

pub const Textures = enum {
    Brick,
    Unknown,
};
