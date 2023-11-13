const std = @import("std");
const BaseViewModel = @import("./ViewModels/ViewModel.zig").ViewModel;
const BaseView = @import("./Views/View.zig").View;

pub const ViewLocator = struct {
    fn GetView(view: Views) BaseView {
        switch (view) {
            Views.Raylib_Splash_Screen => {
                return @import("./Views/RaylibSplashScreenView.zig").RaylibSplashScreenView;
            },
            Views.Dylan_Splash_Screen => {
                return @import("./Views/DylanSplashScreenView.zig").DylanSplashScreenView;
            },
            Views.Menu => {
                return @import("./Views/MenuView.zig").MenuView;
            },
            Views.Scale => {
                return @import("./Views/ScaleView.zig").ScaleView;
            },
            Views.Paused => {
                return @import("./Views/PausedView.zig").PausedView;
            },
            Views.Settings => {
                return @import("./Views/SettingsView.zig").SettingsView;
            },
            else => {
                return BaseView{ .DrawRoutine = DrawQuit };
            },
        }
    }

    fn DrawQuit() Views {
        return Views.Quit;
    }

    pub fn Build(view: Views) BaseView {
        const BuiltView = GetView(view);
        BuiltView.init();
        return BuiltView;
    }
};

pub const Views = enum {
    Raylib_Splash_Screen,
    Dylan_Splash_Screen,
    Menu,
    Scale,
    Paused,
    Settings,
    Quit,
};