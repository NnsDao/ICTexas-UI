<template>
  <div class="game-board" @click.stop="colseMyaccount()">
    <div class="game-table">
      <div class="table">
        <img class="beauty-img" src="../../assets/game_board/img_beauty.png" />

        <template v-if="tableStatus === 'waitinguser'">
          <div class="ready-actions">
            <a-button
              size="large"
              type="primary"
              class="ready-btn"
              :class="{ disable: userStatus === 'inseatready' }"
              :loading="readyLoading"
              @click="userReady"
              :disabled="userStatus === 'inseatready'"
              >Ready</a-button
            >
            <a-button
              size="large"
              type="primary"
              class="getout-btn"
              :loading="getOutLoading"
              @click="userGetOut"
              >Get Out</a-button
            >
          </div>

          <wait-user
            :class="'user-' + user.siteIndex"
            :id="user.siteIndex"
            :account="user.account"
            :isReady="user.isReady"
            v-for="user in waitingUser"
            :key="user.account"
            :TimeEnd="user.needReadyBefore"
            :balance="
              typeof user.balance === 'undefined' ? '...' : user.balance
            "
            :message="user.message || ''"
          />
        </template>

        <template v-else>
          <div class="table-show">
            <div class="round">{{ gameInfo.currentRound }}</div>
            <div class="pot">POT {{ gameInfo.totalBets }}</div>
            <div class="flop"></div>
            <div class="public-cards">
              <card
                :type="type"
                v-for="type in gameInfo.boardCards"
                :key="type.index"
              />
            </div>
          </div>

          <operation
            v-if="gameInfo.currentActionUser === userInfo.address"
            class="operation-box"
          />

          <user
            :class="'user-' + user.siteIndex"
            :id="user.siteIndex"
            :account="user.account"
            :holeCards="user.holeCards"
            :bet="user.bet"
            :isSmallblind="user.isSmallblind"
            :isBigblind="user.isBigblind"
            :currentRoundAction="user.currentRoundAction"
            :currentRoundAmount="user.currentRoundAmount"
            v-for="user in userList"
            :key="user.account"
            :balance="
              typeof user.balance === 'undefined' ? '...' : user.balance
            "
            :isAllIn="user.isAllin"
            :isFold="user.isFold"
            :isOnline="user.isOnline"
            :message="user.message || ''"
          />
        </template>
      </div>
    </div>

    <div class="time-left">
      <div style="color: lightgreen" v-if="gameInfo.tableNo !== -1">
        TABLE {{ parseInt(gameInfo.tableNo) + 1 }}
      </div>
      <div
        :class="{ warn: timeLeft < 10 }"
        v-if="tableStatus !== 'waitinguser' && timeLeft !== 0"
      >
        Time Left: {{ timeLeft }}
      </div>
    </div>

    <div class="user-info">
      <a-button type="primary" class="history-btn" @click="showReward()">
        <template #icon><HistoryOutlined /></template>
        Last Game
      </a-button>

      <a-avatar size="large" class="user-btn" @click.stop="showMyaccount()">
        <template #icon><img :src="userInfo.avatorUrl" /></template>
      </a-avatar>
    </div>

    <my-account class="my-account" v-if="isShowAccount" />
    <Reward v-if="isShowReward" @close="closeReward" />
    <a-input-search
      class="input-message"
      v-model:value="message"
      placeholder="input message"
      enter-button="Send"
      size="large"
      @search="sendMessage"
    />
  </div>
</template>

<script>
import { defineComponent, onMounted, ref } from "vue";
import { mapGetters } from "vuex";
import Card from "./card.vue";
import User from "./user.vue";
import WaitUser from "./waitUser.vue";
import Operation from "./operation.vue";
import store from "../../store";
import Reward from "./reword.vue";
import GameInfo from "../../utils/game";
import TokenInfo from "../../utils/token";
import router from "../../router";
import { message } from "ant-design-vue";
import { HistoryOutlined } from "@ant-design/icons-vue";
import MyAccount from "../MyAccount/index.vue";
import { isAgentExpiration } from '../../utils/identity'

export default defineComponent({
  components: {
    Card,
    User,
    Operation,
    Reward,
    WaitUser,
    HistoryOutlined,
    MyAccount,
  },
  setup() {
    onMounted(async () => {
      await store.dispatch("game/setGameEnd");
      await store.dispatch("token/setTokenBasicInfo");
      await store.dispatch("user/setBalance");
      await store.dispatch("game/setGameSite");
      await Promise.all([
        store.dispatch("game/setUserStatus"),
        store.dispatch("game/setTableSatus"),
        store.dispatch("game/setLastGameReward"),
      ]);
      await store.dispatch("game/setUserBalance");
    });

    const timeLeft = ref(0);
    const isShowReward = ref(false);
    const closeReward = () => {
      isShowReward.value = false;
    };
    const showReward = () => {
      isShowReward.value = true;
    };

    const readyLoading = ref(false);
    const userReady = async () => {
      if (await !isAgentExpiration()) {
        message.info("Login has expired！");
        TokenInfo.Instance.logout();
        GameInfo.Instance.logout();
        router.push("/");
        return;
      }

      readyLoading.value = true;
      await GameInfo.Instance.userReadyPlay();
      readyLoading.value = false;
    };

    const getOutLoading = ref(false);
    const userGetOut = () => {
      getOutLoading.value = true;
      GameInfo.Instance.userGetUp();
      router.push("room");
      getOutLoading.value = false;
    };

    const isShowAccount = ref(false);
    const showMyaccount = () => {
      isShowAccount.value = !isShowAccount.value;
    };
    const colseMyaccount = () => {
      isShowAccount.value = false;
    };

    const message = ref("");
    const sendMessage = () => {
      if (!message.value.length) {
        return;
      }

      GameInfo.Instance.userSpeak(message.value);
      message.value = "";
    };

    return {
      isShowAccount,
      showMyaccount,
      colseMyaccount,

      readyLoading,
      userReady,

      getOutLoading,
      userGetOut,

      isShowReward,
      closeReward,
      showReward,

      message,
      sendMessage,

      timeLeft,
    };
  },
  data() {
    return {
      countDownInterval: null,
    };
  },
  watch: {
    tableStatus(to, from) {
      if (from == "waitinguser" && to == "ingame") {
        message.info("Game Start");
        store.dispatch("game/setUserBalance");
        this.createInterval();
      }

      if (from == "ingame" && to == "waitinguser") {
        clearInterval(this.countDownInterval);
        store.dispatch("game/setGameEnd");
        store.dispatch("game/setLastGameReward").then(() => {
          this.isShowReward = true;
        });
      }
    },

    userStatus(to) {
      if (to == "notinseat") {
        router.push("/room");
      }
    },

    currentRound(to) {
      message.info(`${to} Start`);
    },
  },
  methods: {
    createInterval() {
      this.countDownInterval = setInterval(() => {
        if (!this.gameInfo.currentActionBefore) {
          return;
        }

        let left = Math.floor(
          (this.gameInfo.currentActionBefore - new Date().getTime()) / 1000
        );

        if (left < 0) {
          GameInfo.Instance.userHeartBeat();
          left = 0;
        }

        this.timeLeft = left;
      }, 1000);
    },
  },
  computed: {
    ...mapGetters("token", ["tokenInfo"]),
    ...mapGetters("user", ["userInfo"]),
    ...mapGetters("game", [
      "siteInfo",
      "userStatus",
      "gameInfo",
      "totalUserCount",
      "readyUserCount",
      "tableStatus",
      "userList",
      "waitingUser",
      "currentRound",
    ]),
  },
});
</script>

<style scoped>
.game-board {
  width: 100%;
  height: 100vh;
  background-repeat: no-repeat;
  background-size: cover;
}

.game-table {
  width: 100%;
  height: 100%;

  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

@media screen and (max-width: 1000px) {
  .game-table {
    height: auto;
  }
}

.table {
  margin: 0 auto;
  width: 1000px;
  height: 500px;

  background-image: url("../../assets/game_board/bg_table.png");
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;

  position: relative;
}

.beauty-img {
  position: absolute;
  left: calc(50% - 90px);
  top: -105px;
  width: 200px;
  border-radius: 50px;
}

.table-show {
  color: white;
  margin-top: 80px;
  font-weight: bolder;
  font-family: monospace;
}

.round {
  font-size: 48px;
  line-height: 48px;
  margin-bottom: 10px;
}

.pot {
  font-size: 28px;
  line-height: 36px;
  margin-bottom: 20px;
}

.flop {
  font-size: 24px;
  line-height: 48px;
  margin-top: 10px;
}

.public-cards {
  margin-top: 10px;
  display: flex;
  width: 40%;
  margin: 0 auto;
  justify-content: space-between;
}

.user-1 {
  position: absolute;
  top: -100px;
  right: 200px;
}

.user-2 {
  position: absolute;
  top: -20px;
  right: 0px;
}

.user-3 {
  position: absolute;
  top: 150px;
  right: -20px;
}

.user-4 {
  position: absolute;
  top: 320px;
  right: 0px;
}

.user-5 {
  position: absolute;
  top: 390px;
  right: 250px;
}

.user-6 {
  position: absolute;
  top: 390px;
  left: 250px;
}

.user-7 {
  position: absolute;
  top: 320px;
  left: 0px;
}

.user-8 {
  position: absolute;
  top: 150px;
  left: -20px;
}

.user-9 {
  position: absolute;
  top: -20px;
  left: -20px;
}

.user-10 {
  position: absolute;
  top: -100px;
  left: 200px;
}

.operation-box {
  position: absolute;
  left: 300px;
  top: 240px;
  background: rgb(0, 0, 0, 0.4);
  box-shadow: rgba(0, 0, 0, 0.56) 0px 22px 70px 4px;
  z-index: 100;
  padding: 10px;
}

.ready-actions {
  position: absolute;
  top: 200px;
  left: 400px;
}

.ready-btn.disable {
  color: rgba(0, 0, 0, 0.25);
}

.ready-btn,
.getout-btn {
  width: 100px;
  font-weight: bolder;
  color: #fff;
}

.ready-btn {
  margin-right: 20px;
}

.history-btn {
  margin-right: 20px;
}

.my-account {
  position: absolute;
  right: 20px;
  top: 80px;
}

.time-left {
  position: absolute;
  top: 20px;
  left: 40px;

  font-weight: bolder;
  color: #fff;
  font-size: 28px;
  text-align: left;
}

.time-left.warn {
  color: red;
}

.user-info {
  position: fixed;
  top: 20px;
  right: 40px;

  display: flex;
  align-items: center;
}

.input-message {
  position: fixed;
  left: 10px;
  bottom: 10px;
  width: 300px;
}
</style>