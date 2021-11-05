<!--修改头像弹窗 -->
<template>
  <div class="dialog-wrapper">
    <div class="dialog-bg" @click.stop>
      <div class="head">
        <img src="../../../src/assets/ntf/avator/title.png" alt="">
      </div>
      <div class="content">
        <div class="avator">
          <img class="v2avatorUrl" :src="avatorUrl" alt="" v-on:error.once="errorUrl($event)">
        </div>
        <div class="input">
          <a-input v-model:value="avatorUrl" @pressEnter="enterCallback"/>

        </div>
        <div class="footer">
          <div class="cancel" @click.stop="cancel()">
          </div>
          <div class="ok" @click.stop="handleOk()">
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
/**
 * @description
 * 开发 赵笑寒 10.29
 * */
import {defineComponent, ref} from 'vue';
import {message} from "ant-design-vue";
import GameInfo from "../../utils/game";
import store from "../../store";
// import {DownCircleOutlined} from '@ant-design/icons-vue';


export default defineComponent({
  components: {},
  setup() {
    let avatorUrl = ref('');
    let errorUrl = (e) => {
      e.currentTarget.src = "https://hrrqn-4aaaa-aaaai-aasoq-cai.raw.ic0.app/assets/nnsdao-logo-1024.3009ad19.png"
    }

    let enterCallback = () => {
      handleOk()
    }

    const showModal = (url) => {

      if (url.indexOf("http") != -1) {
        avatorUrl.value = url;
      }
    };

    const handleOk = async () => {
      const AntAvatarImage = document.getElementsByClassName("v2avatorUrl")
      if (!AntAvatarImage.length || !AntAvatarImage[0].children.length) {
        message.error("Can't find the Image");
        return;
      }

      const res = await GameInfo.Instance.setAvatar(avatorUrl.value);
      if (!res[0]) {
        message.error(res[1]);
        return;
      }

      await store.dispatch("user/setNickname");
      this.cancel()
    };

    return {
      avatorUrl,
      errorUrl,
      enterCallback,
      showModal,
      handleOk,
    };

  },
    methods: {
      cancel() {
        this.$emit('offAvatorDialog', false)
      }
    }
})
</script>

<style scoped>
.dialog-wrapper {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  overflow: auto;
  margin: 0;
  background-color: rgba(0, 0, 0, 0.8);
  z-index: 11;
  display: flex;
  justify-content: center;
  align-items: center;
}

.dialog-bg {
  position: relative;
  background: #fff;
  width: 50vw;
  height: 22.62vw;
  background: url("../../../src/assets/ntf/avator/bg.png") no-repeat;
  background-size: cover;
  color: #FFFFFF;
  display: flex;
  flex-direction: column;
}

.dialog-bg .head {
  margin-top: 5%;
}

.content {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.content .avator {
  margin: 2% 0;
  width: 5vw;
  height: 5vw;
  border: 1px solid black;
  border-radius: 50%;
  overflow: hidden;
}

.content .avator img {
  width: 100%;
  height: 100%;
}

.content .input {
  margin: 2% 0;
  background: url("../../../src/assets/ntf/avator/bg2.png") no-repeat;
  background-size: cover;
  width: 40vw;
  height: 3.12vw;
}

/deep/ .ant-input {
  box-sizing: border-box;
  margin: 0;
  padding: 0 15px;
  font-variant: tabular-nums;
  list-style: none;
  font-feature-settings: 'tnum';
  position: relative;
  display: inline-block;
  width: 100%;
  height: 99%;
  color: #e8d3a0;
  font-size: 14px;
  line-height: 1.5715;
  background-color: #193739;
  border: none;
  border-radius: 5px;
  transition: all 0.3s;
}

.content .footer {
  border-radius: 50%;
  display: flex;
}

.content .footer .cancel {
  margin-right: 5vw;
  width: 6.45vw;
  height: 2.75vw;
  background: url("../../../src/assets/ntf/avator/cancel.png") no-repeat;
  background-size: cover;
}

.content .footer .ok {
  width: 6.45vw;
  height: 2.75vw;
  background: url("../../../src/assets/ntf/avator/ok.png") no-repeat;
  background-size: cover;

}
</style>
