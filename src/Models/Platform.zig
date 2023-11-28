const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const World = @import("World.zig").World;
const Logger = @import("../Logger.zig").Logger;
const Colors = @import("../Colors.zig").Colors;

pub const Platform = struct {
    Position: raylib.Rectangle,
    Size: PlatformSize,

    fn GetSizeX(self: Platform, current_screen: raylib.Rectangle) f32 {
        const new_size_x: f32 = self.Size.width / 100 * current_screen.width;
        return new_size_x;
    }

    fn GetSizeY(self: Platform, current_screen: raylib.Rectangle) f32 {
        const new_size_y: f32 = self.Size.height / 100 * current_screen.height;
        return new_size_y;
    }

    pub fn GetSize(self: Platform, current_screen: raylib.Rectangle) PlatformSize {
        return PlatformSize{
            .width = self.GetSizeX(current_screen),
            .height = self.GetSizeY(current_screen),
        };
    }

    pub fn GetCollision(self: Platform, current_screen: raylib.Rectangle, otherItem: raylib.Rectangle) raylib.Rectangle {
        const position = self.GetPositionAbsolute(current_screen);
        return raylib.getCollisionRec(position, otherItem);
    }

    fn GetPositionX(self: Platform, current_screen: raylib.Rectangle) f32 {
        if (current_screen.width != self.Position.width) {
            const new_position_x: f32 = self.Position.x / self.Position.width * current_screen.width;
            return new_position_x;
        }
        return self.Position.x;
    }

    fn GetPositionY(self: Platform, current_screen: raylib.Rectangle) f32 {
        if (current_screen.height != self.Position.height) {
            const new_position_y: f32 = self.Position.y / self.Position.height * current_screen.height;
            return new_position_y;
        }
        return self.Position.y;
    }

    fn GetPosition(self: Platform, yOffset: f32, current_screen: raylib.Rectangle) raylib.Rectangle {
        return raylib.Rectangle.init(
            self.GetPositionX(current_screen),
            self.GetPositionY(current_screen) + yOffset,
            current_screen.width,
            current_screen.height,
        );
    }

    pub fn GetPositionAbsolute(self: Platform, current_screen: raylib.Rectangle) raylib.Rectangle {
        return raylib.Rectangle.init(
            self.GetPositionX(current_screen),
            self.GetPositionY(current_screen),
            self.GetSizeX(current_screen),
            self.GetSizeY(current_screen),
        );
    }

    pub fn UpdatePosition(self: Platform, yOffset: f32, current_screen: raylib.Rectangle) Platform {
        return Platform{
            .Position = self.GetPosition(yOffset, current_screen),
            .Size = self.Size,
        };
    }

    pub fn Draw(self: Platform, current_screen: raylib.Rectangle) void {
        const platformPosition = self.Position;
        const platformSize = self.GetSize(current_screen);
        raylib.drawRectangle(
            @intFromFloat(platformPosition.x),
            @intFromFloat(platformPosition.y),
            @intFromFloat(platformSize.width),
            @intFromFloat(platformSize.height),
            Colors.Miyazaki.Yellow,
        );
    }
};

pub const PlatformSize = struct {
    width: f32,
    height: f32,
};
