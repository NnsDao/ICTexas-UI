<template>
  <!-- <div :id="'user' + id" :class="{ left: isLeft, right: !isLeft }">
    <div class="two-cards">
      <card
        :class="'cards-' + (index + 1)"
        :type="card"
        v-for="(card, index) in holeCards"
        :key="index"
      />

      <img class="avatar-box" :src="avatarBox" alt="" srcset="" />
      <img class="avatar-icon" :src="avatorUrl" alt="" srcset="" />
      <img class="name-box" :src="nameBox" alt="" srcset="" />
      <img class="action-box" :src="actionBox" alt="" srcset="" />
      <div class="action-amout" v-if="currentRoundAction">
        +{{ currentRoundAmount }}
      </div>

      <div class="dot-box">
        <template v-if="isMe">
          <HomeFilled :style="{ fontSize: '14px', color: 'lightgreen' }" />
        </template>

        <template v-if="!isMe && isOnline">
          <div class="green-dot"></div>
          <div class="green-dot"></div>
        </template>

        <template v-if="!isMe && !isOnline">
          <div class="gray-dot"></div>
          <div class="gray-dot"></div>
        </template>
      </div>

      <div class="chips-box">
        <img
          class="chips-icon"
          src="../../assets/game_board/chips.png"
          alt=""
          srcset=""
        />

        <div class="bet">{{ bet }}</div>
      </div>

      <a-tooltip
        :title="message"
        placement="topLeft"
        color="green"
        :visible="message !== ''"
      >
        <div class="text-box" @click="copyAddress">
          <div class="name">
            {{
              gameInfo.userInfos[account]
                ? gameInfo.userInfos[account].alias
                : account.substr(0, 5) + "..."
            }}
          </div>
          <div class="score">{{ balance }}</div>
        </div>
      </a-tooltip>

      <div class="blind" v-if="isSmallblind">SB: {{ gameInfo.smallblind }}</div>
      <div class="blind" v-if="isBigblind">BB: {{ gameInfo.bigblind }}</div>
    </div>
  </div>-->
  
  <a-tooltip :title="message" placement="topLeft" color="green" :visible="message !== ''">
    <div class="user">
      <div :class="[ isMe  ? 'my-cards': 'other-cards']" :id="'cards-' + id" style="z-index:99">
        <div
          :class="['card-' + (index + 1), 'card']"
          v-for="(card, index) in holeCards"
          :key="index"
        >
          <card :type="card" />
        </div>
      </div>

      <div :class="[ !waitingAction  ? '': 'avatar-acting']" style="z-index:99">
        <div class="avatar">
          <img :src="avatorUrl" alt srcset />
        </div>
      </div>

      <div class="info" @click="copyAddress">
        <div class="action-box" v-if="actionBoxText != ''">
          <span>{{actionBoxText}}</span>
        </div>
        <span class="nickname">
          {{
          gameInfo.userInfos[account]
          ? gameInfo.userInfos[account].alias
          : account.substr(0, 5) + "..."
          }}
        </span>
        <div class="score">
          <img src="../../assets/v2/game_board/chip.png" class="chip" />
          <span>${{ balance }}</span>
        </div>
      </div>
    </div>
  </a-tooltip>
</template>

<script>
import { defineComponent } from "vue";
import Card from "./card.vue";
import { mapGetters } from "vuex";
import { HomeFilled } from "@ant-design/icons-vue";
import { message } from "ant-design-vue";

export default defineComponent({
  components: {
    Card,
    HomeFilled,
  },
  props: {
    id: {
      type: Number,
      require: true,
    },
    state: {
      type: String,
      default: "ready",
    },
    account: {
      type: String,
      require: true,
    },
    isFold: {
      type: Boolean,
      default: false,
    },
    isAllIn: {
      type: Boolean,
      default: false,
    },
    holeCards: {
      type: Array,
      default: () => {
        return ["back", "back"];
      },
    },
    bet: {
      type: Number,
      default: 0,
    },
    isSmallblind: {
      type: Boolean,
      default: false,
    },
    isBigblind: {
      type: Boolean,
      default: false,
    },
    currentRoundAction: {
      type: String,
      require: true,
    },
    currentRoundAmount: {
      type: Number,
      require: true,
    },
    balance: {
      type: Number,
      require: true,
    },
    isOnline: {
      type: Boolean,
      require: true,
    },
    message: {
      type: String,
      default: "",
    },
  },
  data() {
    return {
      actionMap: window.localStorage,
      playerMap: window.localStorage,
      avatarMap: window.localStorage,
    };
  },
  methods: {
    copyAddress() {
      var aux = document.createElement("input");
      aux.setAttribute("value", this.account);
      document.body.appendChild(aux);
      aux.select();
      document.execCommand("copy");
      document.body.removeChild(aux);
      message.info("The account address has been copied to the clipboard");
    },
  },
  computed: {
    ...mapGetters("game", ["gameInfo"]),
    ...mapGetters("user", ["userInfo"]),

    isLeft() {
      return this.id >= 6;
    },

    isTurn() {
      return this.gameInfo.currentActionUser == this.account;
    },

    isMe() {
      return this.userInfo.address == this.account;
    },

    avatorUrl() {
      const url =
        this.gameInfo.userInfos[this.account] &&
        this.gameInfo.userInfos[this.account].avatar
          ? this.gameInfo.userInfos[this.account].avatar
          : this.avatarMap.getItem(`avatar_${this.id}`);
      return url;
    },

    avatarBox() {
      if (this.isLeft) {
        if (this.isTurn) {
          return this.playerMap.getItem("avatar_panel_left_hl");
        }
        if (this.isFold) {
          return this.playerMap.getItem("avatar_mask_left");
        }
        return this.playerMap.getItem("avatar_panel_left");
      } else {
        if (this.isTurn) {
          return this.playerMap.getItem("avatar_panel_right_hl");
        }
        if (this.isFold) {
          return this.playerMap.getItem("avatar_mask_right");
        }
        return this.playerMap.getItem("avatar_panel_right");
      }
    },

    nameBox() {
      if (this.isLeft) {
        if (this.isTurn) {
          return this.playerMap.getItem("name_panel_left_hl");
        }
        if (this.isFold) {
          return this.playerMap.getItem("name_mask_left");
        }
        return this.playerMap.getItem("name_panel_left");
      } else {
        if (this.isTurn) {
          return this.playerMap.getItem("name_panel_right_hl");
        }
        if (this.isFold) {
          return this.playerMap.getItem("name_mask_right");
        }
        return this.playerMap.getItem("name_panel_right");
      }
    },

    actionBoxText() {
      if (this.isAllIn) {
        return "all in";
      }

      if (this.isFold) {
        return "fold";
      }

      if (this.isTurn && this.isMe) {
        return "wait";
      }

      if (!this.currentRoundAction) {
        if (this.isTurn && !this.isMe) {
          return "wait";
        } else {
          return "";
        }
      } else {
        switch (this.currentRoundAction) {
          case "bet":
          case "call":
          case "check":
          case "fold":
          case "raise":
            return this.currentRoundAction;
          case "smallblind":
            return "SB";
          case "bigblind":
            return "BB";
        }
        return "";
      }
    },

    waitingAction() {
      if (this.isTurn && this.isMe) {
        return true;
      }

      if (!this.currentRoundAction) {
        if (this.isTurn && !this.isMe) {
          return true;
        }
      }
    },

    actionBox() {
      if (this.isAllIn) {
        return this.actionMap.getItem(
          `action_allin_${this.isLeft ? "left" : "right"}`
        );
      }

      if (this.isFold) {
        return this.actionMap.getItem(
          `action_fold_${this.isLeft ? "left" : "right"}`
        );
      }

      if (this.isTurn && this.isMe) {
        return this.actionMap.getItem(
          `action_wait_${this.isLeft ? "left" : "right"}`
        );
      }

      if (!this.currentRoundAction) {
        if (this.isTurn && !this.isMe) {
          return this.actionMap.getItem(
            `action_wait_${this.isLeft ? "left" : "right"}`
          );
        } else {
          return this.actionMap.getItem("action_empty");
        }
      } else {
        return this.actionMap.getItem(
          `action_${this.currentRoundAction}_${this.isLeft ? "left" : "right"}`
        );
      }
    },
  },
});
</script>

<style scoped>
.user {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
}

.my-cards {
  display: flex;
  position: absolute;
  top: -60px;
}

.my-cards .card {
  width: 90px;
  height: 123px;
}

.my-cards .card-1 {
  width: 90px;
  height: 123px;
  transform: rotate(-10deg);
  position: relative;
  left: 23px;
}
.my-cards .card-2 {
  width: 90px;
  height: 123px;
  transform: rotate(10deg);
  position: relative;
  right: 23px;
}

.other-cards {
  display: flex;
  position: absolute;
  z-index: 99;
}

.other-cards#cards-1 {
  left: 30px;
  bottom: -77px;
}

.other-cards#cards-2 {
  left: -99px;
  bottom: -49px;
}

.other-cards#cards-3 {
  left: -71px;
  bottom: 84px;
}

.other-cards#cards-4 {
  top: -88px;
  left: 28px;
}

.other-cards#cards-5 {
  top: -88px;
  left: 34px;
}

.other-cards#cards-6 {
  top: -88px;
  right: 28px;
}

.other-cards#cards-7 {
  right: -71px;
  bottom: 84px;
}

.other-cards#cards-8 {
  right: -99px;
  bottom: -49px;
}

.other-cards#cards-9 {
  right: 30px;
  bottom: -77px;
}

.other-cards .card-1 {
  width: 49px;
  height: 65px;
  transform: rotate(-5deg);
  position: relative;
  left: 23px;
}
.other-cards .card-2 {
  width: 49px;
  height: 65px;
  transform: rotate(10deg);
  position: relative;
  right: 23px;
}

.avatar-acting {
  width: 138px;
  height: 138px;
  display: flex;
  z-index: 99;
  align-items: center;
  justify-content: center;
  background-position: left;
  background-size: cover;
  background-repeat: no-repeat;
  background-image: url("../../assets/v2/game_board/guang.png");
}
.avatar {
  width: 114px;
  height: 114px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  background-position: center;
  background-size: contain;
  background-image: url("../../assets/v2/game_board/avatar_bg.png");
}
.avatar > img {
  width: calc(100% - 10px);
  height: calc(100% - 10px);
  border-radius: 9999px;
}

.action-box {
  position: absolute;
  right: 0;
  top: -29px;
  min-width: 59px;
  height: 29px;
  background: #faae4c;
  border: 1px solid rgba(255, 255, 255, 0.76);
}

.info {
  position: relative;
  width: 145px;
  height: 58px;
  cursor: pointer;
  display: flex;
  z-index: 99;
  flex-direction: column;
  background-image: url("../../assets/v2/game_board/user_info.png");
  background-repeat: no-repeat;
  background-size: contain;
  margin-top: -4px;
}
.nickname {
  font-size: 20px;
  font-weight: 400;
  color: #d48940;
}
.chip {
  width: 24px;
  height: 24px;
}
.score {
  font-size: 18px;
  font-weight: 400;
  color: #c5ecf1;
}
/* 
.two-cards {
  position: relative;
  width: 200px;
}

.cards-1,
.cards-2,
.name-box,
.avatar-box,
.avatar-icon,
.text-box,
.action-box,
.chips-box,
.dot-box,
.operation-box,
.blind,
.action-amout {
  position: absolute;
}

.left .cards-1 {
  left: 0;
}

.left .cards-2 {
  left: 45px;
}

.left .name-box {
  top: 65px;
  left: -15px;
}

.left .avatar-box {
  top: 65px;
  left: 98px;
}

.left .avatar-icon {
  top: 88px;
  left: 106px;
  width: 42px;
}

.left .text-box {
  top: 81px;
  left: 0px;
}

.left .action-box {
  top: 40px;
  right: 0px;
}

.left .action-amout {
  top: 15px;
  right: 15px;
}

.right .cards-1 {
  right: 45px;
}

.right .cards-2 {
  right: 0px;
}

.right .name-box {
  top: 65px;
  right: -15px;
}

.right .avatar-box {
  top: 65px;
  right: 98px;
}

.right .avatar-icon {
  top: 88px;
  right: 106px;
  width: 42px;
}

.right .text-box {
  top: 81px;
  right: 0px;
}

.right .action-box {
  top: 40px;
  left: 0px;
}

.right .action-amout {
  top: 15px;
  left: 15px;
}

.text-box {
  top: 78px;
  right: 0px;
  font-size: 18px;
  color: white;
  width: 97px;
  height: 56px;
  line-height: 29px;
  font-weight: bolder;
}

.text-box .name {
  width: 95px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.score {
  color: yellow;
}

.bet {
  color: white;
  font-size: 20px;
  font-weight: bolder;
}

#user1 .chips-box {
  top: 120px;
  left: -10px;
}

#user2 .chips-box,
#user3 .chips-box,
#user4 .chips-box {
  top: 90px;
  left: -10px;
}

#user5 .chips-box {
  top: 90px;
  left: -10px;
}

#user6 .chips-box {
  top: 90px;
  right: -10px;
}

#user7 .chips-box,
#user8 .chips-box,
#user9 .chips-box {
  top: 90px;
  right: -10px;
}

#user10 .chips-box {
  top: 120px;
  right: -10px;
}

.dot-box {
  display: flex;
}

.right .dot-box {
  top: 143px;
  left: 50px;
}

.left .dot-box {
  top: 143px;
  right: 50px;
}

.green-dot {
  width: 10px;
  height: 10px;
  background-color: lightgreen;
  margin-right: 2px;
}

.gray-dot {
  width: 10px;
  height: 10px;
  background-color: gray;
  margin-right: 2px;
}

.action-amout {
  font-size: 20px;
  font-weight: bold;
  color: lightgreen;
}

.blind {
  color: orange;
  font-size: 20px;
  font-weight: 900;
}

.left .blind {
  top: 135px;
  left: 0px;
}

.right .blind {
  top: 135px;
  right: 0px;
} */
</style>