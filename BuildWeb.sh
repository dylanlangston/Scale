echo Install emscripten
./src/emscripten/emsdk install latest 1> /dev/null
echo Activate emscripten
./src/emscripten/emsdk activate latest 1> /dev/null

echo Build Started
if zig build -Dtarget=wasm32-emscripten --sysroot $(realpath ./src/emscripten/upstream/emscripten) ; then
    echo Build Succeded
else
    echo Build Failed
fi