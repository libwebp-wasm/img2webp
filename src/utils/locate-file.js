export function initLocateFile(module, ext = '.wasm') {
  return {
    locateFile(path) {
      if (!path.endsWith(ext)) return path

      return module
    }
  }
}
