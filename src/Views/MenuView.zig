const std = @import("std");
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

const vm: type = MenuViewModel.GetVM();

pub fn DrawFunction() Views {
    raylib.clearBackground(raylib.Color.blank);

    const locale = Shared.Locale.GetLocale().?;

    const title = locale.Title;
    const screenWidth = raylib.getScreenWidth();
    const screenHeight = raylib.getScreenHeight();
    const fontSize = @divFloor(screenHeight, 20);
    const titleWidth = raylib.measureText(title, fontSize);

    raylib.drawText(title, @divFloor(screenWidth - titleWidth, 2), 100, fontSize, raylib.Color.yellow);

    var index: usize = 0;
    for (std.enums.values(Selection)) |select| {
        const text = vm.GetSelectionText(select);
        const i: i8 = @intCast(index);
        const x: f32 = @floatFromInt(@divFloor(screenWidth, 2) - @divFloor(screenWidth, 3));
        const y: f32 = @floatFromInt(50 + (fontSize + 32) * i);
        const width: f32 = @floatFromInt(@divFloor(screenWidth, 3) * 2);
        const height: f32 = @floatFromInt(fontSize + 15);
        vm.Rectangles[index] = raylib.Rectangle.init(
            x,
            y,
            width,
            height,
        );
        raylib.drawRectangleRounded(
            vm.Rectangles[index],
            0.1,
            10,
            raylib.Color.blue,
        );
        raylib.drawRectangleRoundedLines(
            vm.Rectangles[index],
            0.1,
            10,
            5,
            raylib.Color.red,
        );

        const fontsizeF: f32 = @floatFromInt(fontSize);

        raylib.drawTextEx(
            Shared.GetFont(Fonts.SpaceMeatball),
            text,
            raylib.Vector2.init(
                (vm.Rectangles[index].x + vm.Rectangles[index].width / 2 - raylib.measureTextEx(
                    Shared.GetFont(Fonts.SpaceMeatball),
                    text,
                    fontsizeF,
                    0,
                ).x / 2),
                vm.Rectangles[index].y + 11,
            ),
            fontsizeF,
            0,
            raylib.Color.green,
        );

        index += 1;

        if (index == 3) break;
    }

    return Views.Menu;
}

fn GetSelection() void {
    switch (vm.Rectangles) {
        Selection.Start => {
            return Views.Raylib_Splash_Screen;
        },
        Selection.Settings => {
            return Views.Raylib_Splash_Screen;
        },
        Selection.Quit => {
            return Views.Raylib_Splash_Screen;
        },
        else => {
            return Views.Menu;
        },
    }
}

pub const MenuView = View{ .DrawRoutine = &DrawFunction, .VM = &MenuViewModel };
