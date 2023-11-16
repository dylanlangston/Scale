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
            return self.EnsureWithinBounnds(
                directions.horizontal,
                new_position_x,
                Player.GetSize(),
            );
        }
        return self.EnsureWithinBounnds(
            directions.horizontal,
            self.Position.x,
            Player.GetSize(),
        );
    }

    fn GetPositionY(self: Player, current_screen: raylib.Rectangle) f32 {
        const size = Player.GetSize();
        if (current_screen.height != self.Position.height) {
            const new_position_y: f32 = self.Position.y / self.Position.height * current_screen.height;
            return self.EnsureWithinBounnds(directions.vertical, new_position_y, size);
        }
        return self.EnsureWithinBounnds(
            directions.vertical,
            self.Position.y,
            size,
        );
    }

    fn GetPosition(self: Player, current_screen: raylib.Rectangle) raylib.Rectangle {
        return raylib.Rectangle.init(
            self.GetPositionX(current_screen),
            self.GetPositionY(current_screen),
            current_screen.width,
            current_screen.height,
        );
    }

    const directions = enum {
        up,
        down,
        left,
        right,
        vertical,
        horizontal,
    };

    fn EnsureWithinBounnds(self: Player, direction: directions, f: f32, size: PlayerSize) f32 {
        switch (direction) {
            directions.left,
            directions.up,
            => {
                if (f < 0) return 0;
            },
            directions.down => {
                if (f > self.Position.height - size.height) return self.Position.height - size.height;
            },
            directions.right => {
                if (f > self.Position.width - size.width) return self.Position.width - size.width;
            },
            directions.vertical => {
                if (f < 0) return 0;
                if (f > self.Position.height - size.height) return self.Position.height - size.height;
            },
            directions.horizontal => {
                if (f < 0) return 0;
                if (f > self.Position.width - size.width) return self.Position.width - size.width;
            },
        }

        return f;
    }

    pub fn UpdatePosition(self: Player) Player {
        const current_screen = World.GetCurrentScreenSize();
        return Player{
            .Position = self.GetPosition(current_screen),
        };
    }

    pub fn MoveUp(self: Player, move_mod: f32) Player {
        const playerSize = Player.GetSize();
        const new_y = self.EnsureWithinBounnds(
            directions.up,
            (self.Position.y - (playerSize.height / move_mod)),
            playerSize,
        );

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
        const new_y = self.EnsureWithinBounnds(
            directions.down,
            (self.Position.y + (playerSize.height / move_mod)),
            playerSize,
        );

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
        const new_x = self.EnsureWithinBounnds(
            directions.left,
            (self.Position.x - (playerSize.width / move_mod)),
            playerSize,
        );

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
        const new_x = self.EnsureWithinBounnds(
            directions.right,
            (self.Position.x + (playerSize.width / move_mod)),
            playerSize,
        );

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
