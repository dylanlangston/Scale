const std = @import("std");
const builtin = @import("builtin");
const View = @import("./View.zig").View;
const Helpers = @import("../Helpers.zig");
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const raylib = @import("raylib");
const raygui = @import("raygui");
const Views = @import("../ViewLocator.zig").Views;
const Inputs = @import("../Inputs.zig").Inputs;
const Shared = @import("../Helpers.zig").Shared;
const Fonts = @import("../FontManager.zig").Fonts;
const Colors = @import("../Colors.zig").Colors;

pub fn DrawFunction() Views {
    raylib.clearBackground(raylib.Color.yellow);

    if (raygui.GuiButton(.{ .x = 100, .y = 100, .width = 200, .height = 100 }, "press me!") == 1) {
        std.debug.print("pressed\n", .{});
    }

    if (Inputs.A_Pressed()) {
        return Views.Menu;
    }

    return Views.Settings;
}

pub const SettingsView = View{
    .DrawRoutine = &DrawFunction,
};
