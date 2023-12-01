const std = @import("std");
const raylib = @import("raylib");
const Shared = @import("Helpers.zig").Shared;
const Logger = @import("Logger.zig").Logger;

pub const MusicManager = struct {
    var LoadedMusics: ?std.AutoHashMap(Musics, raylib.Music) = null;

    const MusicManagerErrors = error{ AudioDeviceNotReady, FailedToAppend };

    pub inline fn GetMusic(Music: Musics) MusicManagerErrors!raylib.Music {
        if (LoadedMusics == null) {
            LoadedMusics = std.AutoHashMap(Musics, raylib.Music).init(Shared.GetAllocator());
        }

        if (LoadedMusics.?.contains(Music)) {
            return LoadedMusics.?.get(Music).?;
        }

        switch (Music) {
            // Default Music is jump
            else => {
                const jump = SaveMusicToCache(Musics.Jump, ".wav", @embedFile("./Sounds/jump.wav"));
                if (jump) |s| {
                    raylib.setMusicVolume(s, 0.5);
                } else |err| {
                    Logger.Error_Formatted("Failed to set Music volumn: {}", .{err});
                }
                return jump;
            },
        }
    }

    inline fn SaveMusicToCache(key: Musics, fileType: [:0]const u8, bytes: [:0]const u8) MusicManagerErrors!raylib.Music {
        const m = raylib.loadMusicStreamFromMemory(fileType, bytes);
        LoadedMusics.?.put(key, m) catch return MusicManagerErrors.FailedToAppend;
        return m;
    }

    pub inline fn deinit() void {
        if (LoadedMusics != null) {
            LoadedMusics.?.deinit();
        }
    }
};

pub const Musics = enum {
    Unknown,
};
