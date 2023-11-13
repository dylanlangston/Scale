export class Module {

    public requestFullscreen?: (lockPointer: boolean, resizeCanvas: boolean) => void;
    public _updateWasmResolution?: (width: number, height: number) => void;

    public preRun(mod: any): void {
        mod.arguments.push(Module.getSettings());
    }

    private static settingsName: string = "settings";
    private static getSettings(): string|null {
        return window.localStorage.getItem(Module.settingsName) ?? "";
    }
    private static saveSettings() {
        let u8array = [];
        for (let i = 0; i < (<any>window).Module._getSettingsSize(); i++) {
            u8array.push((<any>window).Module._getSettingsVal(i));
        }
        const settings = new TextDecoder().decode(new Uint8Array(u8array))
        window.localStorage.setItem(Module.settingsName, settings);
    }

    public instantiateWasm(imports: any, successCallback: any) {
        console.log('instantiateWasm: instantiating asynchronously');
        fetch("scale.wasm")
        .then((response) => response.arrayBuffer())
        .then((bytes) => {
            console.log('wasm download finished, begin instantiating');
            return WebAssembly.instantiate(new Uint8Array(bytes), imports);
        })
        .then((output) => {
            console.log('wasm instantiation succeeded');
            successCallback(output.instance);
            // Trigger a resize on load to ensure the correct canvas size
            window.dispatchEvent(new Event('resize'));
        }).catch((e) => {
            console.log('wasm instantiation failed! ' + e);
        });
        return {}; // Compiling asynchronously, no exports.
      }

    public print(t: string): void {
        console.log(t);
    };

    public printErr(text: string): void {
        text = Array.prototype.slice.call(arguments).join(' ');
        if (text == "info: save-settings") {
            Module.saveSettings();
            return;
        }
        console.error(text);
    }
    
    public canvas: HTMLCanvasElement = (() => {
        const e = <HTMLCanvasElement>document.getElementById("canvas");
        e?.addEventListener("webglcontextlost", (e => {
            alert("WebGL context lost. You will need to reload the page.");
            e.preventDefault();
        }), !1);
        return e;
    })();

    public setStatus(e: string): void {
        const statusElement = <HTMLElement>document.getElementById("status");
        statusElement.innerHTML = e;
    }

    public totalDependencies: number = 0;
    public monitorRunDependencies(e: number) {
        this.totalDependencies = Math.max(this.totalDependencies, e);
    }
}