const std = @import("std");
const builtin = @import("builtin");
const View = @import("./View.zig").View;
const Helpers = @import("../Helpers.zig");
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const raylib = @import("raylib");
const Views = @import("../ViewLocator.zig").Views;
const Inputs = @import("../Inputs.zig").Inputs;
const MenuViewModel = @import("../ViewModels/MenuViewModel.zig").MenuViewModel;
const Selection = @import("../ViewModels/MenuViewModel.zig").Selection;
const Shared = @import("../Helpers.zig").Shared;
const Fonts = @import("../FontManager.zig").Fonts;
const Colors = @import("../Colors.zig").Colors;
const Logger = @import("../Logger.zig").Logger;

const vm: type = MenuViewModel.GetVM();

pub fn DrawFunction() Views {
    raylib.clearBackground(Colors.Gray.Base);

    const locale = Shared.Locale.GetLocale().?;
    const font = Shared.GetFont(Fonts.EightBitDragon);
    const brick = Shared.GetTexture(.Brick);

    const title = locale.Title;
    const screenWidth = raylib.getScreenWidth();
    const screenHeight = raylib.getScreenHeight();
    const fontSize = @divFloor(screenWidth, 20);
    const startY = @divFloor(screenHeight, 4);

    const bricks_scale_x: f32 = 800 / @as(f32, @floatFromInt(screenWidth));
    const bricks_scale_y: f32 = 450 / @as(f32, @floatFromInt(screenHeight));
    const brick_size_x: f32 = 32 / bricks_scale_x;
    const brick_size_y: f32 = 32 / bricks_scale_y;
    const bricks_x: f32 = 25;
    const bricks_y: f32 = 14;
    const brick_rect = raylib.Rectangle.init(
        0,
        0,
        @floatFromInt(brick.width),
        @floatFromInt(brick.height),
    );
    for (0..bricks_x) |x| {
        for (0..bricks_y) |y| {
            const dest = raylib.Rectangle.init(
                @as(f32, @floatFromInt(x)) * brick_size_x,
                @as(f32, @floatFromInt(y)) * brick_size_y,
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

    const foregroundColor = Colors.Miyazaki.Blue_Gray;
    const backgroundColor = Colors.Miyazaki.Blue_Gray.alpha(0.75);
    const accentColor = Colors.Miyazaki.Blue;

    // Title
    const titleFont = Shared.GetFont(Fonts.EcBricksRegular);
    const TitleTextSize = raylib.measureTextEx(
        font,
        title,
        @as(f32, @floatFromInt(fontSize)) * 4,
        @floatFromInt(font.glyphPadding),
    );
    const titleFontsizeF: f32 = TitleTextSize.y;
    raylib.drawTextEx(
        titleFont,
        title,
        raylib.Vector2.init(
            ((@as(f32, @floatFromInt(screenWidth)) - TitleTextSize.x - titleFontsizeF) / 2) + 10,
            @as(f32, @floatFromInt(startY)) - (titleFontsizeF / 2),
        ),
        titleFontsizeF,
        @floatFromInt(titleFont.glyphPadding),
        Colors.Miyazaki.Brown,
    );

    // raylib.drawText(
    //     title,
    //     @divFloor(screenWidth - titleWidth, 2),
    //     startY,
    //     fontSize * 3,
    //     backgroundColor,
    // );

    var index: usize = 0;
    for (std.enums.values(Selection)) |select| {
        const text = vm.GetSelectionText(select);
        const i: i8 = @intCast(index);
        const x: f32 = @floatFromInt(@divFloor(screenWidth, 2) - @divFloor(screenWidth, 3));
        const y: f32 = @floatFromInt(startY + (fontSize * 3) + (fontSize + 32) * i);
        const width: f32 = @floatFromInt(@divFloor(screenWidth, 3) * 2);
        const height: f32 = @floatFromInt(fontSize + 16);
        vm.Rectangles[index] = raylib.Rectangle.init(
            x,
            y,
            width,
            height,
        );

        const selected_or_not_color = if (select == vm.selection) accentColor else foregroundColor;

        raylib.drawRectangleRounded(
            vm.Rectangles[index],
            0.1,
            10,
            backgroundColor,
        );
        raylib.drawRectangleRoundedLines(
            vm.Rectangles[index],
            0.1,
            10,
            5,
            selected_or_not_color,
        );

        const TextSize = raylib.measureTextEx(font, text, @floatFromInt(fontSize), @floatFromInt(font.glyphPadding));
        const fontsizeF: f32 = TextSize.y;

        raylib.drawTextEx(
            font,
            text,
            raylib.Vector2.init(
                8 + vm.Rectangles[index].x + ((vm.Rectangles[index].width - TextSize.x) / 2),
                vm.Rectangles[index].y + 8,
            ),
            fontsizeF,
            @floatFromInt(font.glyphPadding),
            selected_or_not_color,
        );

        index += 1;

        if (builtin.target.os.tag == .wasi) {
            // Disable quit in WASM
            if (index == 2) break;
        }
        if (index == 3) break;
    }

    if (Inputs.A_Pressed()) {
        return GetSelection();
    }

    const selection_int = @intFromEnum(vm.selection);
    if (Inputs.Up_Pressed() and selection_int > 0) {
        vm.selection = @enumFromInt(selection_int - 1);
    }

    if (Inputs.Down_Pressed()) {
        if (builtin.target.os.tag == .wasi) {
            // Disable quit in WASM
            if (selection_int < 1) {
                vm.selection = @enumFromInt(selection_int + 1);
            }
        } else if (selection_int < 2) {
            vm.selection = @enumFromInt(selection_int + 1);
        }
    }

    return Views.Menu;
}

fn GetSelection() Views {
    switch (vm.selection) {
        Selection.Start => {
            return Views.GameplayIntro;
        },
        Selection.Settings => {
            return Views.Settings;
        },
        Selection.Quit => {
            return Views.Quit;
        },
        else => {
            return Views.Menu;
        },
    }
}

pub const MenuView = View{ .DrawRoutine = &DrawFunction, .VM = &MenuViewModel };
