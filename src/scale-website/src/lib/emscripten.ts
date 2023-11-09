export class Module {
    public print(t: string): void {
        console.log(t);
    };
    
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