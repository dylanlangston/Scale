<script lang="ts">
    import { Button } from "$lib/gameController";
    import { onMount, onDestroy } from "svelte";

    export let handleButtonPressed = (button: Button) => {
        console.log("Button Pressed: " + button);
    };
    export let handleButtonReleased = (button: Button) => {
        console.log("Button Released: " + button);
    };

    function touchStart(e: TouchEvent): void {
        console.log("TouchStart-: " + e);
    }
    function touchMove(e: TouchEvent): void {
        console.log(e);
    }
    function touchEnd(e: TouchEvent): void {
        console.log("TouchEnd-: " + e);
    }
    function touchCancel(e: TouchEvent): void {
        console.log("TouchCancel-: " + e);
    }

    const touchElement = globalThis.document;
    onMount(() => {
        touchElement?.addEventListener("touchstart", touchStart);
        touchElement?.addEventListener("touchmove", touchMove);
        touchElement?.addEventListener("touchend", touchEnd);
        touchElement?.addEventListener("touchcancel", touchCancel);
    });
    onDestroy(() => {
        touchElement?.removeEventListener("touchstart", touchStart);
        touchElement?.removeEventListener("touchmove", touchMove);
        touchElement?.removeEventListener("touchend", touchEnd);
        touchElement?.removeEventListener("touchcancel", touchCancel);
    });
</script>

<style lang="postcss">
      #dpad {
        --button-size: 2rem;
      }

      #dpad > button {
        width: var(--button-size);
        height: var(--button-size);
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
      }
      
      #dpad > #up-left.corner {
        border-left: var(--button-size) solid transparent;
        border-right: 0rem solid transparent;
        border-bottom: var(--button-size) solid transparent;
      }
      
      #dpad > #up-right.corner {
        border-left: 0rem solid transparent;
        border-right: var(--button-size) solid transparent;
        border-bottom: var(--button-size) solid transparent;
      }
      
      #dpad > #down-left.corner {
        border-left: var(--button-size) solid transparent;
        border-right: 0rem solid transparent;
        border-top: var(--button-size) solid transparent;
      }
      
      #dpad > #down-right.corner {
        border-left: 0rem solid transparent;
        border-right: var(--button-size) solid transparent;
        border-top: var(--button-size) solid transparent;
      }
      
      #dpad > button.down:not(.corner), #jump.down {
        background-color: #f0f0f0;
      }
      
      #dpad > #up-left.corner.down, #up-right.corner.down {
        border-bottom: var(--button-size) solid #f0f0f0;
      }
      
      #dpad > #down-left.corner.down, #down-right.corner.down {
        border-top: var(--button-size) solid #f0f0f0;
      }
</style>

<div id="dpad" class="absolute top-0 bottom-0 left-4 z-10 m-auto p-1 grid grid-cols-3 grid-rows-3 w-fit h-fit items-center justify-items-center bg-slate-50/[.5] rounded-full select-none">
    <button id="up" title="Up" class="row-start-1 col-start-2 bg-black/[.5] rounded-t-lg text-black" value={Button.Up}>🞁</button>
    <button id="left" title="Left" class="row-start-2 col-start-1 bg-black/[.5] rounded-l-lg text-black" value={Button.Left}>🞀</button>
    <button id="down" title="Down" class="row-start-3 col-start-2 bg-black/[.5] rounded-b-lg text-black" value={Button.Down}>🞃</button>
    <button id="right" title="Right" class="row-start-2 col-start-3 bg-black/[.5] rounded-r-lg text-black" value={Button.Right}>🞂</button>
    <div class="row-start-2 col-start-2 w-full h-full bg-black/[.5]"></div>
    <button id="up-left" class="corner row-start-1 col-start-1 rounded-lg bg-transparent" value={Button.Up_Left}></button>
    <button id="up-right" class="corner row-start-1 col-start-3 rounded-lg bg-transparent" value={Button.Up_Right}></button>
    <button id="down-left" class="corner row-start-3 col-start-1 rounded-lg bg-transparent" value={Button.Down_Left}></button>
    <button id="down-right" class="corner row-start-3 col-start-3 rounded-lg bg-transparent" value={Button.Down_Right}></button>
</div>

<div class="absolute top-20 bottom-0 right-4 z-10 bg-slate-50/[.5] rounded-full p-1 w-fit h-fit m-auto select-none">
    <button id="jump" title="Jump" class="bg-black/[.5] rounded-full w-12 h-12 p-0 font-bold text-black" value={Button.Jump}>A</button>
</div>

<div class="absolute top-4 left-4 z-10 bg-slate-50/[.5] rounded-full p-1 w-fit h-fit select-none">
    <button id="start" title="start" class="bg-black/[.5] rounded-full w-14 h-8 p-0 font-bold text-black" value={Button.Start}>Start</button>
</div>