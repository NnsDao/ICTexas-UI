import {createRouter, createWebHashHistory} from 'vue-router'

import Login from './pages/Login/index.vue'
import Game from './pages/Game/index.vue'
import Room from './pages/Room/index.vue'
import NFT from './pages/NFT/index.vue'
import RoundStatistics from "./pages/NFT/RoundStatistics.vue";
import UserInfoDialog from './pages/NFT/UserInfoDialog.vue'
import Avatar from './pages/NFT/AvatorDialog.vue'
import Novice from "./pages/NFT/Novice.vue";
import {isAgentExpiration} from './utils/identity'
import TokenInfo from "./utils/token";
import GameInfo from "./utils/game";
import store from "./store";

const routes = [
    {path: '/', component: Login},
    {path: '/game', component: Game},
    {path: '/room', component: Room},
    {path: '/nft', component: NFT},
    {path: '/RoundStatistics', component: RoundStatistics},
    {path: '/Avatar', component: Avatar},
    {path: '/UserInfoDialog', component: UserInfoDialog},
    {path: '/Novice',component: Novice}


]

const router = createRouter({
    history: createWebHashHistory(),
    routes,
})

router.beforeEach(async (to, from, next) => {
    if (to.path === '/') {
        if (!await isAgentExpiration()) {
            await TokenInfo.Instance.login()
            await GameInfo.Instance.login()
            await store.dispatch("token/setTokenBasicInfo")
            await store.dispatch("user/setBalance")
            await store.dispatch("user/setNickname"),
                await store.dispatch("game/setGameSite")
            await store.dispatch("game/setUserStatus")

            if (store.state.game.userStatus == "notinseat") {
                next({path: '/room'})
            } else {
                next({path: '/game'})
            }
        } else {
            next()
        }
    }

    if (!TokenInfo.Instance.isLogin) {
        if (await isAgentExpiration()) {
            next({path: '/'})
        } else {
            await TokenInfo.Instance.login()
            await GameInfo.Instance.login()
            await store.dispatch("token/setTokenBasicInfo")
            await store.dispatch("user/setBalance")
            await store.dispatch("user/setNickname"),
                await store.dispatch("game/setGameSite")
            await store.dispatch("game/setUserStatus")

            if (store.state.game.userStatus == "notinseat") {
                next({path: '/room'})
            } else {
                next({path: '/game'})
            }
        }
    } else next()
})

export default router