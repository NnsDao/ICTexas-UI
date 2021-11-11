<template>
  <div class="mask" @click="close">
    <div class="title">Round Clear</div>
    <div class="winner">Round Winner: {{ winnerAccount() }}</div>

    <div class="user-group">
      <div
        class="user"
        v-for="user in gameInfo.lastGameReward"
        :key="user.index"
      >
        <div class="rank-info">
          <div class="star-placehoder">
            <img
              v-if="user.rank == 0"
              src="../../assets/game_board/star.png"
              class="start-img"
            />
          </div>

          <img
            v-if="user.rank == 0"
            src="../../assets/game_board/first.png"
            class="rank-img"
          />
          <img
            v-if="user.rank == 1"
            src="../../assets/game_board/second.png"
            class="rank-img"
          />
          <img
            v-if="user.rank == 2"
            src="../../assets/game_board/third.png"
            class="rank-img"
          />
        </div>

        <div class="reward-info">
          <div class="reward" :class="{ top1: user.rank == 0 }">
            {{
              showName(user.account)
            }}
            : + {{ user.reward }}
            <a-tag v-if="user.isFold" class="fold-tag">Fold</a-tag>
            <a-tag v-if="user.isAllIn" class="fold-tag" color="orange">All In</a-tag>
          </div>

          <div class="cards">
            <card
              :class="'cards-' + (index + 1)"
              :type="card"
              v-for="(card, index) in user.cards"
              :key="index"
              :width="50"
            />

            <card
              :class="'cards-' + (index + 6)"
              :type="card"
              v-for="(card, index) in user.resetCards"
              :key="index"
              :width="50"
            />
          </div>

          <div class="card-type">{{ user.type }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { defineComponent } from "vue";
import { mapGetters } from "vuex";
import Card from "./card.vue";

export default defineComponent({
  components: {
    Card,
  },
  setup() {},
  computed: {
    ...mapGetters("game", ["gameInfo"]),

  
  },
  methods: {
    close() {
      this.$emit("close");
    },

    winnerAccount() {
      console.log(this.gameInfo,'gameInfo')
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
});
</script>



<style scoped>
.mask {
  position: fixed;
  left: 0;
  right: 0;
  top: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.9);
}

.title {
  margin-top: 20px;
  font-size: 32px;
  font-weight: 900;
  color: yellow;
}

.winner {
  font-size: 18px;
  font-weight: bold;
  color: #fff;
}

.user-group {
  height: 620px;
  display: flex;
  flex-direction: column;
  flex-wrap: wrap;
  align-items: center;
}

.user {
  width: 350px;
  display: flex;
}

.star-placehoder {
  height: 26px;
}

.reward {
  font-size: 18px;
  font-weight: bold;
  color: #fff;
  display: flex;
  align-items: center;
}

.reward-info {
  width: 300px;
}

.reward.top1 {
  color: yellow;
}

.card-type {
  font-size: 16px;
  font-weight: bold;
  color: #eee;
  text-align: right;
}

.rank-img {
  width: 40px;
  height: auto;
  margin: 10px;
}

.start-img {
  width: 30px;
  height: auto;
}

.rank-info {
  width: 60px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.cards {
  position: relative;
  height: 70px;
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

.end-btn {
  position: absolute;
  top: 660px;
  left: calc(50% - 60px);

  height: 62px;
  width: 122px;

  background-image: url("../../assets/game_board/btn_end.png");
  background-size: contain;
  cursor: pointer;
}

.end-btn:hover {
  background-image: url("../../assets/game_board/btn_end_pressed.png");
}

.fold-tag {
  margin-left: 5px;
}
</style>