import { defineConfig } from 'rollup'
import terser from '@rollup/plugin-terser'
import { nodeResolve } from '@rollup/plugin-node-resolve'

import {
  EXTERNALS as external,
  GLOBAL_NAME as globalName,
  LIBRARY_NAME as libraryName
} from './rollup.constant'

export default defineConfig(
  [
    // CommonJS
    { output: { file: `lib/${libraryName}.js`, format: 'cjs', indent: false } },
    // ES
    { output: { file: `es/${libraryName}.js`, format: 'es', indent: false } },
    // UMD Development
    {
      output: {
        file: `dist/${libraryName}.js`,
        format: 'umd',
        indent: false,
        name: globalName
      }
    },
    // UMD Production
    {
      output: {
        file: `dist/${libraryName}.min.js`,
        format: 'umd',
        indent: false,
        name: globalName
      },
      plugins: [
        terser({
          compress: { unsafe: true, pure_getters: true, unsafe_comps: true }
        })
      ]
    }
  ].map(({ plugins, ...rest }) => ({
    ...rest,
    external,
    input: 'src/index.js',
    plugins: [...(plugins || []), nodeResolve()]
  }))
)
