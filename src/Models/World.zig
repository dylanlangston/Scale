const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const PlayerModel = @import("../Models/Player.zig").Player;
const PlatformModel = @import("../Models/Platform.zig").Platform;
const PlatformPattern = @import("../Models/Platform.zig").PlatformPattern;
const LoadedPattern = @import("../Models/Platform.zig").PlatformPattern.LoadedPattern;
const MirroredPattern = @import("../Models/Platform.zig").PlatformPattern.MirroredPattern;
const Shared = @import("../Helpers.zig").Shared;
const Logger = @import("../Logger.zig").Logger;
const RndGen = std.rand.DefaultPrng;

pub const World = struct {
    pub var Player: PlayerModel = undefined;
    pub var Platforms: std.ArrayList(PlatformModel) = undefined;
    var loadedPatterns: ?LoadedPattern = null;
    var mirroredPatterns: ?MirroredPattern = null;
    var PlatformPatterns: ?[]PlatformPattern = null;
    var rnd: RndGen = undefined;

    inline fn GetPattern() PlatformPattern {
        const patterns = PlatformPatterns.?;
        const random = rnd.random().intRangeAtMost(usize, 0, patterns.len - 1);
        const pattern = patterns[random];
        return pattern;
    }

    pub inline fn Init() !void {
        Deinit();

        rnd = RndGen.init(@intCast(std.time.nanoTimestamp()));

        if (PlatformPatterns == null) {
            loadedPatterns = PlatformPattern.LoadPatternsFromFile(@embedFile("../platform-patterns.json"));
            const normal_patterns = loadedPatterns.?.get();
            mirroredPatterns = PlatformPattern.MirrorAllPlatformPatterns(normal_patterns);
            if (std.mem.concat(Shared.GetAllocator(), PlatformPattern, &[_][]PlatformPattern{
                normal_patterns,
                mirroredPatterns.?.get(),
            })) |patterns| {
                PlatformPatterns = patterns;
            } else |err| {
                Logger.Error_Formatted("Failed to mirror platfrorms: {}", .{err});
            }
        }

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
        const platforms = PlatformModel.GetNewPlatformsFromPattern(
            GetPattern(),
            raylib.Rectangle.init(
                0,
                0,
                screenWidth,
                screenHeight,
            ),
        );
        defer platforms.deinit();
        for (platforms.items) |p| {
            try Platforms.append(p);
        }

        // try Platforms.append(PlatformModel{
        //     .Position = raylib.Rectangle.init(
        //         screenWidth / 3,
        //         0,
        //         screenWidth,
        //         screenHeight,
        //     ),
        //     .Size = .{
        //         .height = 2,
        //         .width = 33,
        //     },
        // });
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

            var pattern = GetPattern();
            while (topmostPlatform.?.Pattern != null and PlatformPattern.CheckOverLap(pattern, topmostPlatform.?.Pattern.?)) {
                pattern = GetPattern();
            }
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
        if (PlatformPatterns != null) {
            Shared.GetAllocator().free(PlatformPatterns.?);
            PlatformPatterns = null;
        }
        if (loadedPatterns != null) {
            loadedPatterns.?.deinit();
            loadedPatterns = null;
        }
        if (mirroredPatterns != null) {
            mirroredPatterns.?.deinit();
            mirroredPatterns = null;
        }
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
