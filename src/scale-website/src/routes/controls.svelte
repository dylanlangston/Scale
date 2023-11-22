<script lang="ts">
    import { Button } from "$lib/gameController";

    export let handleButtonPressed = (button: Button) => {
        console.log("Button Pressed: " + button);
    };
    export let handleButtonReleased = (button: Button) => {
        console.log("Button Released: " + button);
    };

    function touchUp(e: PointerEvent) {
      if (e.target instanceof HTMLButtonElement && e.target.tagName == "BUTTON" && e.target.classList.contains("down"))
      {
        e.target.classList.remove("down");
        handleButtonReleased(<any>e.target.value);
      }
      e.preventDefault();
    }

    function touchDown(e: PointerEvent) {
      if (e.target instanceof HTMLButtonElement && e.target.tagName == "BUTTON" && !e.target.classList.contains("down"))
      {
        e.target.classList.add("down");
        navigator.vibrate(10);
        handleButtonPressed(<any>e.target.value);
      }
    }

    function touchMove(e: PointerEvent) {
      e.preventDefault();
      
      const buttonsDown = document.querySelectorAll("#dpad > button.down");
      const elem = <HTMLButtonElement>document.elementFromPoint(e.clientX, e.clientY);
      if (buttonsDown.length == 1 && buttonsDown[0] == elem) return;
      
      buttonsDown.forEach(n => {
        n.classList.remove("down");
        handleButtonReleased(<any>(<HTMLButtonElement>n).value);
      });
      
      if (elem?.tagName == "BUTTON")
      {
        elem.classList.add("down");
        navigator.vibrate(10);
        handleButtonPressed(<any>elem.value);
      }
    }
</script>

<style global lang="postcss">
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
      
      #dpad > button.down:not(.corner), #jump.down, #start.down {
        background-color: theme(colors.neutral.300);
      }
      
      #dpad > #up-left.corner.down, #dpad > #up-right.corner.down {
        border-bottom: var(--button-size) solid theme(colors.neutral.300);
      }
      
      #dpad > #down-left.corner.down, #dpad > #down-right.corner.down {
        border-top: var(--button-size) solid theme(colors.neutral.300);
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
  <div id="dpad" 
  on:pointermove={e => touchMove(e)}
  on:pointerdown={e => touchMove(e)}
  on:pointerup={e => touchUp(e)}
  on:pointerleave={e => touchUp(e)}
  on:pointercancel={e => touchUp(e)}
  on:lostpointercapture={e => touchUp(e)}
  class="absolute bottom-10 left-4 z-10 m-auto p-1 grid grid-cols-3 grid-rows-3 w-fit h-fit items-center justify-items-center bg-slate-50/[.5] rounded-full select-none touch-none">
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

  <div class="absolute bottom-20 right-4 z-10 bg-slate-50/[.5] rounded-full p-1 w-fit h-fit m-auto select-none">
      <button id="jump" title="Jump" class="bg-black/[.5] rounded-full w-16 h-16 p-0 font-bold text-black" 
        value={Button.Jump}
        on:pointerdown={e => touchDown(e)}
        on:pointerup={e => touchUp(e)}
        on:pointerleave={e => touchUp(e)}
        on:pointercancel={e => touchUp(e)}
        on:lostpointercapture={e => touchUp(e)}
      >A</button>
  </div>

  <div class="absolute top-4 left-4 z-10 bg-slate-50/[.5] rounded-full p-1 w-fit h-fit select-none">
      <button id="start" title="start" class="bg-black/[.5] rounded-full w-14 h-8 p-0 font-bold text-black" 
        value={Button.Start}
        on:pointerdown={e => touchDown(e)}
        on:pointerup={e => touchUp(e)}
        on:pointerleave={e => touchUp(e)}
        on:pointercancel={e => touchUp(e)}
        on:lostpointercapture={e => touchUp(e)}
      >Start</button>
  </div>
</div>