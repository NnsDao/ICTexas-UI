import TokenInfo from '../../utils/token'
import GameInfo from '../../utils/game'
 
const state = () => ({
  name: '',
  address: '',
  balance: 0,
  principal: '',
  nickName: '',
  avatorUrl: ''
})

const getters = {
    userInfo: (state) => state
}

const actions = {
  setPrincipal({ commit }, principal) {
    commit('setPrincipal', principal)
  },

  async setAddress({ commit }) {
    const address =  await TokenInfo.Instance.getSelfAddress()
    commit('setAddress', address)
  },

  async setBalance({ dispatch, commit, state }) {
    if (!state.address) {
      await dispatch('setAddress')
    }

    const address =  await TokenInfo.Instance.getBalance(state.address)
    commit('setBalance', address)
  },

  async setNickname({ dispatch, commit, state }) { 
    if (!state.address) {
      await dispatch('setAddress')
    }

    const info =  await GameInfo.Instance.userInfo(state.address)
    commit('setNickname', info[state.address] ? info[state.address].alias : "")
    commit('setAvator', info[state.address] ? info[state.address].avatar : "")
  },
}

const mutations = {
  setPrincipal(state, principal) {
    state.principal = principal
  },

  setAddress(state, address) {
    state.address = address
  },

  setBalance(state, balance) {
    state.balance = balance
  },

  setNickname(state, nickName) {
    state.nickName = nickName
  },

  setAvator(state, avator) {
    if (!avator) {
      state.avatorUrl = window.localStorage.getItem("avatar_5")
      return
    }
    state.avatorUrl = avator
  }
}

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations
}