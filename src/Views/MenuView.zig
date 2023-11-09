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

const vm = MenuViewModel.GetVM(type);

pub fn DrawFunction() Views {
    raylib.clearBackground(raylib.Color.blank);

    const locale = Shared.Locale.GetLocale().?;

    const title = locale.Title;
    const screenWidth = raylib.getScreenWidth();
    const screenHeight = raylib.getScreenHeight();
    const fontSize = @divFloor(screenHeight, 20);
    const titleWidth = raylib.measureText(title, fontSize);

    raylib.drawText(title, @divFloor(screenWidth - titleWidth, 2), 100, fontSize, raylib.Color.yellow);

    vm.Rectangles = [_]raylib.Rectangle{
        undefined,
        undefined,
        undefined,
    };

    for (0..3) |ind| {
        const i: i8 = @intCast(ind);
        const x: f32 = @floatFromInt(@divFloor(screenWidth, 2) - @divFloor(screenWidth, 3));
        const y: f32 = @floatFromInt(50 + (fontSize + 32) * i);
        const width: f32 = @floatFromInt(@divFloor(screenWidth, 3) * 2);
        const height: f32 = @floatFromInt(fontSize + 15);
        vm.Rectangles[ind] = raylib.Rectangle.init(
            x,
            y,
            width,
            height,
        );
        raylib.drawRectangleRounded(
            vm.Rectangles[ind],
            0.1,
            10,
            raylib.Color.blue,
        );
        raylib.drawRectangleRoundedLines(
            vm.Rectangles[ind],
            0.1,
            10,
            5,
            raylib.Color.red,
        );

        const fontsizeF: f32 = @floatFromInt(fontSize);

        raylib.drawTextEx(
            Shared.GetFont(Fonts.SpaceMeatball),
            "test",
            raylib.Vector2.init(
                (vm.Rectangles[ind].x + vm.Rectangles[ind].width / 2 - raylib.measureTextEx(
                    Shared.GetFont(Fonts.SpaceMeatball),
                    "test",
                    fontsizeF,
                    0,
                ).x / 2),
                vm.Rectangles[ind].y + 11,
            ),
            fontsizeF,
            0,
            raylib.Color.green,
        );
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
