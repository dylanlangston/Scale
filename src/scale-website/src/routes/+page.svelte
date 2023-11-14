<script lang="ts">
  import { Module } from "$lib/emscripten";
  import { onMount} from "svelte";
  import { BrowserDetector } from "browser-dtector";

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

const padding_horizontal = 0;
let updateSizeTimeout: number|undefined = undefined;
function UpdateSize(e: Event): void {
  clearTimeout(updateSizeTimeout);
  const new_canvas = cloneCanvas();

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
    clearTimeout(hideNewCanvasTimeout);
    hideNewCanvasTimeout = setTimeout(() => {
      new_canvas.hidden = true;
    }, 250);
    
  }, 10);
}

function getCanvasImage(): string | null {
  const newCanvas = <HTMLCanvasElement>document.createElement("canvas");
  newCanvas.width = window.Module.canvas.width;
  newCanvas.height = window.Module.canvas.height;
  const context = newCanvas.getContext('2d');
  context?.drawImage(window.Module.canvas, 0, 0);
  const img_data = context?.getImageData(2, 2, 1, 1);
  return img_data?.data[3] == 0 ? null : newCanvas.toDataURL("image/png");
}

let hideNewCanvasTimeout: number|undefined = undefined;

function cloneCanvas(): HTMLImageElement {
  const newCanvas = <HTMLImageElement>document.getElementById("canvas-copy");
  newCanvas.width = window.innerWidth;
  newCanvas.height = window.innerHeight;

  const canvasImage = getCanvasImage();
  if (canvasImage == null) return newCanvas;

  newCanvas.src = canvasImage;
  newCanvas.hidden = false;
  return newCanvas;
}

function loadEmscripten(): void {
  loadScript("emscripten.js");

  window.Module = new Module();
  window.Module.setStatus("Downloading...");
  window.onerror = (e: any) => {
    document.getElementById("canvas")!.style.display = 'none';
    document.getElementById("canvas-copy")!.style.display = 'none';

    window.Module.setStatus("Exception thrown, see JavaScript console.\nReload page to try again.");
    window.Module.setStatus = (e: any) => {
      e && console.error("[post-exception status] " + e);
    }
  };
}

let isMobile = () => {
  const detector = new BrowserDetector();
  return detector.parseUserAgent().isMobile;
};

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
    text-stroke: 1px white;
    text-fill-color: black;
  }
</style>

<div class="portrait:hidden">
  <span id="controls" class="absolute right-0 pr-3 pt-2" title="Fullscreen">
    <button type="button" on:click={() => toggleFullScreen()}><a class="rounded-lg bg-slate-400/[.3] font-extrabold text-3xl btn-fullscreen p-2 pt-0">⛶</a></button>
  </span>
  <div class="emscripten">
    <canvas class="emscripten w-full h-full" id="canvas" on:contextmenu={(e) => e.preventDefault()} tabindex=-1></canvas>
    <img hidden class="absolute top-0 left-0 w-full h-full object-fill" id="canvas-copy"/>
  </div>
  <div class="absolute flex top-0 bottom-0 left-0 right-0 items-center justify-center pointer-events-none -z-50">
    <div id="status-container" class="rounded-lg bg-slate-50 shadow-xl p-8 m-8">
      <div class="emscripten text-center text-6xl font-bold" id="status" contenteditable="true"><div class="jsonly">Starting...</div><noscript>Please enable Javascript to play.</noscript></div>
    </div>
  </div>
</div>

<div class="landscape:hidden">
  <div class="absolute flex top-0 bottom-0 left-0 right-0 items-center justify-center pointer-events-none">
    <div class="rounded-lg bg-slate-50 shadow-xl p-8 m-8">
      {#if isMobile()}
        <div class="text-center text-6xl font-bold">Rotate! 🔄</div>
      {:else}
        <div class="text-center text-6xl font-bold">Resize! ↔️npm</div>
      {/if}
    </div>
  </div>
</div>