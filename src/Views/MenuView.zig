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

    raylib.drawText(vm.Message, 100, 100, 20, raylib.Color.yellow);

    vm.Message = "Text Updated :)";

    return Views.Menu;
}

pub const MenuView = View{ .DrawRoutine = &DrawFunction, .VM = &MenuViewModel };
