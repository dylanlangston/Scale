const raylib = @import("raylib");

// TODO: Update palette, see:
// https://lospec.com/palette-list
pub const Colors = struct {
    pub const Transparent = raylib.Color.blank;

    pub const Tone = Color{
        .Base = raylib.Color.ray_white,
        .Dark = raylib.Color.black,
        .Light = raylib.Color.white,
    };

    pub const Gray = Color{
        .Base = raylib.Color.gray,
        .Dark = raylib.Color.dark_gray,
        .Light = raylib.Color.light_gray,
    };

    pub const Red = Color{
        .Base = raylib.Color.red,
        .Dark = raylib.Color.maroon,
        .Light = raylib.Color.pink,
    };

    pub const Yellow = Color{
        .Base = raylib.Color.gold,
        .Dark = raylib.Color.orange,
        .Light = raylib.Color.yellow,
    };

    pub const Green = Color{
        .Base = raylib.Color.lime,
        .Dark = raylib.Color.dark_green,
        .Light = raylib.Color.green,
    };

    pub const Blue = Color{
        .Base = raylib.Color.blue,
        .Dark = raylib.Color.dark_blue,
        .Light = raylib.Color.sky_blue,
    };

    pub const Purple = Color{
        .Base = raylib.Color.violet,
        .Dark = raylib.Color.dark_purple,
        .Light = raylib.Color.purple,
    };

    pub const Brown = Color{
        .Base = raylib.Color.brown,
        .Dark = raylib.Color.dark_brown,
        .Light = raylib.Color.beige,
    };

    // Miyazaki 16 Palette
    pub const Miyazaki = struct {
        pub const Black = raylib.Color.init(
            35,
            34,
            40,
            255,
        );
        pub const Blue_Gray = raylib.Color.init(
            40,
            66,
            97,
            255,
        );
        pub const Brown = raylib.Color.init(
            95,
            88,
            84,
            255,
        );
        pub const Brown_Gray = raylib.Color.init(
            135,
            133,
            115,
            255,
        );
        pub const Tan = raylib.Color.init(
            184,
            176,
            149,
            255,
        );
        pub const Light_Gray = raylib.Color.init(
            195,
            213,
            199,
            255,
        );
        pub const White = raylib.Color.init(
            235,
            236,
            220,
            255,
        );
        pub const Blue = raylib.Color.init(
            36,
            133,
            166,
            255,
        );
        pub const Light_Blue = raylib.Color.init(
            84,
            186,
            210,
            255,
        );
        pub const Earth = raylib.Color.init(
            117,
            77,
            69,
            255,
        );
        pub const Red = raylib.Color.init(
            198,
            80,
            70,
            255,
        );
        pub const Pink = raylib.Color.init(
            230,
            146,
            138,
            255,
        );
        pub const Green = raylib.Color.init(
            30,
            116,
            83,
            255,
        );
        pub const LightGreen = raylib.Color.init(
            85,
            160,
            88,
            255,
        );
        pub const Lime = raylib.Color.init(
            161,
            191,
            65,
            255,
        );
        pub const Yellow = raylib.Color.init(
            227,
            192,
            84,
            255,
        );
    };
};

pub const Color = struct {
    Base: raylib.Color,
    Dark: raylib.Color,
    Light: raylib.Color,
};
