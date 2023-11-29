const std = @import("std");
const raylib = @import("raylib");
const Shared = @import("Helpers.zig").Shared;

pub const SoundManager = struct {
    var LoadedSounds: ?std.AutoHashMap(Sounds, raylib.Sound) = null;

    const SoundManagerErrors = error{FailedToAppend};

    pub inline fn GetSound(sound: Sounds) SoundManagerErrors!raylib.Sound {
        if (LoadedSounds == null) {
            LoadedSounds = std.AutoHashMap(Sounds, raylib.Font).init(Shared.GetAllocator());
        }

        if (LoadedSounds.?.contains(sound)) {
            return LoadedSounds.?.get(sound).?;
        }

        switch (sound) {
            Sounds.Jump => {
                return SaveSoundToCache(Sounds.Jump, ".wav", @embedFile("./Sounds/jump.wav"));
            },
            else => {
                return raylib.Sound{};
            },
        }
    }

    inline fn SaveSoundToCache(key: Sounds, fileType: [:0]const u8, bytes: [:0]const u8) SoundManagerErrors!raylib.Texture {
        const w = raylib.loadWaveFromMemory(fileType, bytes);
        const s = raylib.loadSoundFromWave(w);
        LoadedSounds.?.put(key, s) catch return SoundManagerErrors.FailedToAppend;
        return s;
    }

    pub inline fn deinit() void {
        if (LoadedSounds != null) {
            LoadedSounds.?.deinit();
        }
    }
};

pub const Sounds = enum {
    Jump,
};
