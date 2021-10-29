<!--用户信息 弹窗-->
<template>
  <div class="dialog-wrapper">
    <div class="dialog">
      <div class="dialog-top">
        <div class="picture">头像</div>
        <div class="main-info">
          <div class="first">
            <span style="font-size: 24px;color: #D48940">{{ 'lallaboboi ' }}</span>
            <img src="../../../src/assets/ntf/userinfo/bianji.png" alt="">
          </div>
          <div class="first">
            <img src="../../../src/assets/ntf/userinfo/yt.png" alt="">
            &nbsp;{{ '   3k' }}
          </div>
          <div class="first">
            <img src="../../../src/assets/ntf/userinfo/g.png" alt="">
            &nbsp;{{ '   gxx' }}
          </div>
          <div class="first">
            {{ 'id  ' }}&nbsp;
            {{ 'xxx' }}
          </div>

        </div>
        <div class="mid">
          <div>BIGGEST &nbsp; WIN</div>
          <div>小图标这个没切图</div>
          <div class="button">
            &nbsp;<img src="../../../src/assets/ntf/userinfo/yt.png" alt="">
            &nbsp;<span class="text">1k</span>
          </div>
        </div>
        <div class="text-wrapper">
          <div class="text-left">
            <div>GAMES PLAYED:</div>
            <div>BIGGEST WIN:</div>
            <div>STARTED PLAYING:</div>
            <div>LOCATION:</div>
          </div>
        </div>
        <div class="text-wrapper">
          <div class="text-right">
            <div>120</div>
            <div>
              <img src="../../../src/assets/ntf/userinfo/yt.png" alt="">
              <span>20K</span>
            </div>
            <div>08/18/2021</div>
            <div>UNKNOWN</div>
          </div>
        </div>
      </div>
      <div class="dialog-bottom">
        <div class="item" v-for="item in dataSource " :key="item.id">
          <div class="text-green">{{ item.top }}</div>
          <img :src="item.url" alt="">
          <div>{{ item.bottom }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * @description
 * 开发者 赵笑寒 10.28
 *
 * */
import {defineComponent,} from 'vue';
// import {DownCircleOutlined} from '@ant-design/icons-vue';


export default defineComponent({
  components: {},
  setup() {

    let dataSource = [
      {
        id: '1',
        top: '123',
        url: require("../../../src/assets/ntf/k_1.png"),
        bottom: '131',
      },
      {
        id: '2',
        top: '123',
        url: require("../../../src/assets/ntf/k_2.png"),
        bottom: '131',
      },
      {
        id: '3',
        top: '123',
        url: require("../../../src/assets/ntf/k_3.png"),
        bottom: '131',
      },
      {
        id: '4',
        top: '123',
        url: require("../../../src/assets/ntf/k_4.png"),
        bottom: '131',
      },
      {
        id: '5',
        top: '123',
        url: require("../../../src/assets/ntf/k_5.png"),
        bottom: '131',
      },

    ]
    return {
      dataSource
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

.dialog {
  position: relative;
  background: #fff;
  width: 50vw;
  min-height: 40vw;
  background: url("../../../src/assets/ntf/userinfo/dk_a.png") no-repeat;
  background-size: contain;
  color: #FFFFFF;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.dialog-top {
  margin-top: 14.5%;
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
  justify-content: space-around;
}

.picture {
  margin-left: 20px;
  width: 75px;
  height: 75px;
  border: 1px solid black;
  border-radius: 50%;
}

.main-info {

}

.first {
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
  flex-wrap: nowrap;
  text-align: center;
  line-height: 22px;
}

.first img {
  width: 15px;
  height: 15px;
}

.first span {
  color: #fff;
  font-size: 20px;
}

.mid {
  display: flex;
  flex-direction: column;
  align-items: center;

}

.mid .button {
  background: url("../../../src/assets/ntf/userinfo/anniu.png") no-repeat;
  background-size: contain;
  display: flex;
  align-items: center;
  width: 70px;
}

.mid .button img {
  width: 15px;
  height: 15px;
}

.mid .button .text {
  line-height: 25px;
}

.text-wrapper {
  line-height: 20px;
  text-align: left;
}

.text-wrapper img {
  width: 15px;
  height: 15px;
}

.text-right {
  margin-right: 30px

}

.dialog-bottom {
  margin: 0 4% 25% 4%;;
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.text-green{
  color: #64cd56;
 }

.dialog-bottom .item img {
  width: 58%;
}
</style>
