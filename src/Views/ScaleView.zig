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

pub fn DrawFunction() Views {
    const VM = ScaleViewModel.GetVM();
    _ = VM;
    WorldModel.Player = WorldModel.Player.UpdatePosition();
    const playerPosition = WorldModel.Player.Position;
    const PlayerSize = PlayerModel.GetSize();
    Logger.Info_Formatted("X: {} Y:{} Width:{} Height:{}", .{
        playerPosition.x,
        playerPosition.y,
        playerPosition.width,
        playerPosition.height,
    });

    raylib.clearBackground(raylib.Color.green);

    raylib.drawRectangle(
        @intFromFloat(playerPosition.x),
        @intFromFloat(playerPosition.y),
        @intFromFloat(PlayerSize.width),
        @intFromFloat(PlayerSize.height),
        Colors.Red.Base,
    );

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

    var moveModifier: f32 = if (numberButtonsPressed > 1) 6 else 32;

    if (Inputs.Up_Held()) {
        WorldModel.Player = WorldModel.Player.MoveUp(moveModifier);
    }

    if (Inputs.Down_Held()) {
        WorldModel.Player = WorldModel.Player.MoveDown(moveModifier);
    }

    if (Inputs.Left_Held()) {
        WorldModel.Player = WorldModel.Player.MoveLeft(moveModifier);
    }

    if (Inputs.Right_Held()) {
        WorldModel.Player = WorldModel.Player.MoveRight(moveModifier);
    }

    if (Inputs.Start_Pressed()) {
        return Shared.Pause(Views.Scale);
    }

    if (Inputs.A_Pressed()) {
        return Views.Menu;
    }

    return Views.Scale;
}

pub const ScaleView = View{
    .DrawRoutine = &DrawFunction,
    .VM = &ScaleViewModel,
};
