<script lang="ts">
    import { Button } from "$lib/gameController";
    import { onMount, onDestroy } from "svelte";

    export let handleButtonPressed = (button: Button) => {
        console.log("Button Pressed: " + button);
    };
    export let handleButtonReleased = (button: Button) => {
        console.log("Button Released: " + button);
    };

    function touchUp(e: PointerEvent) {
      if (e.target instanceof HTMLButtonElement && e.target.tagName == "BUTTON")
      {
        e.target.classList.remove("down");
        if (Object.values(Button).includes(e.target.value))
        {
          handleButtonReleased(<any>e.target.value);
        }
      }
      e.preventDefault();
    }

    function touchMove(e: PointerEvent) {
      e.preventDefault();
      
      const buttonsDown = document.querySelectorAll("button.down");
      const elem = <HTMLButtonElement>document.elementFromPoint(e.clientX, e.clientY);
      if (buttonsDown.length == 1 && buttonsDown[0] == elem) return;
      
      document.querySelectorAll("button.down").forEach(n => {
        n.classList.remove("down");
        if (Object.values(Button).includes((<HTMLButtonElement>n).value))
        {
          handleButtonReleased(<any>(<HTMLButtonElement>n).value);
        }
      });
      
      if (elem?.tagName == "BUTTON")
      {
        elem.classList.add("down");
        navigator.vibrate(10);
        if (Object.values(Button).includes(elem.value))
        {
          handleButtonPressed(<any>elem.value);
        }
      }
    }
    const touchElement = globalThis.document;
    onMount(() => {
      touchElement?.addEventListener("pointermove", touchMove);
      touchElement?.addEventListener("pointerup", touchUp);
      touchElement?.addEventListener("pointerleave", touchUp);
      touchElement?.addEventListener("pointercancel", touchUp);
      touchElement?.addEventListener("lostpointercapture", touchUp);
    });
    onDestroy(() => {
      touchElement?.removeEventListener("pointermove", touchMove);
      touchElement?.removeEventListener("pointerup", touchUp);
      touchElement?.removeEventListener("pointerleave", touchUp);
      touchElement?.removeEventListener("pointercancel", touchUp);
      touchElement?.removeEventListener("lostpointercapture", touchUp);
    });
</script>

<style lang="postcss">
      #dpad {
        --button-size: 3rem;
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

      .arrow {
        border: solid theme(colors.black);
        border-width: 0 3px 3px 0;
        display: inline-block;
        padding: 3px;
      }

      .arrow.right {
        transform: rotate(-45deg);
        -webkit-transform: rotate(-45deg);
      }

      .arrow.left {
        transform: rotate(135deg);
        -webkit-transform: rotate(135deg);
      }

      .arrow.up {
        transform: rotate(-135deg);
        -webkit-transform: rotate(-135deg);
      }

      .arrow.down {
        transform: rotate(45deg);
        -webkit-transform: rotate(45deg);
      }
</style>

<div id="gamepad">
  <div id="dpad" class="absolute top-0 bottom-0 left-4 z-10 m-auto p-1 grid grid-cols-3 grid-rows-3 w-fit h-fit items-center justify-items-center bg-slate-50/[.5] rounded-full select-none touch-none">
    <button id="up" title="Up" class="row-start-1 col-start-2 bg-black/[.5] rounded-t-lg text-black" value={Button.Up}><i class="arrow up"></button>
    <button id="left" title="Left" class="row-start-2 col-start-1 bg-black/[.5] rounded-l-lg text-black" value={Button.Left}><i class="arrow left"></button>
    <button id="down" title="Down" class="row-start-3 col-start-2 bg-black/[.5] rounded-b-lg text-black" value={Button.Down}><i class="arrow down"></button>
    <button id="right" title="Right" class="row-start-2 col-start-3 bg-black/[.5] rounded-r-lg text-black" value={Button.Right}><i class="arrow right"></button>
    <div class="row-start-2 col-start-2 w-full h-full bg-black/[.5]"></div>
    <button id="up-left" class="corner row-start-1 col-start-1 rounded-lg bg-transparent" value={Button.Up_Left}></button>
    <button id="up-right" class="corner row-start-1 col-start-3 rounded-lg bg-transparent" value={Button.Up_Right}></button>
    <button id="down-left" class="corner row-start-3 col-start-1 rounded-lg bg-transparent" value={Button.Down_Left}></button>
    <button id="down-right" class="corner row-start-3 col-start-3 rounded-lg bg-transparent" value={Button.Down_Right}></button>
  </div>

  <div class="absolute top-0 bottom-0 right-4 z-10 bg-slate-50/[.5] rounded-full p-1 w-fit h-fit m-auto select-none">
      <button id="jump" title="Jump" class="bg-black/[.5] rounded-full w-16 h-16 p-0 font-bold text-black" value={Button.Jump}>A</button>
  </div>

  <div class="absolute top-4 left-4 z-10 bg-slate-50/[.5] rounded-full p-1 w-fit h-fit select-none">
      <button id="start" title="start" class="bg-black/[.5] rounded-full w-14 h-8 p-0 font-bold text-black" value={Button.Start}>Start</button>
  </div>
</div>