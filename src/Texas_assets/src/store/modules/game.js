import GameInfo from '../../utils/game'
import TokenInfo from '../../utils/token'
import { reactive } from 'vue'

const RoundMap = {
    preflop: 1,
    flop: 2,
    river: 3,
    turn: 4
}

const SiteMap = {
    low: 0,
    mid: 1,
    high: 2,
}

const state = () => ({
  userStatus: 'notinseat',
  tableStatus: 'waitinguser',
  siteType: '',
  tableNo: -1,
  roundNo: '',
  roundType: '',
  currentActionCan: reactive({}),
  boardCards: reactive([]),
  currentRound: '',
  currentActionUser: '',
  totalBets: 0,
  siteTime: 0,
  userList: reactive([]),
  siteInfo: reactive([]),
  waitingUser: reactive([]),
  totalUserCount: 0,
  readyUserCount: 0,
  smallblind: 0,
  bigblind: 0,
  lastGameReward: reactive([]),
  currentActionBefore: 0,
  currentActionSeq: 0,
  userInfos: reactive({}),
})

const getters = {
    userStatus: (state) => state.userStatus,
    tableStatus: (state) => state.tableStatus,
    userList: (state) => state.userList,

    siteInfo: (state) => state.siteInfo,
    totalUserCount: (state) => state.totalUserCount,
    readyUserCount: (state) => state.readyUserCount,
    waitingUser: (state) => state.waitingUser,
    currentRound: (state) => state.currentRound,
    gameInfo: (state) => state
}

const actions = {
    async setGameSite({ commit, state }) {
        if (state.siteInfo.length) {
            return
        }

        await GameInfo.Instance.login()
        const siteInfo = await GameInfo.Instance.gamingSites()
        commit('setSiteInfo', siteInfo)
    },

    async setUserStatus({ commit, state, dispatch }) {
        await GameInfo.Instance.login()

        if (!state.siteInfo.length) {
            await dispatch('setGameSite')
        }

        const user = await GameInfo.Instance.userStatus()
        commit('setUserStatus', user.state)
        if (user.state !== "notinseat") {
            commit('setSiteType', user.siteType)
            commit('setTableNo', user.tableNo)
            commit('setSiteTime', user.siteTime)
            commit('setBlind', state.siteInfo[SiteMap[user.siteType]].blind)
        }
    },

    async setTableSatus({ dispatch, commit, state }) {
        if (!state.siteType || state.tableNo === -1 ) {
            return
        }   
        const table = await GameInfo.Instance.tableStatus(state.siteType, state.tableNo)
        commit('setTableStatus', table.state)
        if (table.state === 'waitinguser') {
            commit('setWaitingUsers', table.data.waitinguser)
            dispatch('setUserAlias')
        } else if(table.state === 'ingame') {
            commit('setBoardCards', table.data.boardCards)
            commit('setTotalBets', table.data.totalBets)
            commit('setCurrentRound', table.data.currentRound)
            commit('setCurrentActionUser', table.data.currentActionUser)
            commit('setCurrentActionCan', table.data.currentActionCan)
            commit('setCurrentActionBefore', table.data.currentActionBefore)
            commit('setCurrentActionSeq', table.data.currentActionSeq)
            commit('setUsers', table.data.users)
        }
    },

    async setLastGameReward({ commit, state }) {
        const result = await GameInfo.Instance.lastGameRewardsOfTable(state.siteType, state.tableNo)
        commit('setLastGameReward', result)
    },

    async setUserBalance({ state }) {
        if (state.tableStatus === 'waitinguser') {
            for (let index = 0; index < state.waitingUser.length; index++) {
                const userItem = state.waitingUser[index]
                const balance = await TokenInfo.Instance.getBalance(userItem.account)
                if (state.waitingUser[index] && state.waitingUser[index].account === userItem.account) {
                    state.waitingUser[index].balance = balance
                }
            }
        } else {
            for (let index = 0; index < state.userList.length; index++) {
                const userItem = state.userList[index]
                const balance = await TokenInfo.Instance.getBalance(userItem.account)
                if (state.userList[index] && state.userList[index].account === userItem.account) {
                    state.userList[index].balance = balance
                }
            }
        }
    },

    async setUserAlias({ state }, forceRefresh = false) {
        let addressList = []
        if (forceRefresh) {
            addressList = state.waitingUser.map(user => user.account)
            addressList.concat(state.userList.map(user => user.account))
        } else {
            addressList = state.waitingUser.map(user => user.account).filter(address => !state.userInfos[address])
            addressList.concat(state.userList.map(user => user.account)).filter(address => !state.userInfos[address])
        }
        
        if (addressList.length) {
            const userInfos = await GameInfo.Instance.userInfos(addressList)
            Object.assign(state.userInfos, userInfos)
        }
    },
 
    setGameEnd({ state }) {
        state.userList.length = 0
        state.waitingUser.length = 0
        state.tableStatus = "waitinguser"
        state.currentActionBefore = null
        state.boardCards.length = 0
    }
}

const mutations = {
    setSiteInfo(state, siteInfo) {
        state.siteInfo = siteInfo
    },

    setUserStatus(state, userStatus) {
        state.userStatus = userStatus
    },

    setSiteType(state, siteType) {
        state.siteType = siteType
    },

    setRoundNo(state, roundNo) {
        state.roundNo = roundNo
    },

    setTableNo(state, tableNo) {
        state.tableNo = tableNo
    },

    setSiteTime(state, siteTime) {
        state.siteTime = siteTime
    },

    setTableStatus(state, tableStatus) {
        state.tableStatus = tableStatus
    },

    setTotalUserCount(state, totalUserCount) {
        state.totalUserCount = totalUserCount
    },

    setReadyUserCount(state, readyUserCount) {
        state.readyUserCount = readyUserCount
    },

    setBoardCards(state, boardCards) {
        state.boardCards = boardCards
    },

    setTotalBets(state, totalBets) {
        state.totalBets = totalBets
    },

    setCurrentRound(state, currentRound) {
        state.currentRound = currentRound
        state.roundNo = RoundMap[currentRound]
    },

    setCurrentActionUser(state, currentActionUser) {
        state.currentActionUser = currentActionUser
    },

    setBlind(state, blind) {
        state.smallblind = blind
        state.bigblind = blind * 2
    },

    setCurrentActionCan(state, currentActionCan) {
        state.currentActionCan = currentActionCan
    },

    setLastGameReward(state, lastGameReward) {
        state.lastGameReward = lastGameReward
    },

    setCurrentActionBefore(state, currentActionBefore) {
        state.currentActionBefore = currentActionBefore
    },
    
    setWaitingUsers(state, waitingUser) {
        const balanceMap = {}
        state.waitingUser.forEach(user => {
            balanceMap[user.account] = user.balance
        })

        state.waitingUser.length = 0
        waitingUser.forEach(user => {
            user.balance = balanceMap[user.account]
            state.waitingUser.push(user)
        })
    },

    setUser(state, user) {
        let newUser = true
        state.userList.some((userItem) => {
            if (userItem.account === user.account) {
                Object.assign(userItem, user)
                newUser = false
                return true
            }
        })

        if (newUser) {
            state.userList.push(user)
        }
    },

    setUsers(state, users) {
        users.forEach(user => {
            let newUser = true
            state.userList.some((userItem, index) => {
                if (userItem.account === user.account) {
                    Object.assign(state.userList[index], user)
                    newUser = false
                    return true
                }
            })

            if (newUser) {
                state.userList.push(user)
            }
        })
    },

    setGameUserBalance(state, userIndex, balance) {
        state.userList[userIndex].balance = balance
    },

    setWaitUserBalance(state, userIndex, balance) {
        state.waitingUser[userIndex].balance = balance
    },

    setCurrentActionSeq(state, currentActionSeq) {
        state.currentActionSeq = currentActionSeq
    }
}

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations
}