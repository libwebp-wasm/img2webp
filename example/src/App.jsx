import { useRef, useState, useCallback } from 'react'
import { Input, Button } from 'antd'
import {
  initFS,
  Img2Webp,
  runImg2Webp,
  initLocateFile,
  getFileWithBlobData,
  writeFileWithUint8ArrayData
} from '@libwebp-wasm/img2webp'
import img2webp from '@libwebp-wasm/img2webp/lib/img2webp.wasm?url'

export default function App() {
  const fileRef = useRef(null)
  const [url, setUrl] = useState('')

  const handleTransform = useCallback(() => {
    const files = fileRef.current
    if (!files || !files.length) return

    Img2Webp({
      ...initLocateFile(img2webp)
    }).then((instance) => {
      Promise.all(
        Array.from(files).map(
          (file) =>
            new Promise((resolve, reject) => {
              const fileReader = new FileReader()

              fileReader.onload = ({ target: { result } }) => {
                resolve({ file, result })
              }
              fileReader.onerror = () => reject(new Error('fileReader error'))

              fileReader.readAsArrayBuffer(file)
            })
        )
      ).then((results) => {
        initFS(instance, '/img2webp')

        results.forEach(({ file, result }) => {
          writeFileWithUint8ArrayData(instance, file.name, result)
        })

        const targetName = 'foobar.webp'

        runImg2Webp(
          instance,
          '_main',
          '-d',
          `${Math.trunc((10 * 1000) / results.length)}`,
          '-loop',
          '0',
          ...results.map(({ file: { name } }) => name),
          '-o',
          targetName
        )

        setUrl(URL.createObjectURL(getFileWithBlobData(instance, targetName)))
      })
    })
  }, [])
  const handleFileChange = useCallback(({ target: { files } }) => {
    fileRef.current = files
  }, [])

  return (
    <div className='App'>
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <Input
          multiple
          type='file'
          bordered={false}
          style={{ width: 200 }}
          onChange={handleFileChange}
        />
        <Button type='primary' onClick={handleTransform}>
          Transform
        </Button>
      </div>
      <output
        hidden={!url}
        style={{ display: 'block', width: 412, paddingLeft: 11, paddingTop: 7 }}
      >
        <img src={url} style={{ width: '100%' }} />
      </output>
    </div>
  )
}
