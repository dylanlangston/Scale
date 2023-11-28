const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const World = @import("World.zig").World;
const Logger = @import("../Logger.zig").Logger;
const Colors = @import("../Colors.zig").Colors;

pub const Player = struct {
    Position: raylib.Rectangle,
    Velocity: raylib.Vector2,
    IsAirborne: bool,
    IsMoving: bool,
    Dead: bool,

    const Size = PlayerSize{
        .width = 5,
        .height = 8,
    };

    const widthRatio = Size.width / 100;
    const heightRatio = Size.height / 100;

    fn GetSizeX(current_screen: raylib.Rectangle) f32 {
        const new_size_x: f32 = widthRatio * current_screen.width;
        return new_size_x;
    }

    fn GetSizeY(current_screen: raylib.Rectangle) f32 {
        const new_size_y: f32 = heightRatio * current_screen.height;
        return new_size_y;
    }

    pub fn GetSize(current_screen: raylib.Rectangle) PlayerSize {
        return PlayerSize{
            .width = GetSizeX(current_screen),
            .height = GetSizeY(current_screen),
        };
    }

    fn GetPositionX(self: Player, current_screen: raylib.Rectangle, size: PlayerSize) f32 {
        if (current_screen.width != self.Position.width) {
            Logger.Debug_Formatted("Self: {}", .{self});
            Logger.Debug_Formatted("CurrentScreen: {}", .{current_screen});
            const new_position_x: f32 = self.Position.x / self.Position.width * current_screen.width;
            Logger.Debug_Formatted("OldX: {}, NewX: {}", .{ self.Position.x, new_position_x });
            return EnsureWithinBounnds(
                current_screen,
                directions.horizontal,
                new_position_x,
                size,
            );
        }
        return self.Position.x;
    }

    fn GetPositionY(self: Player, current_screen: raylib.Rectangle, size: PlayerSize) f32 {
        if (current_screen.height != self.Position.height) {
            const new_position_y: f32 = self.Position.y / self.Position.height * current_screen.height;
            return EnsureWithinBounnds(
                current_screen,
                directions.vertical,
                new_position_y,
                size,
            );
        }
        return self.Position.y;
    }

    fn GetPosition(self: Player, current_screen: raylib.Rectangle, size: PlayerSize) raylib.Rectangle {
        return raylib.Rectangle.init(
            self.GetPositionX(current_screen, size),
            self.GetPositionY(current_screen, size),
            current_screen.width,
            current_screen.height,
        );
    }

    pub fn GetPositionAbsolute(self: Player, current_screen: raylib.Rectangle, size: PlayerSize) raylib.Rectangle {
        return raylib.Rectangle.init(
            self.GetPositionX(current_screen, size),
            self.GetPositionY(current_screen, size),
            size.width,
            size.height,
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

    fn EnsureWithinBounnds(screen: raylib.Rectangle, direction: directions, f: f32, size: PlayerSize) f32 {
        switch (direction) {
            directions.left,
            directions.up,
            => {
                if (f < 0) return 0;
            },
            directions.down => {
                if (f > screen.height - size.height) return screen.height - size.height;
            },
            directions.right => {
                if (f > screen.width - size.width) return screen.width - size.width;
            },
            directions.vertical => {
                if (f < 0) return 0;
                if (f > screen.height - size.height) return screen.height - size.height;
            },
            directions.horizontal => {
                if (f < 0) return 0;
                if (f > screen.width - size.width) return screen.width - size.width;
            },
        }

        return f;
    }

    fn IsCollidingXLeft(
        originalPosition: raylib.Rectangle,
        newPosition: raylib.Rectangle,
        current_screen: raylib.Rectangle,
        size: PlayerSize,
        platformCollision: ?raylib.Rectangle,
    ) bool {
        _ = size;
        _ = current_screen;
        if (newPosition.x == 0) {
            return true;
        }

        if (platformCollision != null and originalPosition.x >= newPosition.x) {
            return true;
        }

        return false;
    }

    fn IsCollidingXRight(
        originalPosition: raylib.Rectangle,
        newPosition: raylib.Rectangle,
        current_screen: raylib.Rectangle,
        size: PlayerSize,
        platformCollision: ?raylib.Rectangle,
    ) bool {
        if (newPosition.x + size.width >= current_screen.width) {
            return true;
        }

        if (platformCollision != null and originalPosition.x <= newPosition.x) {
            return true;
        }

        return false;
    }

    fn IsCollidingYTop(
        originalPosition: raylib.Rectangle,
        newPosition: raylib.Rectangle,
        current_screen: raylib.Rectangle,
        size: PlayerSize,
        platformCollision: ?raylib.Rectangle,
    ) bool {
        _ = current_screen;
        _ = size;
        if (newPosition.y < 0) {
            return true;
        }

        if (platformCollision != null and originalPosition.y >= newPosition.y) {
            return true;
        }

        return false;
    }

    fn IsCollidingYBottom(
        originalPosition: raylib.Rectangle,
        newPosition: raylib.Rectangle,
        current_screen: raylib.Rectangle,
        size: PlayerSize,
        platformCollision: ?raylib.Rectangle,
    ) bool {
        _ = size;
        _ = current_screen;
        // if (newPosition.y + size.height >= current_screen.height) {
        //     return true;
        // }

        if (platformCollision != null and originalPosition.y <= newPosition.y) {
            return true;
        }

        return false;
    }

    pub fn UpdatePosition(self: Player, yOffset: f32, current_screen: raylib.Rectangle) Player {
        const playerSize = Player.GetSize(current_screen);

        const friction = if (self.IsAirborne)
            (FRICTION_AIR * raylib.getFrameTime())
        else
            (FRICTION_GROUND * raylib.getFrameTime());

        const new_VelocityY = if (!self.IsAirborne) 0 else (self.Velocity.y - (GRAVITY * raylib.getFrameTime()));

        const new_VelocityX: f32 = if (self.Velocity.x > 0)
            (@max(self.Velocity.x - friction, 0))
        else
            (@min(self.Velocity.x + friction, 0));

        var newVelocity = raylib.Vector2.init(
            new_VelocityX,
            new_VelocityY,
        );
        const originalPosition: raylib.Rectangle = self.GetPosition(current_screen, playerSize);
        var newPosition: raylib.Rectangle = raylib.Rectangle.init(
            originalPosition.x,
            originalPosition.y + yOffset,
            originalPosition.width,
            originalPosition.height,
        );
        var newIsAirborne: bool = self.IsAirborne;
        var newIsMoving: bool = self.IsMoving;
        const newDead: bool = newPosition.y + playerSize.height >= current_screen.height;

        if (self.IsMoving) {
            const new_x = newPosition.x - (playerSize.width * newVelocity.x * raylib.getFrameTime());

            newPosition = raylib.Rectangle.init(
                new_x,
                newPosition.y,
                newPosition.width,
                newPosition.height,
            );

            if (newVelocity.x == 0) {
                newIsMoving = false;
            }
        }

        var collideY: bool = false;

        if (self.IsAirborne) {
            const new_y = newPosition.y - (playerSize.height * newVelocity.y * raylib.getFrameTime());

            newPosition = raylib.Rectangle.init(
                newPosition.x,
                new_y,
                newPosition.width,
                newPosition.height,
            );

            const absolutePosition = raylib.Rectangle.init(
                newPosition.x,
                newPosition.y,
                playerSize.width,
                playerSize.height,
            );
            const platformCollision = World.CheckForPlatformCollision(absolutePosition, current_screen);

            if (IsCollidingYTop(originalPosition, newPosition, current_screen, playerSize, platformCollision)) {
                collideY = true;
                newVelocity = raylib.Vector2.init(
                    newVelocity.x,
                    -1,
                );

                newPosition = raylib.Rectangle.init(
                    newPosition.x,
                    if (platformCollision == null) (newPosition.y) else (platformCollision.?.y + platformCollision.?.height),
                    newPosition.width,
                    newPosition.height,
                );
            } else if (IsCollidingYBottom(originalPosition, newPosition, current_screen, playerSize, platformCollision)) {
                collideY = true;
                newIsAirborne = false;

                newVelocity = raylib.Vector2.init(
                    newVelocity.x,
                    0,
                );

                newPosition = raylib.Rectangle.init(
                    newPosition.x,
                    if (platformCollision == null) (newPosition.y) else (platformCollision.?.y - playerSize.height),
                    newPosition.width,
                    newPosition.height,
                );
            }
        }
        //Falling
        else if (!self.IsAirborne and self.IsMoving) {
            const absolutePosition = raylib.Rectangle.init(
                newPosition.x,
                newPosition.y + MOVE_MAX,
                playerSize.width,
                playerSize.height,
            );
            const platformCollision = World.CheckForPlatformCollision(absolutePosition, current_screen);

            if (platformCollision == null and (newPosition.y + playerSize.height) < current_screen.height) {
                newIsAirborne = true;
                newVelocity = raylib.Vector2.init(
                    newVelocity.x,
                    -1,
                );
            }
        }

        if (!collideY) {
            const absolutePosition = raylib.Rectangle.init(
                newPosition.x,
                newPosition.y,
                playerSize.width,
                playerSize.height,
            );
            const platformCollision = World.CheckForPlatformCollision(absolutePosition, current_screen);

            if (IsCollidingXLeft(originalPosition, newPosition, current_screen, playerSize, platformCollision)) {
                newIsMoving = false;
                newIsAirborne = true;

                newVelocity = raylib.Vector2.init(
                    0,
                    newVelocity.y,
                );

                newPosition = raylib.Rectangle.init(
                    if (platformCollision == null) (newPosition.x) else (platformCollision.?.x + platformCollision.?.width + MOVE_MAX),
                    newPosition.y,
                    newPosition.width,
                    newPosition.height,
                );
            } else if (IsCollidingXRight(originalPosition, newPosition, current_screen, playerSize, platformCollision)) {
                newIsMoving = false;
                newIsAirborne = true;

                newVelocity = raylib.Vector2.init(
                    0,
                    newVelocity.y,
                );

                newPosition = raylib.Rectangle.init(
                    if (platformCollision == null) (newPosition.x) else (platformCollision.?.x - playerSize.width - MOVE_MAX),
                    newPosition.y,
                    newPosition.width,
                    newPosition.height,
                );
            }
        }

        const p = Player{
            .Position = raylib.Rectangle.init(
                EnsureWithinBounnds(
                    current_screen,
                    directions.horizontal,
                    newPosition.x,
                    playerSize,
                ),
                EnsureWithinBounnds(
                    current_screen,
                    directions.vertical,
                    newPosition.y,
                    playerSize,
                ),
                newPosition.width,
                newPosition.height,
            ),
            .Velocity = newVelocity,
            .IsAirborne = newIsAirborne,
            .IsMoving = newIsMoving,
            .Dead = newDead,
        };
        return p;
    }

    const GRAVITY: f32 = 50;
    const JUMP_FORCE: f32 = 25.0;

    pub fn Jump(self: Player, current_screen: raylib.Rectangle) Player {
        if (self.IsAirborne and self.IsMoving) {
            return self;
        } else if (self.IsAirborne) {
            const playerSize = Player.GetSize(current_screen);
            if (IsCollidingXLeft(undefined, self.Position, current_screen, playerSize, null)) {
                return Player{
                    .Position = self.Position,
                    .Velocity = raylib.Vector2.init(
                        -MOVE_MAX,
                        self.Velocity.y,
                    ),
                    .IsAirborne = true,
                    .IsMoving = true,
                    .Dead = self.Dead,
                };
            } else if (IsCollidingXRight(undefined, self.Position, current_screen, playerSize, null)) {
                return Player{
                    .Position = self.Position,
                    .Velocity = raylib.Vector2.init(
                        MOVE_MAX,
                        self.Velocity.y,
                    ),
                    .IsAirborne = true,
                    .IsMoving = true,
                    .Dead = self.Dead,
                };
            } else {
                return self;
            }
        }

        return Player{
            .Position = raylib.Rectangle.init(
                self.Position.x + 1,
                self.Position.y,
                self.Position.width,
                self.Position.height,
            ),
            .Velocity = raylib.Vector2.init(
                self.Velocity.x,
                JUMP_FORCE,
            ),
            .IsAirborne = true,
            .IsMoving = self.IsMoving,
            .Dead = self.Dead,
        };
    }

    const FRICTION_GROUND: f32 = 40;
    const FRICTION_AIR: f32 = 8;
    const MOVE_MAX: f32 = 10;

    pub fn MoveDown(self: Player) Player {
        if (self.IsAirborne) return self;

        return Player{
            .Position = self.Position,
            .Velocity = self.Velocity,
            .IsAirborne = self.IsAirborne,
            .IsMoving = true,
        };
    }

    pub fn MoveLeft(self: Player) Player {
        if (self.IsAirborne) {
            return Player{
                .Position = self.Position,
                .Velocity = raylib.Vector2.init(
                    @max(self.Velocity.x + raylib.getFrameTime(), 0),
                    self.Velocity.y,
                ),
                .IsAirborne = self.IsAirborne,
                .IsMoving = true,
                .Dead = self.Dead,
            };
        }

        return Player{
            .Position = self.Position,
            .Velocity = raylib.Vector2.init(
                MOVE_MAX,
                self.Velocity.y,
            ),
            .IsAirborne = self.IsAirborne,
            .IsMoving = true,
            .Dead = self.Dead,
        };
    }

    pub fn MoveRight(self: Player) Player {
        if (self.IsAirborne) {
            return Player{
                .Position = self.Position,
                .Velocity = raylib.Vector2.init(
                    @min(self.Velocity.x - raylib.getFrameTime(), 0),
                    self.Velocity.y,
                ),
                .IsAirborne = self.IsAirborne,
                .IsMoving = true,
                .Dead = self.Dead,
            };
        }

        return Player{
            .Position = self.Position,
            .Velocity = raylib.Vector2.init(
                -MOVE_MAX,
                self.Velocity.y,
            ),
            .IsAirborne = self.IsAirborne,
            .IsMoving = true,
            .Dead = self.Dead,
        };
    }

    pub fn Draw(self: Player, current_screen: raylib.Rectangle) void {
        const playerSize = GetSize(current_screen);
        const playerPosition = self.GetPosition(current_screen, playerSize);
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
