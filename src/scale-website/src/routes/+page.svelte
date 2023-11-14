<script lang="ts">
  import { Module } from "$lib/emscripten";
  import { onMount} from "svelte";
  import { BrowserDetector } from "browser-dtector";

  function toggleFullScreen(): void {
    const lockPointer = false;
    const resizeCanvas = false;
    const requestFullscreen = window.Module.requestFullscreen;
    if (requestFullscreen)
    {
      const updateWasmResolution = window.Module._updateWasmResolution;
      if (updateWasmResolution)
      {
        const resolution = fitInto16x9AspectRatio(window.screen.width, window.screen.height);
        updateWasmResolution(resolution.width, resolution.height);
      }
      requestFullscreen(lockPointer, resizeCanvas);
    }
  }

function loadScript(name: string): HTMLScriptElement {
    const script = document.createElement("script");
    script.setAttribute("type", "text/javascript");
    script.setAttribute("src", name);
    document.head.append(script);
    return script;
}

const padding_horizontal = 0;
let updateSizeTimeout: number|undefined = undefined;
function UpdateSize(e: Event): void {
  clearTimeout(hideNewCanvasTimeout);
  clearTimeout(updateSizeTimeout);
  const new_canvas = cloneCanvas();
  window.Module.canvas.hidden = true;

  updateSizeTimeout = setTimeout(() => {
    if (window.Browser.isFullscreen)
    {
      return;
    }

    const updateWasmResolution = window.Module._updateWasmResolution;
    if (updateWasmResolution)
    {
      const resolution = fitInto16x9AspectRatio((<Window>e.target).innerWidth, ((<Window>e.target).innerHeight - padding_horizontal));
      updateWasmResolution(resolution.width, resolution.height);
    }
  }, 10);

  hideNewCanvasTimeout = setTimeout(() => {
    window.Module.canvas.hidden = false;
    new_canvas.hidden = true;
  }, 250);
}

function fitInto16x9AspectRatio(originalWidth: number, originalHeight: number): { width: number; height: number } {
    const targetAspectRatio = 16 / 9;
    const currentAspectRatio = originalWidth / originalHeight;

    if (currentAspectRatio > targetAspectRatio) {
        const newWidth = originalHeight * targetAspectRatio;
        return { width: newWidth, height: originalHeight };
    } else {
        const newHeight = originalWidth / targetAspectRatio;
        return { width: originalWidth, height: newHeight };
    }
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
  const resolution = fitInto16x9AspectRatio(window.innerWidth, window.innerHeight);
  newCanvas.width = resolution.width;
  newCanvas.height = resolution.height;

  const canvasImage = getCanvasImage();
  if (canvasImage == null) return newCanvas;

  newCanvas.src = canvasImage;
  newCanvas.hidden = false;
  return newCanvas;
}

function loadEmscripten(): HTMLScriptElement {
  const script = loadScript("emscripten.js");

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

  return script;
}

let isMobile = () => {
  const detector = new BrowserDetector();
  return detector.parseUserAgent().isMobile;
};

onMount(() => {
  if (Module.updateSettingsFromQueryString())
  {
    window.location.search = "";
  }
  else {
    const emscripten = loadEmscripten();
    emscripten.onload = (e) => {
      window.addEventListener('resize', UpdateSize);
      window.addEventListener("deviceorientation", UpdateSize, true);

    };
  }
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

  .emoji {
    font-family: Apple Color Emoji,Segoe UI Emoji,Noto Color Emoji,Android Emoji,EmojiSymbols,EmojiOne Mozilla,Twemoji Mozilla,Segoe UI Symbol,Noto Color Emoji Compat,emoji,noto-emojipedia-fallback;
  }
</style>

<div class="portrait:hidden">
  <span id="controls" class="absolute right-0 pr-3 pt-2 z-50" title="Fullscreen">
    <button type="button" on:click={() => toggleFullScreen()}><a class="rounded-lg bg-slate-400/[.3] font-extrabold text-3xl btn-fullscreen p-2 pt-0 pb-0.5">⛶</a></button>
  </span>
  <div class="emscripten z-0">
    <canvas class="emscripten absolute top-0 bottom-0 left-0 right-0 m-auto" id="canvas" on:contextmenu={(e) => e.preventDefault()} tabindex=-1></canvas>
    <img hidden class="absolute top-0 bottom-0 left-0 right-0 m-auto" id="canvas-copy"/>
  </div>
  <div class="absolute flex top-0 bottom-0 left-0 right-0 items-center justify-center pointer-events-none -z-50">
    <div id="status-container" class="rounded-lg bg-slate-50 shadow-xl p-8 m-8">
      <div class="emscripten text-center text-2xl lg:text-6xl font-bold" id="status" contenteditable="true"><div class="jsonly">Starting...</div><noscript>Please enable Javascript to play.</noscript></div>
    </div>
  </div>
</div>

<div class="landscape:hidden">
  <div class="absolute flex top-0 bottom-0 left-0 right-0 items-center justify-center pointer-events-none">
    <div class="rounded-lg bg-slate-50 shadow-xl p-8 m-8">
      {#if isMobile()}
        <div class="text-center text-2xl lg:text-6xl font-bold emoji">Rotate! 🔄</div>
      {:else}
        <div class="text-center text-2xl lg:text-6xl font-bold emoji">Resize! ↔️</div>
      {/if}
    </div>
  </div>
</div>