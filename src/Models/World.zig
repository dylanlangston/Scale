const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const PlayerModel = @import("../Models/Player.zig").Player;
const PlatformModel = @import("../Models/Platform.zig").Platform;
const PlatformPattern = @import("../Models/Platform.zig").PlatformPattern;
const Shared = @import("../Helpers.zig").Shared;
const Logger = @import("../Logger.zig").Logger;
const RndGen = std.rand.DefaultPrng;

pub const World = struct {
    pub var Player: PlayerModel = undefined;
    pub var Platforms: std.ArrayList(PlatformModel) = undefined;
    var PlatformPatterns: ?[]PlatformPattern = null;

    var c: usize = 0;
    inline fn GetPattern() PlatformPattern {
        const pattern = PlatformPatterns.?[c];
        if (c + 1 >= PlatformPatterns.?.len) {
            c = 0;
        } else {
            c += 1;
        }
        return pattern;
    }

    pub inline fn Init() !void {
        Deinit();

        if (PlatformPatterns == null) {
            PlatformPatterns = PlatformPattern.LoadPatternsFromFile(@embedFile("../platform-patterns.json"));
        }

        //rnd = RndGen.init(@intCast(std.time.nanoTimestamp()));

        const screenWidth: f32 = @floatFromInt(raylib.getScreenWidth());
        const screenHeight: f32 = @floatFromInt(raylib.getScreenHeight());
        const PlayerSize = PlayerModel.GetSize(raylib.Rectangle.init(0, 0, screenHeight, screenWidth));

        Player = PlayerModel{
            .Position = raylib.Rectangle.init(
                (screenWidth - PlayerSize.width) / 2,
                (screenHeight - PlayerSize.height) / 2,
                screenWidth,
                screenHeight,
            ),
            .Velocity = raylib.Vector2.init(0, 20),
            .IsAirborne = true,
            .IsMoving = false,
            .Dead = false,
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
        try Platforms.append(PlatformModel{
            .Position = raylib.Rectangle.init(
                0,
                screenHeight / 3,
                screenWidth,
                screenHeight,
            ),
            .Size = .{
                .height = 2,
                .width = 25,
            },
        });
        try Platforms.append(PlatformModel{
            .Position = raylib.Rectangle.init(
                screenWidth / 4 * 3,
                screenHeight / 3,
                screenWidth,
                screenHeight,
            ),
            .Size = .{
                .height = 2,
                .width = 25,
            },
        });
        try Platforms.append(PlatformModel{
            .Position = raylib.Rectangle.init(
                screenWidth / 4,
                0,
                screenWidth,
                screenHeight,
            ),
            .Size = .{
                .height = 2,
                .width = 50,
            },
        });
    }

    pub inline fn CheckForPlatformCollision(item: raylib.Rectangle, current_screen: raylib.Rectangle) ?raylib.Rectangle {
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

    //var rnd: RndGen = undefined;
    pub inline fn UpdatePlatforms(yOffset: f32, current_screen: raylib.Rectangle) std.ArrayList(PlatformModel) {
        // Iterate through the platforms in reverse to safely remove elements while iterating
        var index: usize = Platforms.items.len;
        var topmostPlatform: ?PlatformModel = null;
        while (index > 0) {
            index -= 1;

            const platform = Platforms.items[index];
            const updatedPlatform = platform.UpdatePosition(yOffset, current_screen);

            if (topmostPlatform == null or topmostPlatform.?.Position.y > updatedPlatform.Position.y) {
                topmostPlatform = updatedPlatform;
            }

            if (updatedPlatform.Position.y + (updatedPlatform.Size.height * 2) > current_screen.height) {
                // Remove platform that is no longer on screen
                _ = Platforms.swapRemove(index);
            } else {
                // Replace Platform with updated version of the same platform
                Platforms.replaceRange(
                    index,
                    1,
                    &[1]PlatformModel{
                        updatedPlatform,
                    },
                ) catch {
                    Logger.Error("Failed to update platform!");
                };
            }
        }

        if (topmostPlatform.?.Position.y > (current_screen.width / 6)) {
            // var positionX: f32 = rnd.random().float(f32) * current_screen.width;
            // const absolutePosition = topmostPlatform.?.GetPositionAbsolute(current_screen);
            // const newWidth: f32 = @floatFromInt(rnd.random().intRangeAtMost(i32, 20, 50));
            // const newWidthAbsolute = newWidth / 100 * current_screen.width;
            // const newHeightAbsolute = 0.02 * current_screen.width;
            // const minWidth = 0.01 * current_screen.width;

            // if (positionX < absolutePosition.x - minWidth and positionX + newWidthAbsolute > absolutePosition.x + absolutePosition.width) {
            //     positionX = current_screen.width - newWidthAbsolute;
            // }

            // // Topmost platfrom is below the new platform and has a smaller width than is possible to jump from
            // if (absolutePosition.x >= positionX and absolutePosition.x + absolutePosition.width >= positionX + newWidthAbsolute) {
            //     positionX = absolutePosition.x + absolutePosition.width;
            // } else if (positionX <= 0) {
            //     positionX = absolutePosition.x + absolutePosition.width;
            // } else if (positionX + newWidthAbsolute > current_screen.width) {
            //     positionX = 0;
            // }

            // Add platform
            // const newPlatform = PlatformModel{
            //     .Position = raylib.Rectangle.init(
            //         positionX,
            //         -(newHeightAbsolute * 2),
            //         current_screen.width,
            //         current_screen.height,
            //     ),
            //     .Size = .{
            //         .height = 2,
            //         .width = newWidth,
            //     },
            // };

            const pattern = GetPattern();
            const newPlatforms = PlatformModel.GetNewPlatformsFromPattern(pattern, current_screen);
            defer newPlatforms.deinit();
            for (newPlatforms.items) |newPlatform| {
                Platforms.append(newPlatform) catch {
                    Logger.Error("Failed to update platform!");
                };
            }
        }

        // if (rnd.random().boolean() and Platforms.items.len < 5) {
        //     // Add platform
        //     const newPlatform = PlatformModel{
        //         .Position = raylib.Rectangle.init(
        //             rnd.random().float(f32) * current_screen.width,
        //             -(topmostPlatform.?.Size.height * 2),
        //             current_screen.width,
        //             current_screen.height,
        //         ),
        //         .Size = .{
        //             .height = 2,
        //             .width = @floatFromInt(rnd.random().intRangeAtMost(i32, 10, 50)),
        //         },
        //     };
        //     Platforms.append(newPlatform) catch {
        //         Logger.Error("Failed to update platform!");
        //     };
        // }

        return Platforms;
    }

    pub inline fn Deinit() void {
        Platforms.clearAndFree();
    }

    pub inline fn GetCurrentScreenSize() raylib.Rectangle {
        const current_screen = raylib.Rectangle.init(
            0,
            0,
            @floatFromInt(raylib.getScreenWidth()),
            @floatFromInt(raylib.getScreenHeight()),
        );
        return current_screen;
    }
};
