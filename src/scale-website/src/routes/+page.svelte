<h1 class="text-3xl font-bold underline">
  Hello world!
</h1>

<style lang="postcss">
  :global(html) {
    background-color: theme(colors.gray.100);
  }
</style>

   <div class=spinner id=spinner></div>
      <div class=emscripten id=status>Downloading...</div>
      <span id=controls><span><input type=checkbox id=resize>Resize canvas</span><span><input type=checkbox id=pointerLock checked>Lock/hide mouse pointer    </span><span><input type=button onclick='Module.requestFullscreen(document.getElementById("pointerLock").checked,document.getElementById("resize").checked)'value=Fullscreen></span></span>
      <div class=emscripten><progress hidden id=progress max=100 value=0></progress></div>
      <div class=emscripten_border>
         <canvas class=emscripten id=canvas oncontextmenu=event.preventDefault() tabindex=-1></canvas>
      </div>
