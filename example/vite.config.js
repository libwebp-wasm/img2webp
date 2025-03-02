import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import vitePluginImp from 'vite-plugin-imp'

import { BASE } from './vite.constant'
import { isProd } from './vite.helper'

// https://vitejs.dev/config/
export default ({ mode }) =>
  defineConfig({
    plugins: [
      react(),
      vitePluginImp({
        libList: [{ libName: 'antd', style: (name) => `antd/es/${name}/style` }]
      })
    ],
    css: {
      preprocessorOptions: {
        less: { javascriptEnabled: true }
      }
    },
    // https://stackoverflow.com/questions/71462201/how-to-fix-the-asset-file-path-in-my-vue-vite-application-build
    ...(isProd(mode) ? { base: BASE } : null)
  })
