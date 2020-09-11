import Vue from 'vue'
import App from './App.vue'
import './registerServiceWorker'
import router from './router'
import store from './store'
import vuetify from './plugins/vuetify';
import Loading from 'vue-loading-overlay';

import 'vue-loading-overlay/dist/vue-loading.css';
Vue.config.productionTip = false
Vue.component ('loading', Loading);

new Vue({
  router,
  store,
  vuetify,
  render: h => h(App)
}).$mount('#app')
