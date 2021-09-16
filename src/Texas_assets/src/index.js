import { createApp } from 'vue'
import Antd from 'ant-design-vue';
import 'ant-design-vue/dist/antd.css';
import App from './App.vue'
import store from './store'
import router from './router'
import './schedual'
import './imgPreloader'

const app = createApp(App)
app.config.productionTip = false

app.use(Antd)
app.use(store)
app.use(router)
app.mount('#app')