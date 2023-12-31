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
const Bricks = @import("../Models/Bricks.zig").Bricks;

const vm: type = MenuViewModel.GetVM();

pub fn DrawFunction() Views {
    // Play music if not already
    Shared.PlayMusic(.Theme);

    raylib.clearBackground(Colors.Gray.Base);

    const locale = Shared.Locale.GetLocale().?;
    const font = Shared.GetFont(Fonts.EightBitDragon);

    const title = locale.Title;
    const screenWidth = raylib.getScreenWidth();
    const screenHeight = raylib.getScreenHeight();
    const screenHeightF: f32 = @floatFromInt(screenHeight);
    const fontSize = @divFloor(screenWidth, 20);
    const startY = @divFloor(screenHeight, 4);

    const scroll_speed: f32 = 20 * raylib.getFrameTime();
    vm.offset_y += scroll_speed;
    if (vm.offset_y > screenHeightF) {
        vm.offset_y -= screenHeightF;
    }

    Bricks.Draw(
        @floatFromInt(screenWidth),
        @floatFromInt(screenHeight),
        vm.offset_y,
    );

    const foregroundColor = Colors.Miyazaki.Blue;
    const backgroundColor = Colors.Miyazaki.Blue_Gray.alpha(0.75);
    const accentColor = Colors.Miyazaki.Light_Blue;

    // Title
    const titleFont = Shared.GetFont(Fonts.EcBricksRegular);
    const TitleTextSize = raylib.measureTextEx(
        titleFont,
        title,
        @as(f32, @floatFromInt(fontSize)) * 3.25,
        @floatFromInt(font.glyphPadding),
    );
    const titleFontsizeF: f32 = TitleTextSize.y;
    raylib.drawTextEx(
        titleFont,
        title,
        raylib.Vector2.init(
            ((@as(f32, @floatFromInt(screenWidth)) - TitleTextSize.x) / 2),
            @as(f32, @floatFromInt(startY)) - (titleFontsizeF / 2),
        ),
        titleFontsizeF,
        @floatFromInt(titleFont.glyphPadding),
        Colors.Miyazaki.Earth,
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
            // Disable settings and quit options in WASM
            if (index == 1) break;
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
            if (selection_int < 0) {
                vm.selection = @enumFromInt(selection_int + 1);
            }
        } else if (selection_int < 2) {
            vm.selection = @enumFromInt(selection_int + 1);
        }
    }

    return Views.Menu;
}

inline fn GetSelection() Views {
    switch (vm.selection) {
        Selection.Start => {
            return Views.Scale;
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

pub const MenuView = View{
    .DrawRoutine = DrawFunction,
    .VM = &MenuViewModel,
};
