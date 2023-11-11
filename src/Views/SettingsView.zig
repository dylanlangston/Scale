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

pub fn DrawFunction() Views {
    if (Inputs.A_Pressed()) {
        return Views.Menu;
    }

    raylib.clearBackground(raylib.Color.yellow);

    return Views.Settings;
}

pub const SettingsView = View{
    .DrawRoutine = &DrawFunction,
};
