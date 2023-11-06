const std = @import("std");
const Shared = @import("../Helpers.zig").Shared;
const View = @import("./View.zig").View;
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const raylib = @import("raylib");
const Views = @import("../ViewLocator.zig").Views;
const Fonts = @import("../FontManager.zig").Fonts;

var framesCounter: i16 = 0;
fn DrawFunction() Views {
    framesCounter += 1;

    raylib.clearBackground(raylib.Color.black);

    const text = "Made By Dylan Langston";
    const font = Shared.GetFont(Fonts.SpaceMeatball);
    const screenWidth: f32 = @floatFromInt(raylib.getScreenWidth());
    const screenHeight: f32 = @floatFromInt(raylib.getScreenHeight());
    const fontSize: f32 = screenWidth / 25;
    const TextSize = raylib.measureTextEx(font, text, fontSize, @floatFromInt(font.glyphPadding));

    const positionX: f32 = (screenWidth - TextSize.x) / 2;
    const positionY: f32 = (screenHeight - TextSize.y) / 2;

    raylib.drawTextEx(font, text, raylib.Vector2.init(positionX, positionY), fontSize, @floatFromInt(font.glyphPadding), raylib.Color.green);

    if (framesCounter == 120) {
        return Views.Menu;
    }

    return Views.Dylan_Splash_Screen;
}

pub const DylanSplashScreenView = View{
    .DrawRoutine = DrawFunction,
};
