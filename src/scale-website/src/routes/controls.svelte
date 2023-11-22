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

    const touchElement = document.documentElement;
    onMount(() => {
        touchElement.addEventListener("touchstart", touchStart);
        touchElement.addEventListener("touchmove", touchMove);
        touchElement.addEventListener("touchend", touchEnd);
        touchElement.addEventListener("touchcancel", touchCancel);
    });
    onDestroy(() => {
        touchElement.removeEventListener("touchstart", touchStart);
        touchElement.removeEventListener("touchmove", touchMove);
        touchElement.removeEventListener("touchend", touchEnd);
        touchElement.removeEventListener("touchcancel", touchCancel);
    });
</script>

<style lang="postcss">
      #dpad {
        position: absolute;
        top: 0;
        bottom: 0;
        left: 1em;
        z-index: 10;
        margin: auto;
        padding: 2px;
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        grid-template-rows: repeat(3, 1fr);
        justify-items: center;
        align-items: center;
        width: fit-content;
        height: fit-content;

        --button-size: 2rem;
      }

      button {
        width: var(--button-size);
        height: var(--button-size);
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: background-color 0.3s, border-bottom-color 0.3s;
      }
      
      button.corner {
        background-color: transparent;
      }
      
      #up-left.corner {
        border-left: var(--button-size) solid transparent;
        border-right: 0rem solid transparent;
        border-bottom: var(--button-size) solid transparent;
      }
      
      #up-right.corner {
        border-left: 0rem solid transparent;
        border-right: var(--button-size) solid transparent;
        border-bottom: var(--button-size) solid transparent;
      }
      
      #down-left.corner {
        border-left: var(--button-size) solid transparent;
        border-right: 0rem solid transparent;
        border-top: var(--button-size) solid transparent;
      }
      
      #down-right.corner {
        border-left: 0rem solid transparent;
        border-right: var(--button-size) solid transparent;
        border-top: var(--button-size) solid transparent;
      }
      
      button.down:not(.corner) {
        background-color: #f0f0f0;
      }
      
      #up-left.corner.down, #up-right.corner.down {
        border-bottom: var(--button-size) solid #f0f0f0;
      }
      
      #down-left.corner.down, #down-right.corner.down {
        border-top: var(--button-size) solid #f0f0f0;
      }
</style>

<div id="dpad" class="bg-red-500 rounded-full">
    <button id="up" class="row-start-1 col-start-2 bg-red-700 rounded-t-lg" value={Button.Up}></button>
    <button id="left" class="row-start-2 col-start-1 bg-red-700 rounded-l-lg" value={Button.Left}></button>
    <button id="down" class="row-start-3 col-start-2 bg-red-700 rounded-b-lg" value={Button.Down}></button>
    <button id="right" class="row-start-2 col-start-3 bg-red-700 rounded-r-lg" value={Button.Right}></button>
    <div class="row-start-2 col-start-2 w-full h-full bg-red-700"></div>
    <button id="up-left" class="corner row-start-1 col-start-1 rounded-lg" value={Button.Up_Left}></button>
    <button id="up-right" class="corner row-start-1 col-start-3 rounded-lg" value={Button.Up_Right}></button>
    <button id="down-left" class="corner row-start-3 col-start-1 rounded-lg" value={Button.Down_Left}></button>
    <button id="down-right" class="corner row-start-3 col-start-3 rounded-lg" value={Button.Down_Right}></button>
</div>