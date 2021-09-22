import store from './store'
import TokenInfo from './utils/token'
import GameInfo  from './utils/game'
import { isAgentExpiration } from './utils/identity'

const isInTable = () => {
    return window.location.hash.indexOf("game") !== -1
}


const syncBalance = async () => {
    if (TokenInfo.Instance.isLogin) {
        const expires = await isAgentExpiration()
        if (!expires) {
            store.dispatch("user/setBalance");
        }
    }
}

const syncGameUserBalance = async () => {
    if (!isInTable()) {
        return
    }

    if (TokenInfo.Instance.isLogin) {
        const expires = await isAgentExpiration()
        if (!expires) {
            store.dispatch("game/setUserBalance");
            store.dispatch("game/setUserAlias", true);
        }
    }
}

const syncTableState = async () => {
    if (!isInTable()) {
        return
    }

    if (TokenInfo.Instance.isLogin) {
        const expires = await isAgentExpiration()
        if (!expires) {
            await store.dispatch("game/setUserStatus")
            await store.dispatch("game/setTableSatus")
        }
    }
}

const heartBeat = async () => {
    if (!isInTable()) {
        return
    }

    GameInfo.Instance.userHeartBeat()
}

const randomInt = (30 + Math.floor(Math.random() * 30)) * 1000
const Schedual = {
    10000: [
        syncBalance,
        syncGameUserBalance
    ],
    3000: [
        syncTableState
    ]
}
Schedual[randomInt] = [ heartBeat ]

Object.keys(Schedual).forEach(interval => {
    Schedual[interval].forEach((fn) => {
        setInterval(fn, parseInt(interval))
    })
})