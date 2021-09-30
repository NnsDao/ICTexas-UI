<template>
  <div class="nav">
    <div class="logo">
      <img src="../../assets/v2/nav/logo.png" />
    </div>
    <div class="menu selected">
      <span>ROOM</span>
    </div>
    <div class="menu">
      <span>NFT</span>
    </div>
    <div class="menu">
      <span>Market</span>
    </div>
    <div class="menu">
      <span>Nickname / login</span>
    </div>
  </div>

  <div @click.stop="colseMyaccount()">
    <div class="user-info">
      <div class="balance">Balance: {{ userInfo.balance }}</div>
      <a-avatar size="large" @click.stop="showMyaccount()">
        <template #icon><img :src="userInfo.avatorUrl" /></template>
      </a-avatar>
    </div>

    <a-spin :spinning="spinning">
      <div class="level-select">
        <div
          v-for="site in siteInfo"
          :key="site.index"
          class="select-btn"
          @click="siteDown(site.level)"
        >
          <div class="level">{{ showLevelName(site.level) }}</div>
          <div class="limit">{{ site.limit }}</div>
        </div>
      </div>
    </a-spin>

    <transition name="fade">
      <my-account class="my-account" v-if="isShowAccount" />
    </transition>

    <input-alias ref="alias" />
  </div>

  <div class="bottom">
    <div class="intro">
      <div>
        <h3>Docs</h3>
        <p>Guide</p>
        <p>Advanced</p>
      </div>
      <div>
        <h3>Docs</h3>
        <p>Guide</p>
        <p>Advanced</p>
      </div>
      <div>
        <h3>Docs</h3>
        <p>Guide</p>
        <p>Advanced</p>
      </div>
    </div>
    <div class="copyright">
      <p>© Nnsdao Labs 2021</p>
      <div>
        <span>A</span>
        <span>B</span>
        <span>C</span>
      </div>
    </div>
  </div>
</template>

<script>
import { message } from "ant-design-vue";
import { defineComponent, ref } from "vue";
import { mapGetters } from "vuex";
import store from "../../store";
import GameInfo from "../../utils/game";
import TokenInfo from "../../utils/token";
import router from "../../router";
import MyAccount from "../MyAccount/index.vue";
import InputAlias from "../MyAccount/InputAlias.vue";
import { isAgentExpiration } from "../../utils/identity";

export default defineComponent({
  components: {
    MyAccount,
    InputAlias,
  },
  setup() {
    const spinning = ref(false);
    const isShowAccount = ref(false);

    const showMyaccount = () => {
      isShowAccount.value = !isShowAccount.value;
    };

    const colseMyaccount = () => {
      isShowAccount.value = false;
    };

    const siteDown = async (type) => {
      if (await !isAgentExpiration()) {
        message.info("Login has expired！");
        TokenInfo.Instance.logout();
        GameInfo.Instance.logout();
        router.push("/");
        return;
      }

      spinning.value = true;
      const result = await GameInfo.Instance.userSitdown(type);
      if (result[0]) {
        router.push("/game");
      } else {
        message.error(result[1]);
      }
      spinning.value = false;
    };

    const LevelMapping = {
      low: "Low",
      mid: "Middle",
      high: "High",
    };
    const showLevelName = (level) => {
      return LevelMapping[level];
    };

    return {
      spinning,
      isShowAccount,
      showMyaccount,
      colseMyaccount,
      siteDown,
      showLevelName,
    };
  },
  computed: {
    ...mapGetters("user", ["userInfo"]),
    ...mapGetters("game", ["siteInfo", "userStatus"]),
  },
  watch: {
    userStatus(to) {
      if (to !== "notinseat") {
        router.push("/game");
      }
    },
  },
  async mounted() {
    this.spinning = true;
    await store.dispatch("game/setGameEnd");
    await TokenInfo.Instance.login();
    await GameInfo.Instance.login();

    await store.dispatch("token/setTokenBasicInfo");
    await store.dispatch("game/setGameSite");
    await Promise.all([
      store.dispatch("user/setBalance"),
      store.dispatch("user/setNickname"),
    ]);

    if (!this.userInfo.nickName) {
      this.$refs.alias.showModal();
    }
    this.spinning = false;
    await store.dispatch("game/setUserStatus");
  },
});
</script>


<style scoped>
.nav {
  width: 100vw;
  height: 70px;
  background: #1b2125;
  border-bottom: 1px solid #c5a86f;
  color: #74fbcf;
  font-size: 24px;
  font-weight: 400;
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.logo {
  width: 181px;
  height: 50px;
}

.menu {
  height: 100%;
  display: flex;
  align-items: center;
}

.selected {
  color: #f7c745;
  background-image: linear-gradient(
    rgba(87, 47, 12, 0),
    rgba(87, 47, 12, 0.77)
  );
  border-bottom: solid 3px #fbe79f;
}

.selected::after,
.selected::before {
  content: "◆";
  font-size: 14px;
  line-height: 14px;
  margin: 0 5px;
}

.bottom {
  border-top: 1px solid #c5a86f;
  width: 100vw;
  height: 186px;
  display: flex;
  flex-direction: column;
  background: #13171a;
  color: #98a7b1;
  padding: 0 16.66vw;
}

.intro {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  font-weight: 400;
  line-height: 30px;
  padding: 30px 2.18vw 12px;
  border-bottom: 1px dashed #2D3B45;;
}

.intro p {
  margin: 0;
}

.intro h3 {
  color: #98a7b1;
}

.copyright{
    display: flex;
    justify-content: space-between;
    padding: 12px 2.18vw;
}

.level-select {
  /* height: 100vh; */
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.select-btn {
  height: 70px;
  width: 50vw;

  border-radius: 35px;
  background-color: #000;
  color: white;
  cursor: pointer;

  margin-bottom: 40px;

  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.select-btn:hover,
.select-btn:focus {
  background-color: black;
  color: #fff;
  border: none;

  opacity: 0.9;
  box-shadow: 0 0 0 2px #ffffff, 0 0 3px 5px #29abe2;
  outline: 2px dotted transparent;
  outline-offset: 2px;
}

.level {
  font-size: 1.5rem;
  font-weight: bolder;
  font-family: monospace;
}

.limit {
  font-size: 0.8rem;
  font-weight: normal;
}

.user-info {
  position: fixed;
  right: 20px;
  top: 20px;
  z-index: 100;

  display: flex;
  justify-items: center;
  align-items: center;
}

.my-account {
  position: absolute;
  right: 20px;
  top: 80px;
}

.balance {
  font-size: 24px;
  color: #fff;
  font-weight: 900;
  cursor: pointer;
  margin-right: 20px;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 1s;
}

.fade-enter,
.fade-leave-to {
  opacity: 0;
}
</style>