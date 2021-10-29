<!--修改头像弹窗 -->
<template>
  <div class="dialog-wrapper">
    <div class="dialog-bg">
      <div class="head">
        <img src="../../../src/assets/ntf/avator/title.png" alt="">
      </div>
      <div class="content">
        <div class="avator">头像</div>
        <div class="input">
          <a-input v-model:value="value" @pressEnter="enterCallback"/>

        </div>
        <div class="footer">
          <div class="cancel">
          </div>
          <div class="ok">
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
// import {DownCircleOutlined} from '@ant-design/icons-vue';


export default defineComponent({
  components: {},
  setup() {
    let value = ref('');
    let enterCallback = value => {
      console.log(value);
    }
    return {
      value,
      enterCallback
    };
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

.content .footer .cancel{
  margin-right: 5vw;
  width: 6.45vw;
  height: 2.75vw;
  background: url("../../../src/assets/ntf/avator/cancel.png") no-repeat;
  background-size: cover;
}
.content .footer .ok{
  width: 6.45vw;
  height: 2.75vw;
  background: url("../../../src/assets/ntf/avator/ok.png") no-repeat;
  background-size: cover;

}
</style>
