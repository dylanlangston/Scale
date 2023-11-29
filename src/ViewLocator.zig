const std = @import("std");
const BaseViewModel = @import("./ViewModels/ViewModel.zig").ViewModel;
const BaseView = @import("./Views/View.zig").View;
const Logger = @import("./Logger.zig").Logger;

pub const ViewLocator = struct {
    inline fn GetView(view: Views) BaseView {
        switch (view) {
            Views.Raylib_Splash_Screen => {
                return @import("./Views/RaylibSplashScreenView.zig").RaylibSplashScreenView;
            },
            Views.Dylan_Splash_Screen => {
                return @import("./Views/DylanSplashScreenView.zig").DylanSplashScreenView;
            },
            Views.GameplayIntro => {
                return @import("./Views/GameplayIntroView.zig").GameplayIntroView;
            },
            Views.Paused => {
                return @import("./Views/PausedView.zig").PausedView;
            },
            Views.Menu => {
                return @import("./Views/MenuView.zig").MenuView;
            },
            Views.Scale => {
                return @import("./Views/ScaleView.zig").ScaleView;
            },
            Views.Settings => {
                return @import("./Views/SettingsView.zig").SettingsView;
            },
            Views.Game_Over => {
                return @import("./Views/GameOverView.zig").GameOverView;
            },
            else => {
                return BaseView{ .DrawRoutine = DrawQuit };
            },
        }
    }

    fn DrawQuit() Views {
        return Views.Quit;
    }

    pub inline fn Build(view: Views) BaseView {
        const BuiltView = GetView(view);
        BuiltView.init();
        return BuiltView;
    }
};

pub const Views = enum {
    Raylib_Splash_Screen,
    Dylan_Splash_Screen,
    Menu,
    Paused,
    GameplayIntro,
    Scale,
    Settings,
    Game_Over,
    Quit,
};
