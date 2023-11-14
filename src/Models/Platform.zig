const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const World = @import("World.zig").World;

pub const Platform = struct {
    Position: raylib.Rectangle,
    Size: PlatformSize,

    fn GetSizeX(self: Platform, current_screen: raylib.Rectangle) f32 {
        const new_position_x: f32 = self.Size.width / 100 * current_screen.width;
        return new_position_x;
    }

    fn GetSizeY(self: Platform, current_screen: raylib.Rectangle) f32 {
        const new_position_x: f32 = self.Size.height / 100 * current_screen.width;
        return new_position_x;
    }

    pub fn GetSize(self: Platform) Platform {
        const current_screen = World.GetCurrentScreen();
        return PlatformSize{
            .width = self.GetSizeX(current_screen),
            .height = self.GetSizeY(current_screen),
        };
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

    fn GetPosition(self: Platform, current_screen: raylib.Rectangle) raylib.Rectangle {
        return raylib.Rectangle.init(
            self.GetPositionX(current_screen),
            self.GetPositionY(current_screen),
            current_screen.width,
            current_screen.height,
        );
    }

    pub fn UpdatePosition(self: Platform) Platform {
        const current_screen = World.GetCurrentScreen();
        return Platform{
            .Position = self.GetPosition(current_screen),
        };
    }
};

pub const PlatformSize = struct {
    width: f32,
    height: f32,
};