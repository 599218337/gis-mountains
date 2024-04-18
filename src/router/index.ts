/*
 * @Author: lzz 599218337@qq.com
 * @Date: 2024-04-17 11:21:02
 * @LastEditors: lzz 599218337@qq.com
 * @LastEditTime: 2024-04-17 15:40:03
 * @FilePath: /gis-test/src/router/index.ts
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'index',
    component: () => import('@/views/index.vue')
  },
  {
    path: '/BI',
    name: 'BI',
    component: () => import('@/views/BI.vue')
  },
]

const router = createRouter({
  history: createWebHistory('/'),  // 设置为history模式，就是路径里面没有#,  createWebHashHistory 是默认的，括号里面的就是基础路径，可以理解为项目名称，就是请求路径的基础url
  routes
})

export default router