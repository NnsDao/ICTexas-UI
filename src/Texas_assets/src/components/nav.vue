<template>
  <div class="nav">
    <div>
      <img class="logo" src="../assets/v2/nav/logo.png"/>
    </div>
    <div class="menu " :class="{selected: currentSeclect === 'room' || currentSeclect === 'game'}" @click="changeSeclect('room')">
      <span>ROOM</span>
    </div>
    <div class="menu" :class="{selected: currentSeclect === 'market'}" @click="changeSeclect('market')">
      <span>NFT</span>
    </div>
    <div class="menu" :class="{selected: currentSeclect === 'kft'}" @click="changeSeclect('kft')">
      <span>Market</span>
    </div>
    <div class="menu">
      <div>
        <a-avatar size="large" class="user-btn" @click.stop="showMyaccount()">
          <template #icon>
            <img :src="userInfo.avatorUrl"/>
          </template>
        </a-avatar>
        {{ userInfo.nickName ? userInfo.nickName : showAddess(userInfo.address) }}
      </div>
    </div>
  </div>
  <user-info-dialog v-if="isShowAccount" @close=" close()"/>
</template>

<script>
import {mapGetters} from "vuex";
import {defineComponent, onMounted, ref, getCurrentInstance} from "vue";
import UserInfoDialog from "../pages/MyAccount/UserInfoDialog.vue";
import {useRoute} from 'vue-router'

export default defineComponent({
  components: {UserInfoDialog},
  setup() {
    const isShowAccount = ref(false);
    const showMyaccount = () => {
      isShowAccount.value = !isShowAccount.value;
    };
    const route = useRoute()
    let currentSeclect = ref((route.path + '').substring(1))
    return {
      isShowAccount,
      showMyaccount,
      currentSeclect
    }
  },
  computed: {
    ...mapGetters("token", ["tokenInfo"]),
    ...mapGetters("user", ["userInfo"]),
  },
  methods: {
    changeSeclect(name) {
      if (this.currentSeclect === name) {
        return this.currentSeclect
      } else {
        this.currentSeclect = name
        this.$router.push({
          path: `${'/' + name}`
        })
      }
    },
    showAddess(address) {
      return `${address.substr(0, 10)}...${address.substr(
          address.length - 10
      )}`;
    },
    close() {
      this.isShowAccount = false
    }
  }

})
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

.nav > div {
  cursor: pointer;
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
</style>