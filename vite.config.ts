/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2024-04-10 09:40:35
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2024-04-11 16:40:09
 * @FilePath: /gis-test/vite.config.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { viteStaticCopy } from "vite-plugin-static-copy";
import glsl from 'vite-plugin-glsl'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    viteStaticCopy({
      targets: [
        // 打包后拷贝包内所有插件，dev时将插件映射到dest位置
        {
          src: "node_modules/@gs3d/sdk/dist/lib/*",
          dest: "./lib",
        },
      ],
    }),
    glsl()
  ],

  resolve: {
    alias: {
      'cesium': fileURLToPath(new URL('./src/utils/gs3d/lib/CesiumChanged/index.js', import.meta.url)),
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  define: {
    // 模块化使用cesium时，需配置全局变量CESIUM_BASE_URL指向cesium包的四大资源文件夹
    CESIUM_BASE_URL: "'./lib/CesiumChanged'",
  },
})
