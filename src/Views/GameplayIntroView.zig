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
const GameplayIntroViewModel = @import("../ViewModels/GameplayIntroViewModel.zig").GameplayIntroViewModel;

const vm: type = GameplayIntroViewModel.GetVM();

pub fn DrawFunction() Views {
    raylib.clearBackground(Colors.Gray.Base);

    const screenWidth: f32 = @floatFromInt(raylib.getScreenWidth());
    const screenHeight: f32 = @floatFromInt(raylib.getScreenHeight());
    const font = Shared.GetFont(Fonts.EightBitDragon);
    const fontSize = @divFloor(screenWidth, 55);
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
            Colors.Miyazaki.Tan,
        );
    }

    const foregroundColor = Colors.Miyazaki.Blue;
    const backgroundColor = Colors.Miyazaki.Blue_Gray.alpha(0.75);
    const accentColor = Colors.Miyazaki.Light_Blue;
    _ = accentColor;

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

    var split_text = std.mem.splitSequence(u8, locale.Gameplay_Intro, "\n");
    var text_raw: ?[]const u8 = split_text.next();
    const padding = fontSize / 2;
    var index: f32 = 0;
    while (text_raw != null) {
        const alloc = Shared.GetAllocator();
        const text: [:0]const u8 = alloc.dupeZ(
            u8,
            text_raw.?,
        ) catch text_raw.?[0..text_raw.?.len :0];

        defer alloc.free(text);

        const textSize = raylib.measureTextEx(
            font,
            text,
            fontSize,
            @floatFromInt(font.glyphPadding),
        );
        raylib.drawTextEx(
            font,
            text,
            raylib.Vector2.init(
                ((screenWidth - textSize.x) / 2),
                startY + (fontSize * 1.75) + ((textSize.y + padding) * index),
            ),
            textSize.y,
            @floatFromInt(font.glyphPadding),
            foregroundColor,
        );

        text_raw = split_text.next();
        index += 1;
    }

    if (Inputs.A_Pressed()) {
        if (vm.BackgroundTexture != null) {
            vm.BackgroundTexture.?.unload();
        }
        return Views.Scale;
    }

    return Views.GameplayIntro;
}

pub const GameplayIntroView = View{
    .DrawRoutine = &DrawFunction,
    .VM = &GameplayIntroViewModel,
};
