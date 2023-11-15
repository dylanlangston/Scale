const std = @import("std");
const builtin = @import("builtin");
const View = @import("./View.zig").View;
const Helpers = @import("../Helpers.zig");
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const raylib = @import("raylib");
const Views = @import("../ViewLocator.zig").Views;
const Inputs = @import("../Inputs.zig").Inputs;
const Shared = @import("../Helpers.zig").Shared;
const Fonts = @import("../FontManager.zig").Fonts;
const Colors = @import("../Colors.zig").Colors;
const Logger = @import("../Logger.zig").Logger;
const BaseView = @import("../Views/View.zig").View;
const PausedViewModel = @import("../ViewModels/PausedViewModel.zig").PausedViewModel;
const PauseOptions = @import("../ViewModels/PausedViewModel.zig").PauseOptions;

const vm: type = PausedViewModel.GetVM();

pub fn DrawFunction() Views {
    raylib.clearBackground(Colors.Blue.Base);

    const screenWidth: f32 = @floatFromInt(raylib.getScreenWidth());
    const screenHeight: f32 = @floatFromInt(raylib.getScreenHeight());
    const fontSize = @divFloor(screenWidth, 20);
    const startY = @divFloor(screenHeight, 4);
    const startX = @divFloor(screenWidth, 4);

    // Draw the background texture
    if (vm.BackgroundTexture != null) {
        const bg: raylib.Texture = vm.BackgroundTexture.?;
        const rec = raylib.Rectangle.init(0, 0, @floatFromInt(bg.width), @floatFromInt(bg.height));
        const rec2 = raylib.Rectangle.init(0, 0, screenWidth, screenHeight);
        const patch = raylib.NPatchInfo{
            .source = rec,
            .bottom = 0,
            .top = 0,
            .left = 0,
            .right = 0,
            .layout = 0,
        };
        raylib.drawTextureNPatch(
            bg,
            patch,
            rec2,
            raylib.Vector2.init(0, 0),
            0,
            Colors.Gray.Base,
        );
    }

    const foregroundColor = Colors.Blue.Dark;
    const backgroundColor = Colors.Blue.Dark.alpha(0.75);
    const accentColor = Colors.Blue.Light;

    const background_rec = raylib.Rectangle.init(
        startX,
        startY,
        screenWidth - (startX * 2),
        screenHeight - (startY * 2),
    );

    raylib.drawRectangleRounded(
        background_rec,
        0.1,
        10,
        backgroundColor,
    );
    raylib.drawRectangleRoundedLines(
        background_rec,
        0.1,
        10,
        5,
        foregroundColor,
    );

    const locale = Shared.Locale.GetLocale().?;

    const text = locale.Paused;
    const textWidth = raylib.measureText(text, @intFromFloat(fontSize));
    raylib.drawText(
        text,
        @divFloor((@as(i32, @intFromFloat(screenWidth)) - textWidth), 2),
        @divFloor((@as(i32, @intFromFloat(screenHeight)) - @as(i32, @intFromFloat(fontSize))), 2),
        @intFromFloat(fontSize),
        foregroundColor,
    );

    const yes = locale.Continue;
    const yesWidth: f32 = @floatFromInt(raylib.measureText(yes, @intFromFloat(fontSize)));
    const no = locale.Quit;
    const noWidth: f32 = @floatFromInt(raylib.measureText(no, @intFromFloat(fontSize)));

    const combinedYesNoWidth: f32 = yesWidth + noWidth;
    const YesNoPadding = (background_rec.width - combinedYesNoWidth) / 3;

    const yesNoPosY: i32 = @divFloor((@as(i32, @intFromFloat(screenHeight)) - @as(i32, @intFromFloat(fontSize))), 2) + (@as(i32, @intFromFloat(fontSize)) * 2);

    raylib.drawText(
        yes,
        @intFromFloat(background_rec.x + YesNoPadding),
        yesNoPosY,
        @intFromFloat(fontSize),
        if (vm.selection == PauseOptions.Continue) accentColor else foregroundColor,
    );

    raylib.drawText(
        no,
        @intFromFloat(background_rec.x + yesWidth + YesNoPadding + YesNoPadding),
        yesNoPosY,
        @intFromFloat(fontSize),
        if (vm.selection == PauseOptions.Quit) accentColor else foregroundColor,
    );

    if (Inputs.Left_Pressed() and vm.selection != PauseOptions.Continue) {
        vm.selection = PauseOptions.Continue;
    }

    if (Inputs.Right_Pressed() and vm.selection != PauseOptions.Quit) {
        vm.selection = PauseOptions.Quit;
    }

    if (Inputs.A_Pressed()) {
        return GetSelection();
    }

    return Views.Paused;
}

fn GetSelection() Views {
    switch (vm.selection) {
        PauseOptions.Continue => {
            return vm.View;
        },
        PauseOptions.Quit => {
            return Views.Menu;
        },
    }
}

pub const PausedView = View{
    .DrawRoutine = &DrawFunction,
    .VM = &PausedViewModel,
};
