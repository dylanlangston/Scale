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
const ScaleViewModel = @import("../ViewModels/ScaleViewModel.zig").ScaleViewModel;
const PlayerModel = @import("../Models/Player.zig").Player;
const WorldModel = @import("../Models/World.zig").World;
const Bricks = @import("../Models/Bricks.zig").Bricks;
const Sounds = @import("../SoundManager.zig").Sounds;

const vm: type = ScaleViewModel.GetVM();
const moveModifier: f32 = 32;

pub fn DrawFunction() Views {
    // Play music if not already
    Shared.PlayMusic(.Theme);

    const current_screen = WorldModel.GetCurrentScreenSize();

    vm.elapsedSeconds += raylib.getFrameTime();

    const scroll_speed_mod: u32 = @intFromFloat(@divFloor(vm.elapsedSeconds, 10));
    const scroll_speed: f32 = (20 + (@as(f32, @floatFromInt(scroll_speed_mod)) * 10)) * raylib.getFrameTime();
    vm.offset_y += scroll_speed;
    if (vm.offset_y > current_screen.height) {
        vm.offset_y -= current_screen.height;
    }

    WorldModel.Platforms = WorldModel.UpdatePlatforms(scroll_speed, current_screen);
    WorldModel.Player = WorldModel.Player.UpdatePosition(scroll_speed - 0.0001, current_screen);

    raylib.clearBackground(Colors.Miyazaki.LightGreen);

    Bricks.Draw(
        current_screen.width,
        current_screen.height,
        vm.offset_y,
    );

    for (WorldModel.Platforms.items) |platform| {
        platform.Draw(current_screen);
    }

    // Draw Player
    WorldModel.Player.Draw(current_screen);

    const up = Inputs.Up_Held();
    const down = Inputs.Up_Held();
    const left = Inputs.Up_Held();
    const right = Inputs.Up_Held();

    const buttonsPressed = [_]bool{
        up,
        down,
        left,
        right,
    };
    var numberButtonsPressed: f32 = 0;
    inline for (0..buttonsPressed.len) |i| {
        _ = i;
        numberButtonsPressed += 1;
    }

    if (Inputs.A_Pressed()) {
        WorldModel.Player = WorldModel.Player.Jump(current_screen);
    }

    // if (Inputs.Down_Held()) {
    //     WorldModel.Player = WorldModel.Player.MoveDown();
    // }

    if (Inputs.Left_Held()) {
        WorldModel.Player = WorldModel.Player.MoveLeft(current_screen);
    }

    if (Inputs.Right_Held()) {
        WorldModel.Player = WorldModel.Player.MoveRight(current_screen);
    }

    // Gameplay intro
    if (vm.introShown == false) {
        vm.introShown = true;
        return Shared.GameIntro();
    }

    // Time
    const locale = Shared.Locale.GetLocale().?;
    const font = Shared.GetFont(Fonts.EightBitDragon);

    const time = locale.Time;
    const fontSize = @divFloor(current_screen.width, 50);
    const duration = std.fmt.fmtDuration(@as(u64, @intFromFloat(vm.elapsedSeconds)) * 1000000000);
    var buf: [128]u8 = undefined;
    const timestamp = std.fmt.bufPrintZ(&buf, "{s}{s}", .{ time, duration }) catch "Unknown!!";
    const timestampSize = raylib.measureTextEx(
        font,
        timestamp,
        fontSize,
        @floatFromInt(font.glyphPadding),
    );
    raylib.drawTextEx(
        font,
        timestamp,
        raylib.Vector2.init(
            current_screen.width - timestampSize.x - (current_screen.width / 50),
            current_screen.height / 100,
        ),
        fontSize,
        @floatFromInt(font.glyphPadding),
        Colors.Miyazaki.Light_Blue,
    );

    // Ensure these are last, otherwise the framebuffer won't display all the 'background' content
    if (Inputs.Start_Pressed()) {
        return Shared.Pause(Views.Scale);
    }
    if (WorldModel.Player.Dead) {
        Shared.PlaySound(Sounds.GameOver);
        return Shared.GameOver();
    }

    return Views.Scale;
}

pub const ScaleView = View{
    .DrawRoutine = &DrawFunction,
    .VM = &ScaleViewModel,
};
