<script lang="ts">
  import { Module } from "$lib/emscripten";
  import { onMount} from "svelte";

  function toggleFullScreen(): void {
    const lockPointer = false;
    const resizeCanvas = true;
    const requestFullscreen = window.Module.requestFullscreen;
    if (requestFullscreen)
    {
      requestFullscreen(lockPointer, resizeCanvas);
    }
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

  window.Module = new Module();
  window.Module.setStatus("Downloading...");
  window.onerror = (e: any) => {
    const canvas = <HTMLCanvasElement>document.getElementById("canvas");
    canvas.style.display = 'none';

    window.Module.setStatus("Exception thrown, see JavaScript console");
    window.Module.setStatus = (e: any) => {
      e && console.error("[post-exception status] " + e);
    }
  };
}

const padding_horizontal = 0;
let updateSizeTimeout: number|undefined = undefined;
function UpdateSize(e: Event): void {
  clearTimeout(updateSizeTimeout);
  updateSizeTimeout = setTimeout(() => {
    if (window.Browser.isFullscreen)
    {
      return;
    }

    const updateWasmResolution = window.Module._updateWasmResolution;
    if (updateWasmResolution)
    {
      updateWasmResolution((<Window>e.target).innerWidth, ((<Window>e.target).innerHeight - padding_horizontal));
    }
  }, 10);
}

onMount(() => {
  loadEmscripten();

  window.addEventListener('resize', UpdateSize);
})
</script>

<style lang="postcss">
  :global(html) {
    background-color: theme(colors.gray.300);
    overflow: hidden;
  }

  .btn-fullscreen {
    -webkit-text-stroke: 1px white;
    -webkit-text-fill-color: black;
  }
</style>

<span id="controls" class="absolute right-0 pr-3 pt-2" title="Fullscreen">
  <button type="button" on:click={() => toggleFullScreen()}><a class="rounded-lg bg-slate-400/[.3] font-extrabold text-4xl btn-fullscreen p-2 pt-0 pb-1">⛶</a></button>
</span>
<div class="emscripten">
  <canvas class="emscripten w-100 bg-gray-300" width="1" height="1" id="canvas" on:contextmenu={(e) => e.preventDefault()} tabindex=-1></canvas>
</div>
<div class="absolute flex top-0 bottom-0 left-0 right-0 items-center justify-center pointer-events-none -z-50">
  <div class="rounded-lg bg-slate-50 shadow-xl p-8 m-8">
    <div class="emscripten text-center text-6xl font-bold" id="status">Downloading...</div>
  </div>
</div>
