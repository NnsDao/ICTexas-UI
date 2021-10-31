<template>
  <a-spin :spinning="spinning" wrapperClassName="spin">
    <div class="operation-group">
      <div :class="['operation-btn', 'fold' , 'allow']" v-if="allowAction.indexOf('fold') !== -1">
        <img src="../../assets/v2/game_board/btn_fold.png" @click="doAction('fold')" />
      </div>

      <div
        :class="['operation-btn', 'check' , allowCheck ? 'allow': 'not-allow' ]"
        v-if="allowAction.indexOf('check') !== -1"
      >
        <img src="../../assets/v2/game_board/btn_check.png" @click="doAction('check')" />
      </div>

      <div
        :class="['operation-btn', 'call' , allowCall ? 'allow': 'not-allow' ]"
        v-if="allowAction.indexOf('call') !== -1"
      >
        <img src="../../assets/v2/game_board/btn_call.png" @click="doAction('call')" />
      </div>

      <!-- <div class="operation-btn allin" v-if="allowAction.indexOf('allin') !== -1">
        <img :src="operationMap.getItem(allinBtn)" @click="doAction('allin')" />
      </div>-->

      <!-- <div
        :class="['operation-btn', 'bet' , allowBet ? 'allow': 'not-allow' ]"
        v-if="allowAction.indexOf('bet') !== -1"
      >
        <img
          src="../../assets/v2/game_board/btn_raise.png"
          class="operation-btn bet"
          @click="doAction('bet')"
        />

        <a-slider
          class="bet-slider"
          :min="gameInfo.currentActionCan['bet']"
          :max="userInfo.balance"
          step="10"
          v-model:value="betValue"
          :tooltip-visible="true"
        />
      </div>-->

      <div
        :class="['operation-btn', 'raise' , allowRaise ? 'allow': 'not-allow' ]"
        v-if="allowAction.indexOf('raise') !== -1"
        @mouseover="showRaiseSlider"
        @mouseleave="raiseSliderVisible = false"
      >
        <img
          src="../../assets/v2/game_board/btn_raise.png"
          class="operation-btn raise"
          @click="doAction('raise')"
        />

        <div class="raise-op" v-show="raiseSliderVisible">
          <div class="raise-buttons">
            <span class="raise-btn" @click="doAction('allin')">ALL in</span>
            <span class="raise-btn">bot</span>
            <span class="raise-btn">1/2bot</span>
            <span class="add" @click="addRaise">+</span>
            <span class="sub" @click="subRaise">-</span>
          </div>
          <div class="raise-silder">
            <span class="allin">ALL in</span>
            <img class="bg" src="../../assets/v2/game_board/slider.png" />
            <div class="raise-value-bg">
              <span class="raise-value">{{raiseValue}}</span>
            </div>
          </div>
        </div>

        <!-- <a-slider
          class="bet-slider"
          :min="gameInfo.currentActionCan['raise']"
          :max="userInfo.balance"
          step="10"
          v-model:value="raiseValue"
          :tooltip-visible="true"
        />-->
      </div>
    </div>

    <div class="operation-group">
      <img
        :src="operationMap.getItem('fold_button')"
        class="operation-btn fold"
        v-if="allowAction.indexOf('fold') !== -1"
        @click="doAction('fold')"
      />
      <img
        :src="operationMap.getItem(checkBtn)"
        class="operation-btn check"
        v-if="allowAction.indexOf('check') !== -1"
        @click="doAction('check')"
      />
    </div>
  </a-spin>
</template>

<script>
import { defineComponent, ref } from "vue";
import { mapGetters } from "vuex";
import GameInfo from "../../utils/game";
import { message } from "ant-design-vue";

export default defineComponent({
  setup() {
    const betValue = ref(0);
    const spinning = ref(false);

    const raiseValue = ref(0);
    const raiseSliderVisible = ref(false);

    console.log(raiseValue);
    console.log(raiseValue);
    return {
      betValue,
      operationMap: window.localStorage,
      spinning,
      raiseValue,
      raiseSliderVisible,
    };
  },
  methods: {
    async doAction(action) {
      if (this.gameInfo.currentActionCan[action] === undefined) {
        return;
      }

      this.spinning = true;
      let result = true;
      if (action === "bet") {
        if (this.betValue === 0)
          this.betValue = this.gameInfo.currentActionCan["bet"];
        result = await GameInfo.Instance.userAction(
          action,
          this.betValue,
          this.gameInfo.currentActionSeq
        );
      } else if (action == "raise") {
        if (this.raiseValue === 0)
          this.raiseValue = this.gameInfo.currentActionCan["raise"];
        result = await GameInfo.Instance.userAction(
          action,
          this.raiseValue,
          this.gameInfo.currentActionSeq
        );
      } else {
        result = await GameInfo.Instance.userAction(
          action,
          this.gameInfo.currentActionCan[action],
          this.gameInfo.currentActionSeq
        );
      }
      message.info("action result: " + result.toString());
      this.spinning = false;
    },
    showRaiseSlider() {
      this.raiseSliderVisible = true;
      if (
        this.raiseValue > this.userInfo.balance ||
        this.raiseValue < this.gameInfo.currentActionCan["raise"]
      ) {
        this.raiseValue = this.gameInfo.currentActionCan["raise"];
      }
    },
    addRaise() {
      this.raiseValue += 10;
      if (this.raiseValue > this.userInfo.balance) {
        this.raiseValue = this.userInfo.balance;
      }
    },
    subRaise() {
      this.raiseValue -= 10;

      if (this.raiseValue < this.gameInfo.currentActionCan["raise"]) {
        this.raiseValue = this.gameInfo.currentActionCan["raise"];
      }
    },
  },
  computed: {
    ...mapGetters("game", ["gameInfo"]),
    ...mapGetters("user", ["userInfo"]),

    allowAction() {
      return Object.keys(this.gameInfo.currentActionCan);
    },

    allowCall() {
      return this.gameInfo.currentActionCan["call"] <= this.userInfo.balance;
    },

    callBtn() {
      if (this.allowCall) {
        return "call_button";
      } else {
        return "call_button_disabled";
      }
    },

    allowCheck() {
      return this.gameInfo.currentActionCan["check"] <= this.userInfo.balance;
    },

    checkBtn() {
      if (this.allowCheck) {
        return "check_button";
      } else {
        return "check_button_disabled";
      }
    },

    allowRaise() {
      return this.gameInfo.currentActionCan["raise"] <= this.userInfo.balance;
    },

    raiseBtn() {
      if (this.allowRaise) {
        return "raise_button";
      } else {
        return "raise_button_disabled";
      }
    },

    allowBet() {
      return this.gameInfo.currentActionCan["bet"] <= this.userInfo.balance;
    },

    betBtn() {
      if (this.allowBet) {
        return "bet_button";
      } else {
        return "bet_button_disabled";
      }
    },

    allowAllin() {
      return (
        this.gameInfo.currentActionCan["allin"] === 0 ||
        this.userInfo.balance < this.gameInfo.currentActionCan["allin"]
      );
    },

    allinBtn() {
      if (this.allowAllin) {
        return "allin_button";
      } else {
        return "allin_button_disabled";
      }
    },
  },
});
</script>


<style scoped>
.spin {
  height: 100%;
}

.spin >>> .ant-spin-container {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.operation-group {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.operation-btn {
  display: block;
  width: 139px;
  height: 60px;
  background-repeat: no-repeat;
  background-size: contain;
}

.operation-btn > img {
  width: 100%;
  height: 100%;
}

.allow {
  cursor: pointer;
}

.not-allow {
  cursor: not-allowed;
}

.operation-bet {
  display: flex;
  margin-top: 10px;
}

.bet-slider {
  width: 240px;
}

.operation-group .operation-btn:nth-last-child(1) {
  margin-right: 0px;
}

.operation-btn.raise {
  position: relative;
}

/* .operation-btn.raise:hover .raise-op {
  visibility: visible;
} */

.raise-op {
  /* visibility: hidden; */
  position: absolute;
  right: 4px;
  bottom: 53px;
  display: flex;
}

.raise-buttons {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: flex-end;
}

.raise-btn {
  width: 90px;
  height: 45px;
  font-size: 23px;
  font-weight: 400;
  color: #ffffff;
  line-height: 45px;
  text-align: center;
  background-image: url("../../assets/v2/game_board/raise-btn-bg.png");
  background-size: contain;
}

.add,
.sub {
  width: 56px;
  height: 56px;
  background: linear-gradient(0deg, #3370c6, #7ba9e9);
  box-shadow: 0px 4px 3px 1px rgb(4 0 0 / 22%);
  border-radius: 5px;
  font-size: 46px;
  color: #ffff;
  font-style: normal;
  font-weight: bold;
  line-height: 56px;
  user-select: none;
}

.add {
  margin-right: 66px;
}

.sub {
  margin-right: 42px;
  margin-bottom: 84px;
}

.raise-btn:nth-child(1) {
  margin: 56px 114px 0 0;
}

.raise-btn:nth-child(2) {
  margin-right: 92px;
}

.raise-btn:nth-child(3) {
  margin-right: 70px;
}

.raise-silder {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.raise-silder .bg {
  width: 93px;
  height: 578px;
}

.raise-silder .bg-front {
  width: 93px;
  height: 578px;
}

.raise-silder .allin {
  font-size: 26px;
  font-weight: 400;
  color: #ffffff;
}

.raise-value-bg {
  width: 120px;
  height: 79px;
  margin-top: -60px;
  background-image: url("../../assets/v2/game_board/zhen.png");
  background-size: contain;
}

.raise-value {
  width: 40px;
  height: 19px;
  font-size: 25px;
  font-family: SimHei;
  font-weight: bold;
  line-height: 79px;
  color: #ffffff;
  -webkit-text-stroke: 2px #031318;
  text-stroke: 2px #031318;
}
</style>