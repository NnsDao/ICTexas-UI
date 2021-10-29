<!-- 统计战绩弹窗 -->
<template>
  <div class="dialog-wrapper">
    <div class="dialog-bg">
      <div class="table-wrapper">
        <div class="table-header">
          <div class="header-first">BET</div>
          <div class="header-second">COMBINATION</div>
          <div class="header-third">WINNINGS</div>
          <div class="header-four">POT 1</div>
          <div class="header-four">POT 2</div>
          <div class="header-four">POT 3</div>
          <div class="header-four">POT 4</div>
        </div>
        <div class="table-body">
          <div>
            <div>头像</div>
            <div>
              <div>name</div>
              <div>
                圈圈
                1k
              </div>
            </div>
          </div>
          <div>
            poker映射
          </div>
          <div>
            圈圈1k
          </div>
          <div>
            按钮1k
          </div>
          <div></div>
          <div></div>
          <div></div>
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
  width: 55vw;
  height: 34.2vw;
  background: url("../../../src/assets/ntf/statistics/roundStatisticsBG.png") no-repeat;
  background-size: cover;
  color: #FFFFFF;
  display: flex;
  flex-direction: column;
}

.table-wrapper {
  border: 1px solid #8E7C61;
  border-radius: 5px;
  margin: 6vw 1.5vw 1vw 1.5vw;

}

.table-header {
  display: flex;
  color: #F7CA5F;
  text-align: center;
  line-height: 3.229vw;
  height: 3.229vw
}

.table-header .header-first .header-second .header-third .header-four {
  background: #152527;
  border-right: 1px solid #8E7C61;
  border-bottom: 1px solid #8E7C61;
}


.table-header .header-first {
}

.table-header .header-second {
}

.table-header .header-third {
}

.table-header .header-four {
}

.table-body {
}
</style>
