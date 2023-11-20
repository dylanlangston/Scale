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
    WorldModel.Platforms = WorldModel.UpdatePlatforms();

    WorldModel.Player = WorldModel.Player.UpdatePosition();

    raylib.clearBackground(Colors.Green.Dark);

    for (WorldModel.Platforms.items) |platform| {
        platform.Draw();
    }

    // Draw Player
    WorldModel.Player.Draw();

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

    if (Inputs.B_Pressed()) {
        WorldModel.Player = WorldModel.Player.Jump();
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
