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
    const canvas = <HTMLCanvasElement>document.getElementById("canvas");
    canvas.style.display = 'none';

    (<any>window).Module.setStatus("Exception thrown, see JavaScript console");
    (<any>window).Module.setStatus = (e: any) => {
      e && console.error("[post-exception status] " + e);
    }
  };
}

const padding_horizontal = 0;
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
    background-color: theme(colors.gray.300);
  }

  .btn-fullscreen {
    -webkit-text-stroke: 1px black;
    -webkit-text-fill-color: white;
  }
</style>

<span id="controls" class="absolute right-0 pr-3 pt-2" title="Fullscreen">
  <button type="button" on:click={() => toggleFullScreen()}><a class="rounded-lg bg-slate-400/[.3] font-extrabold text-3xl btn-fullscreen p-2 pt-0">⛶</a></button>
</span>
<div class="emscripten">
  <canvas class="emscripten w-100 bg-gray-300" id="canvas" on:contextmenu={(e) => e.preventDefault()} tabindex=-1></canvas>
</div>
<div class="absolute flex top-0 bottom-0 left-0 right-0 items-center justify-center pointer-events-none -z-50">
  <div class="rounded-lg bg-slate-50 shadow-xl p-8">
    <div class="emscripten text-center text-6xl font-bold" id="status">Downloading...</div>
  </div>
</div>
