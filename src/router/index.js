import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

  const routes = [
  {
    path: '/',
    redirect: 'Staking'
  },
  {
    path: '/staking',
    name: 'Staking',
    component: () => import('../views/Staking.vue')
  },
  {
    path: '/farming',
    name: 'Farming',
    component: () => import('../views/Farming.vue')
  }
]

const router = new VueRouter({
  routes
})

export default router
