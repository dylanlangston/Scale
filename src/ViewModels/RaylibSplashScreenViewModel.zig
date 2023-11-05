const std = @import("std");
const ViewModel = @import("./ViewModel.zig").ViewModel;
const Shared = @import("../Scale.zig").Shared;
const States = @import("../Views/RaylibSplashScreenView.zig").States;

fn VM() type {
    return struct {
        pub var framesCounter: i16 = 0;
        pub var lettersCount: i16 = 0;
        pub var state = States.Blinking;
        pub var alpha: f32 = 1.0;
        pub var topSideRecWidth: i16 = 16;
        pub var leftSideRecHeight: i16 = 16;
        pub var bottomSideRecWidth: i16 = 16;
        pub var rightSideRecHeight: i16 = 16;

        pub fn Reset() void {
            framesCounter = 0;
            lettersCount = 0;
            state = States.Blinking;
            alpha = 1.0;
            topSideRecWidth = 16;
            leftSideRecHeight = 16;
            bottomSideRecWidth = 16;
            rightSideRecHeight = 16;
        }

        pub fn Update() void {
            switch (state) {
                States.Blinking => {
                    framesCounter += 1;
                    if (framesCounter == 120) {
                        state = States.ExpandTopLeft;
                        framesCounter = 0;
                    }
                },
                States.ExpandTopLeft => {
                    topSideRecWidth += 4;
                    leftSideRecHeight += 4;

                    if (topSideRecWidth == 256) state = States.ExpandBottomRight;
                },
                States.ExpandBottomRight => {
                    bottomSideRecWidth += 4;
                    rightSideRecHeight += 4;

                    if (bottomSideRecWidth == 256) state = States.Letters;
                },
                States.Letters => {
                    framesCounter += 1;

                    if (@divTrunc(framesCounter, 12) == 0) {
                        lettersCount += 1;
                        framesCounter = 0;
                    }

                    if (lettersCount >= 10) {
                        alpha -= 0.02;

                        if (alpha <= 0.0) {
                            alpha = 0.0;
                            state = States.Exit;
                        }
                    }
                },
                States.Exit => {},
            }
        }
    };
}

pub const RaylibSplashScreenViewModel = ViewModel{ .Get = @constCast(@ptrCast(&VM)) };
