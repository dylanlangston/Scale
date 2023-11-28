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

const moveModifier: f32 = 32;

pub fn DrawFunction() Views {
    const current_screen = WorldModel.GetCurrentScreenSize();

    const scroll_speed: f32 = 20 * raylib.getFrameTime();

    WorldModel.Platforms = WorldModel.UpdatePlatforms(scroll_speed, current_screen);
    WorldModel.Player = WorldModel.Player.UpdatePosition(scroll_speed - 0.001, current_screen);

    raylib.clearBackground(Colors.Miyazaki.LightGreen);

    if (WorldModel.Player.Dead) return Views.Menu;

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
    for (0..buttonsPressed.len) |i| {
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
        WorldModel.Player = WorldModel.Player.MoveLeft();
    }

    if (Inputs.Right_Held()) {
        WorldModel.Player = WorldModel.Player.MoveRight();
    }

    if (Inputs.Start_Pressed()) {
        return Shared.Pause(Views.Scale);
    }

    return Views.Scale;
}

pub const ScaleView = View{
    .DrawRoutine = &DrawFunction,
    .VM = &ScaleViewModel,
};
