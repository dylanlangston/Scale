const builtin = @import("builtin");
const std = @import("std");
const raylib = @import("raylib");
const World = @import("World.zig").World;
const Logger = @import("../Logger.zig").Logger;
const Colors = @import("../Colors.zig").Colors;
const Shared = @import("../Helpers.zig").Shared;

pub const Bricks = struct {
    pub inline fn Draw(screenWidth: f32, screenHeight: f32, y_offset: f32) void {
        const brick = Shared.GetTexture(.Brick);

        const bricks_scale_x: f32 = 800 / screenWidth;
        const bricks_scale_y: f32 = 450 / screenHeight;
        const brick_size_x: f32 = 32 / bricks_scale_x;
        const brick_size_y: f32 = 32 / bricks_scale_y;
        const bricks_y_remainder: f32 = @rem(y_offset, brick_size_y);
        const bricks_x: f32 = 25;
        const bricks_y: f32 = 16;
        const brick_rect = raylib.Rectangle.init(
            0,
            0,
            @floatFromInt(brick.width),
            @floatFromInt(brick.height),
        );
        inline for (0..bricks_x) |x| {
            inline for (0..bricks_y) |y| {
                const bricks_y_offset = @as(f32, @floatFromInt(y)) - 1;
                const dest = raylib.Rectangle.init(
                    @as(f32, @floatFromInt(x)) * brick_size_x,
                    bricks_y_remainder + (bricks_y_offset * brick_size_y),
                    brick_size_x,
                    brick_size_y,
                );
                raylib.drawTexturePro(
                    brick,
                    brick_rect,
                    dest,
                    raylib.Vector2.init(0, 0),
                    0,
                    Colors.Miyazaki.Tan,
                );
            }
        }
    }
};
