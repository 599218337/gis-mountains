/*
 * @Author: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @Date: 2024-04-10 09:40:35
 * @LastEditors: lzz 599218337@qq.com
 * @LastEditTime: 2024-04-14 16:54:01
 * @FilePath: /gis-test/src/main.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import locale from 'element-plus/es/locale/lang/zh-cn' //ElementPlus中文语言包


const app = createApp(App)

app.use(ElementPlus, { locale })
app.mount('#app')


declare global {
  interface Window {
    Cesium: any,
  }
}