export function initFS(module, cwd) {
  module.FS.mkdir(cwd)
  module.FS.currentPath = cwd
}

export function writeFileWithUint8ArrayData(module, path, data) {
  module.FS.writeFile(path, new Uint8Array(data))
}

export function getFileWithBlobData(module, path, type = 'image/webp') {
  return new Blob([module.FS.readFile(path).buffer], { type })
}

export function getFileWithFileData(module, path, type = 'image/webp') {
  return new File([getFileWithBlobData(module, path, type)], path, {
    type
  })
}
