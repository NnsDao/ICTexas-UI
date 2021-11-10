<template>
  <div class="dialog-wrapper">
    <div class="dialog-bg">
      <div class="table-wrapper">
        <table>
          <tr>
            <th>BET</th>
            <th>COMBINATION</th>
            <th>WINNINGS</th>
            <th>POT 1</th>
            <th>POT 1</th>
            <th>POT 1</th>
            <th>POT 1</th>
          </tr>
          <tr v-for="item in dataSource" :key='item'>
            <td>
              <div class="userinfo">
                <div class="picture">头像</div>
                <div class="main-info">
                  <div class="first">
                    <span style="font-size: 24px;color: #D48940">{{ item.name }}</span>
                  </div>
                  <div class="first">
                    <img src="../../../src/assets/ntf/userinfo/yt.png" alt="">
                    &nbsp;{{ item.number }}
                  </div>
                </div>
              </div>
            </td>
            <td>
              <div>
                <img class="poker-img" v-for="item in item.pokerArray " :key='item'
                     :src="require('../../assets/poker/' + item + '.png')" alt="">
              </div>
            </td>
            <td>
              <div class="first center">
                <img src="../../../src/assets/ntf/userinfo/yt.png" alt="">
                &nbsp;{{ item.win }}
              </div>
            </td>
            <td>
              <div class="button">
                &nbsp;<img src="../../../src/assets/ntf/userinfo/yt.png" alt="">
                &nbsp;<span class="text">{{ item.pot1 }}</span>
              </div>
            </td>
            <td>
              <div class="button">
                <!--                v-if="item.pot1"-->
                &nbsp;<img src="../../../src/assets/ntf/userinfo/yt.png" alt="">
                &nbsp;<span class="text">{{ item.pot2 }}</span>
              </div>
            </td>
            <td>
              <div class="button">
                &nbsp;<img src="../../../src/assets/ntf/userinfo/yt.png" alt="">
                &nbsp;<span class="text">{{ item.pot3 }}</span>
              </div>
            </td>
            <td>
              <div class="button">
                &nbsp;<img src="../../../src/assets/ntf/userinfo/yt.png" alt="">
                &nbsp;<span class="text">{{ item.pot4 }}</span>
              </div>
            </td>
          </tr>

        </table>
      </div>
    </div>
  </div>
</template>

<script>
import {defineComponent, onMounted, ref} from 'vue';
import {pokerMap} from "../Game/resource";
// import {DownCircleOutlined} from '@ant-design/icons-vue';


export default defineComponent({
  components: {},
  setup() {
    onMounted(() => {
      getImgSrc()

    })


    let value = ref('');
    let enterCallback = value => {
      console.log(value);
    }


    let dataSource = [
      {
        name: 'lallaboboi',
        number: '1k',
        pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        win: '1K',
        pot1: '2K',
        pot2: '3K',
        pot3: '4K',
        pot4: '5K',
      },
      {
        name: 'lallaboboi',
        number: '1k',
        pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        win: '1K',
        pot1: '2K',
        pot2: '3K',
        pot3: '4K',
        pot4: '5K',
      },
      {
        name: 'lallaboboi',
        number: '1k',
        pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        win: '1K',
        pot1: '2K',
        pot2: '3K',
        pot3: '4K',
        pot4: '5K',
      },
      {
        name: 'lallaboboi',
        number: '1k',
        pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        win: '1K',
        pot1: '2K',
        pot2: '3K',
        pot3: '4K',
        pot4: '5K',
      },
      {
        name: 'lallaboboi',
        number: '1k',
        pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        win: '1K',
        pot1: '2K',
        pot2: '3K',
        pot3: '4K',
        pot4: '5K',
      }, {
        name: 'lallaboboi',
        number: '1k',
        pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        win: '1K',
        pot1: '2K',
        pot2: '3K',
        pot3: '4K',
        pot4: '5K',
      }, {
        name: 'lallaboboi',
        number: '1k',
        pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        win: '1K',
        pot1: '2K',
        pot2: '3K',
        pot3: '4K',
        pot4: '5K',
      },


    ]
    let getImgSrc = (value) => {
      return pokerMap.value
    }

    return {
      value,
      enterCallback,
      dataSource,
      getImgSrc
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
  height: auto;
  background: url("../../../src/assets/ntf/statistics/roundStatisticsBG.png") no-repeat center center;
  background-size: contain;
  color: #FFFFFF;
  display: flex;
  flex-direction: column;
}

.table-wrapper {
  margin: 6vw auto 2vw auto;
  width: 78%;
}

table {
  border: 1px solid red;
  width: 100%;
  border-collapse: collapse;

}

th {
  color: #F7CA5F;
}

th, td {
  border: 1px solid #3b3f38;
  height: 70px;
  text-align: center;
}

th {
  background: #152527;

}

.userinfo {
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.picture {
  width: 2.91vw;
  height: 2.91vw;
  border: 1px solid black;
  border-radius: 50%;
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

.center {
  display: flex;
  justify-content: center;
}

.first img {
  width: 15px;
  height: 15px;
}

.first span {
  color: #fff;
  font-size: 20px;
}

.button {
  background: url("../../../src/assets/ntf/userinfo/anniu.png") center center no-repeat;
  background-size: contain;
  display: flex;
  justify-content: center;
  align-items: center;
}

.button img {
  width: 15px;
  height: 15px;
}

.button .text {
  line-height: 25px;
}

.poker-img {
  width: 1.97vw;
  height: 2.65vw;
  margin-right: 10px;
}

</style>
