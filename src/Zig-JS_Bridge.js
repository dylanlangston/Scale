mergeInto(LibraryManager.library, {
  WASMSave: function() {
    let u8array = [];
    for (let i = 0; i < Module._getSettingsSize(); i++) {
      u8array.push(Module._getSettingsVal(i));
    }
    const settings = new TextDecoder().decode(new Uint8Array(u8array))
    window.localStorage.setItem("settings", settings);
  }
});