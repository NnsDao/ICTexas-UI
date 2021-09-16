

import TokenInfo from '../../utils/token'

const state = () => ({
    name: '',
    symbol: '',
    createTime: '',
    totalMint: 0,
    feePercent: 0,
    decimals: 0,
})

const getters = {
    tokenInfo: (state) => state
}

const actions = {
    async setTokenBasicInfo({ commit }) {
        if (state.name && state.symbol) {
            return
        }
        
        const token = TokenInfo.Instance
        await token.setTokenInfo()
        commit('setName', token.name)
        commit('setSymbol', token.symbol)
        commit('setTotalMint', token.totalMint)
        commit('setCreateTime', token.createTime)
        commit('setFeePercent', token.feePercent)
        commit('setDecimals', token.decimals)
    }
}

const mutations = {
    setName(state, name) {
        state.name = name
    },

    setSymbol(state, symbol) {
        state.symbol = symbol
    },

    setTotalMint(state, totalMint) {
        state.totalMint = totalMint
    },

    setCreateTime(state, createTime) {
        state.createTime = createTime
    },

    setFeePercent(state, feePercent) {
        state.feePercent = feePercent
    },

    setDecimals(state, decimals) {
        state.decimals = decimals
    }
}

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations
}