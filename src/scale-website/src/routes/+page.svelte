<script lang="ts">
  import { Module } from "$lib/emscripten";
  import { onMount} from "svelte";

  function toggleFullScreen(): void {
    const lockPointer = false;
    const resizeCanvas = true;
    (<any>window).Module.requestFullscreen(lockPointer, resizeCanvas);
  }

function loadScript(name: string): void {
    const script = document.createElement("script");
    script.setAttribute("type", "text/javascript");
    script.setAttribute("src", name);
    document.head.append(script);
}

function loadEmscripten(): void {
    loadScript("fixes.js");
    loadScript("emscripten.js");

  (<any>window).Module = new Module();
  (<any>window).Module.setStatus("Downloading...");
  (<any>window).onerror = (e: any) => {
    (<any>window).Module.setStatus("Exception thrown, see JavaScript console");
    (<any>window).Module.setStatus = (e: any) => {
      e && console.error("[post-exception status] " + e);
    }
  };
}

const padding_horizontal = 24;
let updateSizeTimeout: number|undefined = undefined;
function UpdateSize(e: Event): void {
  if ((<any>Browser).isFullscreen)
  {
    return;
  }
  
  clearTimeout(updateSizeTimeout);
  updateSizeTimeout = setTimeout(() => {
    (<any>window).Module._updateWasmResolution((<any>e.target).innerWidth, ((<any>e.target).innerHeight - padding_horizontal));
  }, 50);
}

onMount(() => {
  loadEmscripten();

  window.addEventListener('resize', UpdateSize);
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
<div class="emscripten">
  <progress hidden id="progress" max="100" value="0"/>
</div>
<div class="emscripten">
  <canvas class="emscripten w-100" id="canvas" on:contextmenu={(e) => e.preventDefault()} tabindex=-1></canvas>
</div>
<div class="emscripten" id="status">Downloading...</div>