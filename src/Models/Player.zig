const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const World = @import("World.zig").World;

pub const Player = struct {
    Position: raylib.Rectangle,

    const Size = PlayerSize{
        .width = 5,
        .height = 8,
    };

    fn GetSizeX(current_screen: raylib.Rectangle) f32 {
        const new_position_x: f32 = Size.width / 100 * current_screen.width;
        return new_position_x;
    }

    fn GetSizeY(current_screen: raylib.Rectangle) f32 {
        const new_position_x: f32 = Size.height / 100 * current_screen.height;
        return new_position_x;
    }

    pub fn GetSize() PlayerSize {
        const current_screen = World.GetCurrentScreenSize();
        return PlayerSize{
            .width = GetSizeX(current_screen),
            .height = GetSizeY(current_screen),
        };
    }

    fn GetPositionX(self: Player, current_screen: raylib.Rectangle) f32 {
        if (current_screen.width != self.Position.width) {
            const new_position_x: f32 = self.Position.x / self.Position.width * current_screen.width;
            return new_position_x;
        }
        return self.Position.x;
    }

    fn GetPositionY(self: Player, current_screen: raylib.Rectangle) f32 {
        if (current_screen.height != self.Position.height) {
            const new_position_y: f32 = self.Position.y / self.Position.height * current_screen.height;
            return new_position_y;
        }
        return self.Position.y;
    }

    fn GetPosition(self: Player, current_screen: raylib.Rectangle) raylib.Rectangle {
        return raylib.Rectangle.init(
            self.GetPositionX(current_screen),
            self.GetPositionY(current_screen),
            current_screen.width,
            current_screen.height,
        );
    }

    pub fn UpdatePosition(self: Player) Player {
        const current_screen = World.GetCurrentScreenSize();
        return Player{
            .Position = self.GetPosition(current_screen),
        };
    }

    pub fn MoveUp(self: Player, move_mod: f32) Player {
        const playerSize = Player.GetSize();
        var new_y = self.Position.y - (playerSize.height / move_mod);
        if (new_y < 0) new_y = 0;

        return Player{
            .Position = raylib.Rectangle.init(
                self.Position.x,
                new_y,
                self.Position.width,
                self.Position.height,
            ),
        };
    }

    pub fn MoveDown(self: Player, move_mod: f32) Player {
        const playerSize = Player.GetSize();
        var new_y = self.Position.y + (playerSize.height / move_mod);
        const size = Player.GetSize();
        if (new_y > self.Position.height - size.height) new_y = self.Position.height - size.height;

        return Player{
            .Position = raylib.Rectangle.init(
                self.Position.x,
                new_y,
                self.Position.width,
                self.Position.height,
            ),
        };
    }

    pub fn MoveLeft(self: Player, move_mod: f32) Player {
        const playerSize = Player.GetSize();
        var new_x = self.Position.x - (playerSize.width / move_mod);
        if (new_x < 0) new_x = 0;

        return Player{
            .Position = raylib.Rectangle.init(
                new_x,
                self.Position.y,
                self.Position.width,
                self.Position.height,
            ),
        };
    }

    pub fn MoveRight(self: Player, move_mod: f32) Player {
        const playerSize = Player.GetSize();
        var new_x = self.Position.x + (playerSize.width / move_mod);
        const size = Player.GetSize();
        if (new_x > self.Position.width - size.width) new_x = self.Position.width - size.width;

        return Player{
            .Position = raylib.Rectangle.init(
                new_x,
                self.Position.y,
                self.Position.width,
                self.Position.height,
            ),
        };
    }
};

pub const PlayerSize = struct {
    width: f32,
    height: f32,
};
