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
            else => {
                return raylib.Sound{};
            },
        }
    }

    pub inline fn deinit() void {
        if (LoadedSounds != null) {
            LoadedSounds.?.deinit();
        }
    }
};

pub const Sounds = enum {};
