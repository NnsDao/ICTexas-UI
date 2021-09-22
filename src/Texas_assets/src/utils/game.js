

import TokenInfo from './token'
import { Actor } from '@dfinity/agent';
import { idlFactory as texas_idl, canisterId as texas_id } from 'dfx-generated/texas';
import { getHttpAgent } from "./identity";
import { divisionBigInt, multipBigInt, diffArray } from './index'
import { message } from 'ant-design-vue';

export default class GameInfo {
  static RoundMap = {
    preflop: 0,
    flop: 1,
    turn: 2,
    river: 3
  }

  static ChatHistory = {

  }

  static Instance = new GameInfo()

  constructor() {
    this.isLogin = false
  }

  async login() {
    if (!this.isLogin) {
      this.agent = await getHttpAgent()
      this.isLogin = true
      this.game = Actor.createActor(texas_idl, { agent: this.agent, canisterId: texas_id })
      this.selfAccount = await TokenInfo.Instance.getSelfAddress()
    }
  }

  async gamingSites() {
    const siteList = []
    const siteInfo = await this.game.gamingSites()
    siteInfo.forEach((site) => {
      const kind = Object.keys(site[0])[0]
      if (!kind) {
        return
      }
      siteList.push({
        'level': kind,
        'limit': divisionBigInt(site[1], TokenInfo.Instance.decimals),
        'blind': divisionBigInt(site[2], TokenInfo.Instance.decimals),
      })
    })

    return siteList.reverse()
  }

  async userStatus() {
    const user = {}
    let ustate = await this.game.userStatus()
    if (ustate.notinseat !== undefined) {
      user.state = 'notinseat'
      return user
    }

    if (ustate.inseat) {
      user.state = 'inseat'
      ustate = ustate.inseat
    } else if (ustate.inseatready) {
      user.state = 'inseatready'
      ustate = ustate.inseatready
    } else {
      user.state = 'ingame'
      ustate = ustate.ingame
    }
    user.siteType = Object.keys(ustate.site)[0]
    user.tableNo = ustate.table
    user.sitdownAt = divisionBigInt(ustate.sitdownAt, 1000000)
    user.needReadyBefore = divisionBigInt(ustate.needReadyBefore, 1000000)
    return user
  }

  async userSitdown(siteType) {
    try {
      const siteParam = {}
      siteParam[siteType] = null
      return await this.game.userSitdown(siteParam)
    } catch (e) {
      return [false, e]
    } 
  }  
  
  async userReadyPlay() {
    try {
      return await this.game.userReadyPlay()
    } catch (e) {
      return [false, e]
    } 
  }

  async userGetUp() {
    return await this.game.userGetUp()
  }

  getSiteMapIndex(selfIndex, users) {
    return
    if (selfIndex > 5) {
      for (let i = 0; i < selfIndex - 4; i++) {
        users.push(users.shift())
      }
    } else {
      for (let i = 0; i < 4 - selfIndex; i++) {
        users.unshift(users.pop())
      }
    }
  }

  getUserBet(arounds) {
    let bet = 0
    arounds.forEach((around) => {
      around.forEach((aaction) => {
        bet += divisionBigInt(Object.values(aaction)[0], TokenInfo.Instance.decimals)
      })

    })
    return bet
  }

  getUserAction(arounds) {
    const action = []
    arounds.forEach((around) => {
      let roundAction = []
      around.forEach((aaction) => {
        roundAction.push({
          action: Object.keys(aaction)[0],
          amount: divisionBigInt(Object.values(aaction)[0], TokenInfo.Instance.decimals)
        })
      })
      action.push(roundAction)
    })
    return action
  }

  getCurrentActionCan(currentActionCan) {
    let action = {}
    currentActionCan.forEach((item) => {
      const key = Object.keys(item)[0]
      const value = Object.values(item)[0]
      action[key] = divisionBigInt(value, TokenInfo.Instance.decimals)
    })
    return action
  }

  getMessage(account, userSpeak) {
    if (!userSpeak || !account) return ""
    
    const speakIndex = Number(userSpeak.lastSpeakIndex)
    if (GameInfo.ChatHistory[account] !== speakIndex) {
      GameInfo.ChatHistory[account] = speakIndex
      return userSpeak.lastSpeak
    } else {
      return ""
    }
  }

  async tableStatus(type, tableNo) {
    const tableResult = {}
    const typeParam = {}
    typeParam[type] = null
    let table = await this.game.tableStatus(typeParam, tableNo)

    if (!table || !table.length ) {
      return tableResult
    }

    table = table[0]
    if (table.waitinguser) {
      tableResult.state = 'waitinguser'
      tableResult.data = {
        waitinguser: []
      }

      const users = table.waitinguser
      if (users.length === 0) {
        return tableResult
      }

      const waitinguser = []
      let selfIndex = 0
      // users.some(([user], index) => {
      //   if (user && user.account === this.selfAccount) {
      //     selfIndex = index
      //     return true
      //   }
      // })

      this.getSiteMapIndex(selfIndex, users)
      users.forEach(([user], index) => {
        if (user) {
          waitinguser.push({
            siteIndex: index + 1,
            account: user.account,
            isReady: user.isReady,
            needReadyBefore: divisionBigInt(user.needReadyBefore, 1000000),
            sitdownAt: divisionBigInt(user.sitdownAt, 1000000),
            message: this.getMessage(user.account, user.userSpeak)
          })
        }
      })
      tableResult.data = {
        waitinguser: waitinguser
      }
    } else if (table.ingame) {
      tableResult.state = 'ingame'
      const currentRound = Object.keys(table.ingame.currentRound)[0]
      const users = table.ingame.users

      let selfIndex = 0
      // users.some(([user], index) => {
      //   if (user && user.account === this.selfAccount) {
      //     selfIndex = index
      //     return true
      //   }
      // })

      this.getSiteMapIndex(selfIndex, users)
      users.forEach(([user], index) => {
        if (!user) return
        user.siteIndex = index + 1
        user.holeCards = user.holeCards.length ? user.holeCards : ['back', 'back']
        user.bet = this.getUserBet(user.roundActions)
        user.actions = this.getUserAction(user.roundActions)
        user.isSmallblind = user.actions[0] && user.actions[0][0] && user.actions[0][0].action === "smallblind"
        user.isBigblind = user.actions[0]  && user.actions[0][0] && user.actions[0][0].action === "bigblind"
        user.message = this.getMessage(user.account, user.userSpeak)

        const currentRoundActions = user.actions[GameInfo.RoundMap[currentRound]]
        if (currentRoundActions && currentRoundActions.length > 0) {
          const currentRoundLastAction = currentRoundActions[currentRoundActions.length - 1]
          user.currentRoundAction = currentRoundLastAction.action
          user.currentRoundAmount = currentRoundLastAction.amount
        } else {
          user.currentRoundAction = null
          user.currentRoundAmount = null
        }
      })

      tableResult.data = {
        boardCards: [...table.ingame.boardCards, ...Array(5 - table.ingame.boardCards.length).fill("back")],
        currentActionUser: table.ingame.currentActionUser,
        currentActionBefore: divisionBigInt(table.ingame.currentActionBefore, 1000000),
        currentActionCan: this.getCurrentActionCan(table.ingame.currentActionCan),
        currentActionSeq: table.ingame.currentActionSeq,
        currentRound: currentRound,
        totalBets: divisionBigInt(table.ingame.totalBets, TokenInfo.Instance.decimals),
        users: users.filter(item => { return item[0] && item[0].account }).map(item => { return item[0] })
      }
    }

    return tableResult
  }

  async userAction(action, amount, seq) {
    try {
      const actionParam = {}
      actionParam[action] = multipBigInt(amount, TokenInfo.Instance.decimals)
      return await this.game.userAction(actionParam, seq)
    } catch (e) {
      console.log(e)
      return false
    }
  }

  async userHeartBeat() {
    try {
      return await this.game.userHeartBeat()
    } catch (e) {
      console.log(e)
      return false
    }
  }

  async lastGameRewardsOfTable(tableType, tableNo) {
    const rewards = []
    try {
      const tableParam = {}
      tableParam[tableType] = null
      const users = await this.game.lastGameRewardsOfTable(tableParam, tableNo)
    
      if (users.length > 0 && users[0].length > 0) {
        users[0].sort((users1, users2) => {
          if (Number(users2.score) === Number(users1.score)) {
            return Number(users2.reward) - Number(users1.reward)
          }
          return Number(users2.score) - Number(users1.score)
        })
        users[0].forEach((user, index) => {
          const totalCards = user.boardCards.concat(user.holeCards)
          const cardType = Object.keys(user.cardsType)[0]
          rewards.push({
            account: user.account,
            reward: divisionBigInt(user.reward, TokenInfo.Instance.decimals),
            rank: index,
            cards: [...user.cards, ...Array(5 - user.cards.length).fill("back")],
            resetCards: diffArray(totalCards, user.cards),
            type: cardType === "nonetype" ? "": cardType,
            isFold: user.actions.some((action) => {
              return action.indexOf("fold") !== -1
            }),
            isAllIn : user.actions.some((action) => {
              return action.join().indexOf("allin") !== -1
            })
          })
        })
      }

      return rewards
    } catch (e) {
      console.log(e)
      return rewards
    } 
  }

  async setAlias(name) {
    try {
      return await this.game.setAlias(name)
    } catch {
      return [false, "setAlias Error"]
    }
  }

  async setAvatar(url) {
    try {
      return await this.game.setAvatar(url)
    } catch {
      return [false, "setAvatar Error"]
    }
  }

  async userInfo(address) {
    const result = {}
    const infos = await this.game.userInfo(address)
    infos.forEach(info => {
      result[info['address']] = info
    })
    return result
  }

  async userInfos(addressList) {
    const result = {}
    const infos = await this.game.userInfos(addressList)
    if (infos.length !== 0) {
      infos.forEach(([info]) => {
        result[info['address']] = info
      })
    }
  
    return result
  }

  async userSpeak(message) {
    try {
      this.game.userSpeak(message)
    } catch (e) {
      console.log(e)
    }
  }

  async logout() {
    this.isLogin = false
  }
}

window.game = GameInfo.Instance;
window.chat = GameInfo.ChatHistory;