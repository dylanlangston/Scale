const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const World = @import("World.zig").World;
const Logger = @import("../Logger.zig").Logger;
const Colors = @import("../Colors.zig").Colors;
const Shared = @import("../Helpers.zig").Shared;

pub const Platform = struct {
    Position: raylib.Rectangle,
    Size: PlatformSize,

    inline fn GetSizeX(self: Platform, current_screen: raylib.Rectangle) f32 {
        const new_size_x: f32 = self.Size.width / 100 * current_screen.width;
        return new_size_x;
    }

    inline fn GetSizeY(self: Platform, current_screen: raylib.Rectangle) f32 {
        const new_size_y: f32 = self.Size.height / 100 * current_screen.height;
        return new_size_y;
    }

    pub inline fn GetSize(self: Platform, current_screen: raylib.Rectangle) PlatformSize {
        return PlatformSize{
            .width = self.GetSizeX(current_screen),
            .height = self.GetSizeY(current_screen),
        };
    }

    pub inline fn GetCollision(self: Platform, current_screen: raylib.Rectangle, otherItem: raylib.Rectangle) raylib.Rectangle {
        const position = self.GetPositionAbsolute(current_screen);
        return raylib.getCollisionRec(position, otherItem);
    }

    inline fn GetPositionX(self: Platform, current_screen: raylib.Rectangle) f32 {
        if (current_screen.width != self.Position.width) {
            const new_position_x: f32 = self.Position.x / self.Position.width * current_screen.width;
            return new_position_x;
        }
        return self.Position.x;
    }

    inline fn GetPositionY(self: Platform, current_screen: raylib.Rectangle) f32 {
        if (current_screen.height != self.Position.height) {
            const new_position_y: f32 = self.Position.y / self.Position.height * current_screen.height;
            return new_position_y;
        }
        return self.Position.y;
    }

    inline fn GetPosition(self: Platform, yOffset: f32, current_screen: raylib.Rectangle) raylib.Rectangle {
        return raylib.Rectangle.init(
            self.GetPositionX(current_screen),
            self.GetPositionY(current_screen) + yOffset,
            current_screen.width,
            current_screen.height,
        );
    }

    pub inline fn GetPositionAbsolute(self: Platform, current_screen: raylib.Rectangle) raylib.Rectangle {
        return raylib.Rectangle.init(
            self.GetPositionX(current_screen),
            self.GetPositionY(current_screen),
            self.GetSizeX(current_screen),
            self.GetSizeY(current_screen),
        );
    }

    pub inline fn UpdatePosition(self: Platform, yOffset: f32, current_screen: raylib.Rectangle) Platform {
        return Platform{
            .Position = self.GetPosition(yOffset, current_screen),
            .Size = self.Size,
        };
    }

    pub inline fn Draw(self: Platform, current_screen: raylib.Rectangle) void {
        const platform = Shared.GetTexture(.Platform);
        const platform_rect = raylib.Rectangle.init(
            0,
            0,
            @floatFromInt(platform.width),
            @floatFromInt(platform.height),
        );
        const platformPosition = self.GetPositionAbsolute(current_screen);
        raylib.drawTexturePro(
            platform,
            platform_rect,
            platformPosition,
            raylib.Vector2.init(0, 0),
            0,
            Colors.Tone.Light,
        );
        // raylib.drawRectangle(
        //     @intFromFloat(platformPosition.x),
        //     @intFromFloat(platformPosition.y),
        //     @intFromFloat(platformSize.width),
        //     @intFromFloat(platformSize.height),
        //     Colors.Miyazaki.Yellow,
        // );
    }

    pub inline fn GetNewPlatformsFromPattern(pattern: PlatformPattern, current_screen: raylib.Rectangle) std.ArrayList(Platform) {
        var platforms = std.ArrayList(Platform).init(Shared.GetAllocator());

        for (0..pattern.number) |i| {
            const padding = pattern.padding[i] / 100 * current_screen.width;
            const height = pattern.sizes[i].height / 100 * current_screen.height;
            platforms.append(Platform{
                .Position = raylib.Rectangle.init(
                    padding,
                    -(height * 2),
                    current_screen.width,
                    current_screen.height,
                ),
                .Size = pattern.sizes[i],
            }) catch {
                Logger.Error("Failed to create new platform");
            };
        }

        return platforms;
    }
};

pub const PlatformSize = struct {
    width: f32,
    height: f32,
};

pub const PlatformPattern = struct {
    number: usize,
    sizes: []const PlatformSize,
    padding: []const f32,

    // pub fn Init(number: usize, sizes: []const PlatformSize, padding: []const f32) PlatformPattern {
    //     return PlatformPattern{
    //         .number = number,
    //         .sizes = sizes,
    //         .padding = padding,
    //     };
    // }

    pub inline fn LoadPatternsFromFile(file: [:0]const u8) []PlatformPattern {
        const platformPatterns = std.json.parseFromSlice([]PlatformPattern, Shared.GetAllocator(), file, .{}) catch {
            Logger.Error("Failed to load platform patterns!");
            return undefined;
        };
        return platformPatterns.value;
    }
};
