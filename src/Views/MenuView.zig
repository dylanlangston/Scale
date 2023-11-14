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
    const font = Shared.GetFont(Fonts.SpaceMeatball);

    const title = locale.Title;
    const screenWidth = raylib.getScreenWidth();
    const screenHeight = raylib.getScreenHeight();
    const fontSize = @divFloor(screenHeight, 20);
    const startY = @divFloor(screenHeight, 4);
    const titleWidth = raylib.measureText(title, fontSize * 2);

    const foregroundColor = Colors.Blue.Base;
    const backgroundColor = Colors.Blue.Dark;
    const accentColor = Colors.Blue.Light;
    raylib.drawText(
        title,
        @divFloor(screenWidth - titleWidth, 2),
        startY,
        fontSize * 2,
        backgroundColor,
    );

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
                (vm.Rectangles[index].x + vm.Rectangles[index].width / 2 - raylib.measureTextEx(
                    font,
                    text,
                    fontsizeF,
                    0,
                ).x / 2),
                vm.Rectangles[index].y + 8,
            ),
            fontsizeF,
            0,
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
