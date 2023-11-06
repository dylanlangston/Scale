const std = @import("std");
const View = @import("./View.zig").View;
const Helpers = @import("../Helpers.zig");
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const raylib = @import("raylib");
const Views = @import("../ViewLocator.zig").Views;
const Inputs = @import("../Inputs.zig").Inputs;
const MenuViewModel = @import("../ViewModels/MenuViewModel.zig").MenuViewModel;

pub fn DrawFunction() Views {
    const vm = MenuViewModel.GetVM(type);

    raylib.clearBackground(raylib.Color.blank);

    const title = vm.GetTitle();
    const screenWidth = raylib.getScreenWidth();
    const screenHeight = raylib.getScreenHeight();
    const fontSize = @divFloor(screenHeight, 20);
    const titleWidth = raylib.measureText(title, fontSize);

    raylib.drawText(title, @divFloor(screenWidth - titleWidth, 2), 100, fontSize, raylib.Color.yellow);

    if (Inputs.Up()) {
        raylib.drawText("Up", 300, 200, 20, raylib.Color.yellow);
    }

    if (Inputs.Down()) {
        raylib.drawText("Down", 300, 220, 20, raylib.Color.yellow);
    }

    if (Inputs.Left()) {
        raylib.drawText("Left", 300, 240, 20, raylib.Color.yellow);
    }

    if (Inputs.Right()) {
        raylib.drawText("Right", 300, 260, 20, raylib.Color.yellow);
    }

    return Views.Menu;
}

pub const MenuView = View{ .DrawRoutine = &DrawFunction, .VM = &MenuViewModel };
