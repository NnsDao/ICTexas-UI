<template>
  <div class="dialog-wrapper" @click.self="close()">

    <div class="dialog-bg">
      <img class="dialog-close" src="../../assets/close.png" alt="" @click.stop="close()">

      <div class="table-wrapper">
        <div class="thead">
          <table>
            <tr>
              <th>HAND</th>
              <th>NICKNAME</th>
              <th>CARDS</th>
              <th>POT</th>
            </tr>
          </table>
        </div>
        <div class="tbody">
          <table>
            <tr v-for="item in gameInfo.lastGameReward"
                :key="item.index">

              <!--            <tr v-for="(item,index) in dataSource"-->
              <!--                :key="index">-->
              <td>
                {{ item.rank + 1 || 0 }}
              </td>
              <td>
                <div class="nick">
                  <div class="picture">
                    <a-avatar size="large" class="user-btn">
                      <template #icon>
                        <img :src="userInfo.avatorUrl"/>
                      </template>
                    </a-avatar>
                  </div>
                  <div class="main-info">
                    <div class="first">
                    <span style="font-size: 1rem;color: #D48940">
                      {{ showName(item.account) }}
                    </span>
                    </div>
                  </div>
                </div>
              </td>
              <td>
                <div class="cards">
                  <card
                      :class="'cards-' + (index + 1)"
                      :type="card"
                      v-for="(card, index) in item.cards"
                      :key="index"
                      :width="30"
                  />

                  <card
                      :class="'cards-' + (index + 6)"
                      :type="card"
                      v-for="(card, index) in item.resetCards"
                      :key="index"
                      :width="30"
                  />
                </div>
              </td>
              <td>
                <div class="button">
                  &nbsp;<img src="../../assets/ntf/userinfo/yt.png" alt="">
                  &nbsp;<span class="text">{{ item.reward || '0' }}</span>
                </div>
              </td>

            </tr>
          </table>

        </div>
      </div>
    </div>
  </div>
</template>

<script>

import {defineComponent, onMounted, ref} from 'vue';
import {mapGetters} from "vuex";
import Card from "./card.vue";
// import {DownCircleOutlined} from '@ant-design/icons-vue';


export default defineComponent({
  components: {Card},
  computed: {
    ...mapGetters("game", ["gameInfo"]),
    ...mapGetters("user", ["userInfo"]),
  },
  setup() {
    // onMounted(() => {
    //   console.log(this.gameInfo)
    //
    // })


    let value = ref('');
    let enterCallback = value => {
      console.log(value);
    }


    let dataSource = [
      {
        name: 'lallaboboi',
        number: '1k',
        cards: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        pot1: '2K',
      },
      {
        name: 'lallaboboi',
        number: '1k',
        cards: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        pot1: '2K',

      },
      {
        name: 'lallaboboi',
        number: '1k',
        cards: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        pot1: '2K',

      },
      {
        name: 'lallaboboi',
        number: '1k',
        cards: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        pot1: '2K',

      },
      {
        name: 'lallaboboi',
        number: '1k',
        cards: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        pot1: '2K',

      }, {
        name: 'lallaboboi',
        number: '1k',
        cards: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        pot1: '2K',

      }, {
        name: 'lallaboboi',
        number: '1k',
        cards: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
        pot1: '2K',

      },


    ]
    let getImgSrc = (value) => {
    }

    return {
      value,
      enterCallback,
      dataSource,
      getImgSrc
    };
  },
  methods: {
    close() {
      this.$emit("close");
    },

    winnerAccount() {
      console.log(this.gameInfo, 'gameInfo')
      const winner = this.gameInfo.lastGameReward[0];
      if (winner) {
        return this.showName(winner.account);
      } else {
        return "";
      }
    },

    showName(account) {
      return this.gameInfo.userInfos[account] ? this.gameInfo.userInfos[account].alias : `${account.substr(0, 5)}...${account.substr(account.length - 5)}`
    }
  },
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
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.dialog-bg {
  position: relative;
  background: #fff;
  width: 45vw;
  min-width: 700px;
  min-height: 420px;
  height: 28vw;
  background: url("../../assets/ntf/statistics/HandHistoryBg.png") no-repeat center center;
  background-size: contain;
  color: #FFFFFF;
  display: flex;
  flex-direction: column;
}

.table-wrapper {
  margin: 0 auto;
  padding: 11% 0 1.5vw 0;
  width: 95%;
  height: 95%;
}

.thead {
  position: relative;
  table-layout: fixed;
}

.tbody {
  overflow-y: auto;
  overflow-x: hidden;
  height: 89%;

}

table {
  table-layout: fixed;
  width: 100%;
  border-collapse: collapse;

}

tr {
  height: 50px;
  position: relative;
  /*table-layout: fixed;*/
}

th, td {
  border: 1px solid #3b3f38;
  height: 70px;
  text-align: center;
}

th {
  color: #F7CA5F;
  background: #152527;

}

table thead {
  width: calc(100% - 1em)
}

.thead table tr :nth-child(1), .tbody table tr :nth-child(1) {
}

.thead table tr :nth-child(2), .tbody table tr :nth-child(2) {
  width: 25%;
  white-space: nowrap;
}

.thead table tr :nth-child(3), .tbody table tr :nth-child(3) {
  width: 47%;
}

.thead table tr :nth-child(4), .tbody table tr :nth-child(4) {
  width: 13%;
}

.nick {
  display: flex;
  /* justify-content: space-around; */
  align-items: center;
}

.cards {
  position: relative;
  height: 60px;
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.cards-1,
.cards-2,
.cards-3,
.cards-4,
.cards-5,
.cards-6,
.cards-7 {
  width: 12% !important;
  height: auto;
  /*height: auto;*/
  /*position: absolute;*/
}

/*.cards-2 {*/
/*  left: 35px;*/
/*}*/

/*.cards-3 {*/
/*  left: 70px;*/
/*}*/

/*.cards-4 {*/
/*  left: 105px;*/
/*}*/

/*.cards-5 {*/
/*  left: 140px;*/
/*}*/

/*.cards-6 {*/
/*  left: 200px;*/
/*}*/

/*.cards-7 {*/
/*  left: 235px;*/
/*}*/


.userinfo {
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.picture {
  /*width: 56px;*/
  /*height: 56px;*/
  /*border: 1px solid black;*/
  /*border-radius: 50%;*/
  padding: 0 10px;
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
  background: url("../../assets/ntf/userinfo/anniu.png") center center no-repeat;
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
.dialog-close{
  position: absolute;
  top: -3px;
  right: -23px;
  width: 50px;
  height: 50px;
}

.poker-img {
  width: 1.97vw;
  height: 2.65vw;
  margin-right: 10px;
}

</style>
