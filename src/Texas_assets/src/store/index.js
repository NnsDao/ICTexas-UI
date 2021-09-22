import { createStore, createLogger } from 'vuex'
import user from './modules/user'
import token from './modules/token'
import game from './modules/game'

const debug = process.env.NODE_ENV !== 'production'

export default createStore({
  modules: {
    user,
    token,
    game
  },
  strict: debug,
  plugins: debug ? [createLogger()] : []
})