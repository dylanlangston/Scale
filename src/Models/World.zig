const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const PlayerModel = @import("../Models/Player.zig").Player;
const PlatformModel = @import("../Models/Platform.zig").Platform;
const Shared = @import("../Helpers.zig").Shared;
const Logger = @import("../Logger.zig").Logger;

pub const World = struct {
    pub var Player: PlayerModel = undefined;
    pub var Platforms: std.ArrayList(PlatformModel) = undefined;

    pub fn Init() !void {
        Deinit();

        const screenWidth: f32 = @floatFromInt(raylib.getScreenWidth());
        const screenHeight: f32 = @floatFromInt(raylib.getScreenHeight());
        const PlayerSize = PlayerModel.GetSize(raylib.Rectangle.init(0, 0, screenHeight, screenWidth));

        Player = PlayerModel{
            .Position = raylib.Rectangle.init(
                (screenWidth - PlayerSize.width) / 2,
                screenHeight - PlayerSize.height,
                screenWidth,
                screenHeight,
            ),
            .Velocity = raylib.Vector2.init(0, 20),
            .IsJumping = true,
            .IsMoving = false,
        };

        Platforms = std.ArrayList(PlatformModel).init(Shared.GetAllocator());
        try Platforms.append(PlatformModel{
            .Position = raylib.Rectangle.init(
                screenWidth / 4,
                screenHeight / 3 * 2,
                screenWidth,
                screenHeight,
            ),
            .Size = .{
                .height = 2,
                .width = 50,
            },
        });
    }

    pub fn CheckForPlatformCollision(item: raylib.Rectangle, current_screen: raylib.Rectangle) ?raylib.Rectangle {
        for (Platforms.items) |platform| {
            const collision = platform.GetCollision(current_screen, item);
            if (collision.width > 1) {
                return collision;
            }
            if (collision.height > 1) {
                return collision;
            }
        }
        return null;
    }

    pub fn UpdatePlatforms(current_screen: raylib.Rectangle) std.ArrayList(PlatformModel) {
        for (Platforms.items, 0..) |platform, index| {
            Platforms.replaceRange(
                index,
                1,
                &[1]PlatformModel{
                    platform.UpdatePosition(current_screen),
                },
            ) catch {
                Logger.Info("Failed to update platform!");
            };
        }
        return Platforms;
    }

    pub fn Deinit() void {
        Platforms.clearAndFree();
    }

    pub fn GetCurrentScreenSize() raylib.Rectangle {
        const current_screen = raylib.Rectangle.init(
            0,
            0,
            @floatFromInt(raylib.getScreenWidth()),
            @floatFromInt(raylib.getScreenHeight()),
        );
        return current_screen;
    }
};
