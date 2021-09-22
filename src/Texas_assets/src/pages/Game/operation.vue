<template>
  <div>
    <a-spin :spinning="spinning">
      <div class="operation-group">
        <img
          :src="operationMap.getItem(callBtn)"
          class="operation-btn call"
          v-if="allowAction.indexOf('call') !== -1"
          @click="doAction('call')"
        />
        <img
          :src="operationMap.getItem(checkBtn)"
          class="operation-btn check"
          v-if="allowAction.indexOf('check') !== -1"
          @click="doAction('check')"
        />
        <img
          :src="operationMap.getItem('fold_button')"
          class="operation-btn fold"
          v-if="allowAction.indexOf('fold') !== -1"
          @click="doAction('fold')"
        />
        <img
          :src="operationMap.getItem(allinBtn)"
          class="operation-btn allin"
          v-if="allowAction.indexOf('allin') !== -1"
          @click="doAction('allin')"
        />
      </div>

      <div class="operation-bet" v-if="allowAction.indexOf('bet') !== -1">
        <img
          :src="operationMap.getItem(betBtn)"
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
      </div>

      <div class="operation-bet" v-if="allowAction.indexOf('raise') !== -1">
        <img
          :src="operationMap.getItem(raiseBtn)"
          class="operation-btn raise"
          @click="doAction('raise')"
        />

        <a-slider
          class="bet-slider"
          :min="gameInfo.currentActionCan['raise']"
          :max="userInfo.balance"
          step="10"
          v-model:value="raiseValue"
          :tooltip-visible="true"
        />
      </div>
    </a-spin>
  </div>
</template>

<script>
import { defineComponent, ref } from "vue";
import { mapGetters } from "vuex";
import GameInfo from "../../utils/game";
import { message } from "ant-design-vue";

export default defineComponent({
  setup() {
    const betValue = ref(0);
    const raiseValue = ref(0);
    const spinning = ref(false);

    return {
      betValue,
      raiseValue,
      operationMap: window.localStorage,
      spinning,
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
.operation-group {
  display: flex;
}

.operation-bet {
  display: flex;
  margin-top: 10px;
}

.bet-slider {
  width: 240px;
}

.operation-btn {
  display: block;
  cursor: pointer;
  width: 120px;
  height: 60px;
  background-repeat: no-repeat;
  background-size: contain;
  margin-right: 10px;
}

.operation-group .operation-btn:nth-last-child(1) {
  margin-right: 0px;
}

.operation-btn.raise {
  margin-right: 0px;
}
</style>