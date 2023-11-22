export class Module {

    public requestFullscreen?: (lockPointer: boolean, resizeCanvas: boolean) => void;
    public _updateWasmResolution?: (width: number, height: number) => void;
    public _getSettingsSize?: () => number;
    public _getSettingsVal?: (location: number) => number;
    public _js_key_pressed?: (location: number) => void;
    public _js_key_released?: (location: number) => void;

    public preRun(mod: Module): void {
        mod.arguments.forEach(arg => console.log("arg: " + arg));
        mod.arguments.splice(1, 0, Module.getSettings()!);
    }

    private _Initialized: boolean = false; 
    public get Initialized(): boolean {
        return this._Initialized;
    }

    public onRuntimeInitialized(): void {
        this._Initialized = true;
        
        document.getElementById("controls")?.classList.remove("hidden");

        // Trigger a resize on load to ensure the correct canvas size
        window.dispatchEvent(new Event('resize'));
    }

    public arguments: string[] = [
        "./this.program"
    ];

    private static settingsName: string = "settings";
    private static getSettings(): string {
        return window.localStorage.getItem(Module.settingsName) ?? "{}";
    }
    private static saveSettings() {
        let u8array = [];
        for (let i = 0; i < (<any>window).Module._getSettingsSize(); i++) {
            u8array.push((<any>window).Module._getSettingsVal(i));
        }
        const settings = new TextDecoder().decode(new Uint8Array(u8array))
        window.localStorage.setItem(Module.settingsName, settings);
    }

    public static updateSettingsFromQueryString(): boolean {
        const oldSettings = Module.getSettings();
        if (window.location.search.length == 0) return false;

        try
        {
            Module.setStatus("Updating Settings...");
            const settings = JSON.parse(oldSettings);

            const queryString = window.location.search;
            const urlParams = new URLSearchParams(queryString);
    
            const getValue = (v: string) => {
                try 
                {
                    return JSON.parse(v);
                }
                catch 
                {
                    return v;
                }
            };
    
            urlParams.forEach((value, key) => {
              settings[key] = getValue(value);
            });
    
            const newSettings = JSON.stringify(settings);
            window.localStorage.setItem(Module.settingsName, newSettings);
            return true;
        }
        catch 
        {
            return false;
        }

    }

    public instantiateWasm(imports: any, successCallback: any) {
        console.log('instantiateWasm: instantiating asynchronously');
        fetch("scale.wasm", { 
            cache: "default",
        })
        .then((response) => response.arrayBuffer())
        .then((bytes) => {
            console.log('wasm download finished, begin instantiating');
            return WebAssembly.instantiate(new Uint8Array(bytes), imports);
        })
        .then((output) => {
            console.log('wasm instantiation succeeded');
            successCallback(output.instance);
        }).catch((e) => {
            Module.setStatus('wasm instantiation failed! ' + e);
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
        Module.setStatus(e);
    }
    public static setStatus(e: string): void {
        const statusElement = <HTMLElement>document.getElementById("status");
        const statusContainerElement = document.getElementById("status-container");
        statusContainerElement!.hidden = (e.length == 0 || e == null || e == undefined);
        statusElement.innerText = e;
    }

    public totalDependencies: number = 0;
    public monitorRunDependencies(e: number) {
        this.totalDependencies = Math.max(this.totalDependencies, e);
    }
}