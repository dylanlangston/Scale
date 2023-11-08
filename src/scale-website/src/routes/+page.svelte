<script lang="ts">
  import { Module } from "$lib/emscripten";
  import { onMount} from "svelte";

  function toggleFullScreen(): void {
    const lockPointer = false;
    const resizeCanvas = false;
    window.Module.requestFullscreen(lockPointer, resizeCanvas);
  }

  function loadEmscripten(): void {
    const script = document.createElement("script");
    script.setAttribute("type", "text/javascript");
    script.setAttribute("src", "emscripten.js");
    window.Module = new Module();
    window.Module.setStatus("Downloading...");
    window.onerror = e => {
      window.Module.setStatus("Exception thrown, see JavaScript console");
      spinnerElement.style.display = "none", Module.setStatus = e => {
        e && console.error("[post-exception status] " + e)
      }
    };
    document.head.appendChild(script);
  }

  onMount(() => {
    loadEmscripten();
  })
</script>

<style lang="postcss">
  :global(html) {
  background-color: theme(colors.green.500);
  }
</style>

<span id="controls">
  <button type="button" on:click={() => toggleFullScreen()}>Fullscreen</button>
</span>
<div>
  <progress hidden id="progress" max="100" value="0"/>
</div>
<div>
  <canvas id="canvas" on:contextmenu={(e) => e.preventDefault()} tabindex=-1></canvas>
</div>
<div id="status">Downloading...</div>