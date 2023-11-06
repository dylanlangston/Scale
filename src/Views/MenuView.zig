const std = @import("std");
const View = @import("./View.zig").View;
const Helpers = @import("../Helpers.zig");
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const raylib = @import("raylib");
const Views = @import("../ViewLocator.zig").Views;
const MenuViewModel = @import("../ViewModels/MenuViewModel.zig").MenuViewModel;

pub fn DrawFunction() Views {
    const vm = MenuViewModel.GetVM(type);

    raylib.clearBackground(raylib.Color.black);

    const title = vm.GetTitle();
    const screenWidth = raylib.getScreenWidth();
    const screenHeight = raylib.getScreenHeight();
    const fontSize = @divFloor(screenHeight, 20);
    const titleWidth = raylib.measureText(title, fontSize);

    raylib.drawText(title, @divFloor(screenWidth - titleWidth, 2), 100, fontSize, raylib.Color.yellow);

    return Views.Menu;
}

pub const MenuView = View{ .DrawRoutine = &DrawFunction, .VM = &MenuViewModel };
