const std = @import("std");
const Shared = @import("../Scale.zig").Shared;
const Helpers = @import("../Helpers.zig");
const View = @import("./View.zig").View;
const ViewModel = @import("../ViewModels/ViewModel.zig").ViewModel;
const raylib = @import("raylib");
const Views = @import("../ViewLocator.zig").Views;

var start_time: f64 = 0;
fn DrawFunction() Views {
    if (Shared.GetSettings().Debug) {
        return Views.Menu;
    }

    if (start_time == 0) {
        start_time = raylib.getTime();
        return Views.Splash_Screen;
    } else if (start_time + 5 > raylib.getTime()) {
        return Views.Splash_Screen;
    } else {
        return Views.Menu;
    }
}

pub const SplashScreenView = View{ .DrawRoutine = DrawFunction };
