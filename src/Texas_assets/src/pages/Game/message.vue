<template>
  <div class="message">
    <div class="notify"></div>

    <div class="window">
      <div class="view-btn"></div>
      <div class="switch-btn"></div>
      <input class="message-input" placeholder="Message text"/>
      <div class="send-btn">SEND</div>
    </div>
  </div>
</template>

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
}

.switch-btn {
  width: 18px;
  height: 18px;
  margin: 0 10px;
  background-image: url("../../assets/v2/game_board/switch_btn_down.png");
}

.message-input{
    width: 60%;
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
color: #FFFFFF;
}
</style>