<template>
  <div class="dialog-wrapper" @click.self="close()">
    <div class="dialog-bg">
      <div class="table-wrapper">
        <table>
          <tr>
            <th>HAND</th>
            <th>NICKNAME</th>
            <th>CARDS</th>
            <th>POT</th>
          </tr>
          <tr v-for="item in gameInfo.lastGameReward"
              :key="item.index">
            <td>
              {{ item.rank + 1 }}
            </td>
            <td>
              <div class="nick">
                <div class="picture">
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
                    :width="50"
                />

                <card
                    :class="'cards-' + (index + 6)"
                    :type="card"
                    v-for="(card, index) in item.resetCards"
                    :key="index"
                    :width="50"
                />
              </div>
            </td>
            <td>
              <div class="button">
                &nbsp;<img src="../../assets/ntf/userinfo/yt.png" alt="">
                &nbsp;<span class="text">{{ item.reward }}</span>
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
import {mapGetters} from "vuex";
import Card from "./card.vue";
// import {DownCircleOutlined} from '@ant-design/icons-vue';


export default defineComponent({
  components: {Card},
  computed: {
    ...mapGetters("game", ["gameInfo"]),
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


    // let dataSource = [
    //   {
    //     name: 'lallaboboi',
    //     number: '1k',
    //     pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
    //     pot1: '2K',
    //   },
    //   {
    //     name: 'lallaboboi',
    //     number: '1k',
    //     pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
    //     pot1: '2K',
    //
    //   },
    //   {
    //     name: 'lallaboboi',
    //     number: '1k',
    //     pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
    //     pot1: '2K',
    //
    //   },
    //   {
    //     name: 'lallaboboi',
    //     number: '1k',
    //     pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
    //     pot1: '2K',
    //
    //   },
    //   {
    //     name: 'lallaboboi',
    //     number: '1k',
    //     pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
    //     pot1: '2K',
    //
    //   }, {
    //     name: 'lallaboboi',
    //     number: '1k',
    //     pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
    //     pot1: '2K',
    //
    //   }, {
    //     name: 'lallaboboi',
    //     number: '1k',
    //     pokerArray: ['AH', 'KH', 'QH', 'JH', 'TH', '9H'],
    //     pot1: '2K',
    //
    //   },
    //
    //
    // ]
    let getImgSrc = (value) => {
    }

    return {
      value,
      enterCallback,
      // dataSource,
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
  z-index: 11;
  display: flex;
  justify-content: center;
  align-items: center;
}

.dialog-bg {
  position: relative;
  background: #fff;
  width: 55vw;
  height: 40vw;
  background: url("../../assets/ntf/statistics/HandHistoryBg.png") no-repeat center center;
  background-size: contain;
  color: #FFFFFF;
  display: flex;
  flex-direction: column;
}

.table-wrapper {
  margin: 9vw auto 1vw auto;
  width: 85%;
}

.nick {
  display: flex;
  /* justify-content: space-around; */
  align-items: center;
}

.cards {
  position: relative;
  height: 70px;
  width: 133px;
  margin: 10px 10px;
}

.cards-1,
.cards-2,
.cards-3,
.cards-4,
.cards-5,
.cards-6,
.cards-7 {
  width: 50px;
  height: auto;
  position: absolute;
}

.cards-2 {
  left: 35px;
}

.cards-3 {
  left: 70px;
}

.cards-4 {
  left: 105px;
}

.cards-5 {
  left: 140px;
}

.cards-6 {
  left: 200px;
}

.cards-7 {
  left: 235px;
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

.poker-img {
  width: 1.97vw;
  height: 2.65vw;
  margin-right: 10px;
}

</style>
