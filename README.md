<style>
@property --Rainbow_R {
  syntax: '<number>';
  initial-value: 50;
  inherits: true;
}
@property --Rainbow_G {
  syntax: '<number>';
  initial-value: 200;
  inherits: true;
}
@property --Rainbow_B {
  syntax: '<number>';
  initial-value: 50;
  inherits: true;
}

@keyframes RotateR {
  0% {
    --Rainbow_R: 50;
  }
  100% {
    --Rainbow_R: 200;
  }
}

@keyframes RotateG {
  0% {
    --Rainbow_G: 200;
  }
  100% {
    --Rainbow_G: 50;
  }
}

@keyframes RotateB {
  0% {
    --Rainbow_B: 50;
  }
  100% {
    --Rainbow_B: 200;
  }
}

:root {
	--Rainbow_R: 50;
	--Rainbow_G: 200;
	--Rainbow_B: 50;

    --Rainbow: rgb(var(--Rainbow_R), var(--Rainbow_G), var(--Rainbow_B));
    --Rainbow_alt: rgb(var(--Rainbow_B), var(--Rainbow_R), var(--Rainbow_G));

  	animation: RotateR 10s linear infinite alternate, RotateG 5s linear infinite alternate, RotateB 7s linear infinite alternate;
}

h1, h2, h3, h4, h5, h6 {
    color: var(--Rainbow_alt)
}

a:link,a:visited {
	color: inherit;
	text-decoration: underline;
}
a:hover {
	color: var(--Rainbow);
	text-decoration: none;
}
</style>

[//]: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

# Scale Game 🧗‍♂️
This is a submission to the 2023 *Game Off* event hosted by [GitHub](https://github.com/) on [itch.io](https://itch.io/), It's a game developed using [Zig](https://ziglang.org/) and [Raylib](https://www.raylib.com/). It was created by [@dylanlangston](https://github.com/dylanlangston).

#### What's Game Off? [^1]

> [Game Off](https://itch.io/jam/game-off-2023) is GitHub's annual game jam challenging individuals and teams to build a game during the month of November. Use whatever programming languages, game engines, or libraries you like. You're also welcome to use AI tools to help generate code, assets, or anything in between! The theme for this year's jam is SCALE!
>
> The theme for this year's jam is **SCALE**!

#### My submission

My interpretion of the theme is a vertical platformer that is procedurally generated. 

#### Resources
- [Zig Documentation](https://ziglang.org/documentation/master/)
- [Zig Standard Library Documentation](https://ziglang.org/documentation/master/std/#A;std)


[^1]: Game Off 2023 on [Itch.io](https://itch.io/jam/game-off-2023)