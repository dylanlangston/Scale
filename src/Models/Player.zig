const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const World = @import("World.zig").World;
const Logger = @import("../Logger.zig").Logger;
const Colors = @import("../Colors.zig").Colors;

pub const Player = struct {
    Position: raylib.Rectangle,
    Velocity: raylib.Vector2,
    IsJumping: bool,
    IsMoving: bool,

    const Size = PlayerSize{
        .width = 5,
        .height = 8,
    };

    const widthRatio = Size.width / 100;
    const heightRatio = Size.height / 100;

    fn GetSizeX(current_screen: raylib.Rectangle) f32 {
        const new_position_x: f32 = widthRatio * current_screen.width;
        return new_position_x;
    }

    fn GetSizeY(current_screen: raylib.Rectangle) f32 {
        const new_position_y: f32 = heightRatio * current_screen.height;
        return new_position_y;
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
            const new_position_x: f32 = (self.Position.x) / self.Position.width * current_screen.width;
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
            const new_position_y: f32 = (self.Position.y) / self.Position.height * current_screen.height;
            return self.EnsureWithinBounnds(
                directions.vertical,
                new_position_y,
                size,
            );
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

    fn IsCollidingX(position: raylib.Rectangle, current_screen: raylib.Rectangle, size: PlayerSize) bool {
        if (position.x == 0) {
            Logger.Debug_Formatted("Collide: {}", .{std.time.nanoTimestamp()});
            return true;
        } else if (position.x + size.width >= current_screen.width) {
            Logger.Debug_Formatted("Collide: {}", .{std.time.nanoTimestamp()});
            return true;
        }
        return false;
    }

    fn IsCollidingY(position: raylib.Rectangle, current_screen: raylib.Rectangle, size: PlayerSize) bool {
        if (position.y + size.height >= current_screen.height) {
            Logger.Debug_Formatted("Collide: {}", .{std.time.nanoTimestamp()});
            return true;
        }
        return false;
    }

    pub fn UpdatePosition(self: Player) Player {
        const current_screen = World.GetCurrentScreenSize();
        const playerSize = Player.GetSize();

        const friction = if (self.IsJumping)
            (FRICTION_AIR * raylib.getFrameTime())
        else
            (FRICTION_GROUND * raylib.getFrameTime());

        const new_VelocityY = if (!self.IsJumping) 0 else (self.Velocity.y - (GRAVITY * raylib.getFrameTime()));

        const new_VelocityX: f32 = if (self.Velocity.x > 0)
            (@max(self.Velocity.x - friction, 0))
        else
            (@min(self.Velocity.x + friction, 0));

        const newVelocity = raylib.Vector2.init(
            new_VelocityX,
            new_VelocityY,
        );
        var newPosition: raylib.Rectangle = self.Position;
        var newIsJumping: bool = self.IsJumping;
        var newIsMoving: bool = self.IsMoving;

        if (self.IsMoving) {
            const new_x = self.EnsureWithinBounnds(
                directions.horizontal,
                (newPosition.x - (playerSize.width * newVelocity.x * raylib.getFrameTime())),
                playerSize,
            );

            newPosition = raylib.Rectangle.init(
                new_x,
                newPosition.y,
                newPosition.width,
                newPosition.height,
            );

            if (new_VelocityX == 0) {
                Logger.Debug_Formatted("Stop Moving: {}", .{std.time.nanoTimestamp()});
                newIsMoving = false;
            } else if (IsCollidingX(newPosition, current_screen, playerSize)) {
                Logger.Debug_Formatted("Stop Moving: {}", .{std.time.nanoTimestamp()});
                newIsMoving = false;
            }
        }

        if (self.IsJumping) {
            const new_y = self.EnsureWithinBounnds(
                directions.vertical,
                (newPosition.y - (playerSize.height * newVelocity.y * raylib.getFrameTime())),
                playerSize,
            );

            newPosition = raylib.Rectangle.init(
                newPosition.x,
                new_y,
                newPosition.width,
                newPosition.height,
            );

            newIsJumping = !IsCollidingY(newPosition, current_screen, playerSize);
        }

        return Player{
            .Position = newPosition,
            .Velocity = newVelocity,
            .IsJumping = newIsJumping,
            .IsMoving = newIsMoving,
        };
    }

    const GRAVITY: f32 = 50;
    const JUMP_FORCE: f32 = 25.0;

    pub fn Jump(self: Player) Player {
        if (self.IsJumping and self.IsMoving) {
            return self;
        } else if (self.IsJumping) {
            const current_screen = World.GetCurrentScreenSize();
            const playerSize = Player.GetSize();
            if (IsCollidingX(self.Position, current_screen, playerSize)) {
                return Player{
                    .Position = self.Position,
                    .Velocity = raylib.Vector2.init(
                        if (self.Position.x == 0) -MOVE_MAX else MOVE_MAX,
                        self.Velocity.y,
                    ),
                    .IsJumping = true,
                    .IsMoving = true,
                };
            } else {
                return self;
            }
        }

        Logger.Debug_Formatted("Jump: {}", .{std.time.nanoTimestamp()});

        return Player{
            .Position = self.Position,
            .Velocity = raylib.Vector2.init(
                self.Velocity.x,
                JUMP_FORCE,
            ),
            .IsJumping = true,
            .IsMoving = self.IsMoving,
        };
    }

    const FRICTION_GROUND: f32 = 40;
    const FRICTION_AIR: f32 = 8;
    const MOVE_MAX: f32 = 10;

    pub fn MoveDown(self: Player) Player {
        if (self.IsJumping) return self;

        Logger.Debug_Formatted("Move Down: {}", .{std.time.nanoTimestamp()});

        return Player{
            .Position = self.Position,
            .Velocity = self.Velocity,
            .IsJumping = self.IsJumping,
            .IsMoving = true,
        };
    }

    pub fn MoveLeft(self: Player) Player {
        if (self.IsJumping) {
            return Player{
                .Position = self.Position,
                .Velocity = raylib.Vector2.init(
                    @max(self.Velocity.x + raylib.getFrameTime(), 0),
                    self.Velocity.y,
                ),
                .IsJumping = self.IsJumping,
                .IsMoving = true,
            };
        }

        Logger.Debug_Formatted("Move Left: {}", .{std.time.nanoTimestamp()});

        return Player{
            .Position = self.Position,
            .Velocity = raylib.Vector2.init(
                MOVE_MAX,
                self.Velocity.y,
            ),
            .IsJumping = self.IsJumping,
            .IsMoving = true,
        };
    }

    pub fn MoveRight(self: Player) Player {
        if (self.IsJumping) {
            return Player{
                .Position = self.Position,
                .Velocity = raylib.Vector2.init(
                    @min(self.Velocity.x - raylib.getFrameTime(), 0),
                    self.Velocity.y,
                ),
                .IsJumping = self.IsJumping,
                .IsMoving = true,
            };
        }

        Logger.Debug_Formatted("Move Right: {}", .{std.time.nanoTimestamp()});

        return Player{
            .Position = self.Position,
            .Velocity = raylib.Vector2.init(
                -MOVE_MAX,
                self.Velocity.y,
            ),
            .IsJumping = self.IsJumping,
            .IsMoving = true,
        };
    }

    pub fn Draw(self: Player) void {
        const playerPosition = self.Position;
        const playerSize = GetSize();
        raylib.drawRectangle(
            @intFromFloat(playerPosition.x),
            @intFromFloat(playerPosition.y),
            @intFromFloat(playerSize.width),
            @intFromFloat(playerSize.height),
            Colors.Red.Base,
        );
    }
};

pub const PlayerSize = struct {
    width: f32,
    height: f32,
};
