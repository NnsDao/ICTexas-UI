<template>
  <div class="message">
    <div class="notify"></div>

    <div class="window">
      <div class="view-btn"></div>
      <div class="switch-btn"></div>
      <input class="message-input" v-model="message" placeholder="Message text" />
      <div class="send-btn" @click="sendMessage">SEND</div>
    </div>
  </div>
</template>

<script>
import { ref } from "vue";
import GameInfo from "../../utils/game";

export default {
  setup() {
    const message = ref("");
    const sendMessage = () => {
      if (!message.value.length) {
        return;
      }

      GameInfo.Instance.userSpeak(message.value);
      message.value = "";
    };

    return {
      message,
      sendMessage,
    };
  },
};
</script>

<style scoped>
.message {
  height: 100%;
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-width: 600px;
}

.window {
  display: flex;
  align-items: flex-end;
}

.view-btn {
  width: 43px;
  height: 43px;
  background-image: url("../../assets/v2/game_board/history_message.png");
  background-size: contain;
}

.switch-btn {
  width: 18px;
  height: 18px;
  margin: 0 10px;
  background-image: url("../../assets/v2/game_board/switch_btn_down.png");
  background-size: contain;
}

.message-input {
  width: 982px;
  height: 32px;
}

.send-btn {
  margin-left: 18px;
  width: 157px;
  height: 32px;
  cursor: pointer;
  background: #1a262f;
  border: 1px solid #8ea8bb;
  border-radius: 3px;
  text-align: center;
  line-height: 32px;

  font-size: 20px;
  font-weight: 400;
  color: #ffffff;
}
</style>