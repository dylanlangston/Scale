mergeInto(LibraryManager.library, {
  WASMSave: function() {
    let u8array = [];
    for (let i = 0; i < Module._getSettingsSize(); i++) {
      u8array.push(Module._getSettingsVal(i));
    }
    const settings = new TextDecoder().decode(new Uint8Array(u8array))
    window.localStorage.setItem("settings", settings);
  },
  WASMLoad: function() {
    const settings = Module.getSettings() ?? 
      '{"CurrentResolution":{"Width":0,"Height":0},"TargetFPS":120,"Debug":false,"UserLocale":"english"}';
    const ptr = Module.allocateUTF8(settings);
    return ptr;
  },
  WASMLoaded: function(ptr) {
    Module._free(ptr);
  }
});