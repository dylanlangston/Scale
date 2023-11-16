const std = @import("std");
const Shared = @import("../Helpers.zig").Shared;
const View = @import("./View.zig").View;
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const raylib = @import("raylib");
const Views = @import("../ViewLocator.zig").Views;
const Fonts = @import("../FontManager.zig").Fonts;
const Colors = @import("../Colors.zig").Colors;
const Logger = @import("../Logger.zig").Logger;
const DylanSplashScreenViewModel = @import("../ViewModels/DylanSplashScreenViewModel.zig").DylanSplashScreenViewModel;

var framesCounter: i16 = 0;
fn DrawFunction() Views {
    const vm = DylanSplashScreenViewModel.GetVM();

    framesCounter += 1;

    raylib.clearBackground(Colors.Tone.Dark);

    const text = Shared.Locale.GetLocale().?.Dylan_Splash_Text;
    const font = Shared.GetFont(Fonts.TwoLines);
    const screenWidth: f32 = @floatFromInt(raylib.getScreenWidth());
    const screenHeight: f32 = @floatFromInt(raylib.getScreenHeight());
    const fontSize: f32 = screenWidth / 25;
    const offset_mod: f32 = screenHeight / @as(f32, @floatFromInt(framesCounter));
    var color = vm.GetRandomColor(offset_mod);
    const TextSize = raylib.measureTextEx(font, text, fontSize, @floatFromInt(font.glyphPadding));

    const positionX: f32 = (screenWidth - TextSize.x) / 2;
    const positionY: f32 = (screenHeight - TextSize.y) / 2;

    const opacity: f32 = @as(f32, @floatFromInt(260 - framesCounter)) / 260;
    const transparentColor = color.alpha(opacity);

    if (framesCounter > 230) {
        const opaqu: f32 = @as(f32, @floatFromInt(260 - framesCounter)) / 30;
        color = color.alpha(opaqu);
    }

    var lines_loop_counter = framesCounter;
    const midWidth: i32 = @intFromFloat(screenWidth / 2);
    const midHeight: i32 = @intFromFloat(screenHeight / 2);
    while (lines_loop_counter < 260) {
        const endY: i32 = midHeight + 260 - lines_loop_counter + @as(i32, @intFromFloat(TextSize.y));
        raylib.drawLine(
            midWidth - @as(i32, @intFromFloat(TextSize.x / 2)) - (260 - lines_loop_counter),
            endY,
            midWidth + @as(i32, @intFromFloat(TextSize.x / 2)) + (260 - lines_loop_counter),
            endY,
            color,
        );
        if (@rem(lines_loop_counter, 5) == 0) {
            lines_loop_counter += 7;
        } else {
            lines_loop_counter += 1;
        }
    }

    raylib.drawTextEx(
        font,
        text,
        raylib.Vector2.init(positionX, positionY - offset_mod),
        fontSize,
        @floatFromInt(font.glyphPadding),
        transparentColor,
    );

    raylib.drawTextEx(
        font,
        text,
        raylib.Vector2.init(positionX, positionY + offset_mod),
        fontSize,
        @floatFromInt(font.glyphPadding),
        transparentColor,
    );

    raylib.drawTextEx(
        font,
        text,
        raylib.Vector2.init(positionX, positionY),
        fontSize,
        @floatFromInt(font.glyphPadding),
        color,
    );

    if (framesCounter == 260) {
        framesCounter = 0;
        return Views.Menu;
    }

    return Views.Dylan_Splash_Screen;
}

pub const DylanSplashScreenView = View{
    .DrawRoutine = DrawFunction,
    .VM = &DylanSplashScreenViewModel,
};
