<template>
  <div>
    <a-card hoverable class="account-card">
      <template #title>
        <div class="hover-copy">
          <div class="token-name">
            {{ tokenInfo.name }} ({{ tokenInfo.symbol }})
          </div>
          <a-tooltip placement="bottom">
            <template #title>click to copy</template>
            <div class="user-address" @click.stop="copyAddress">
              {{ showAddess(userInfo.address) }}
              <div v-if="userInfo.nickName">{{ userInfo.nickName }}</div>
            </div>
          </a-tooltip>
        </div>
      </template>

      <template #extra>
        <a-popover
          trigger="hover"
          placement="left"
          :visible="isShowMenu"
          @click.stop="showMenu()"
        >
          <template #content>
            <a-button block class="menu-item" type="link" @click.stop="goRecord"
              >Transfer History</a-button
            >
            <a-button block class="menu-item" type="link" @click.stop="setName"
              >Set Nickname</a-button
            >
            <a-button
              block
              class="menu-item"
              type="link"
              @click.stop="setAvator"
              >Set Avator</a-button
            >
            <a-button block class="menu-item" type="link" @click.stop="logout"
              >Logout</a-button
            >
          </template>
          <ellipsis-outlined />
        </a-popover>
      </template>

      <div class="myaccount-content">
        <img
          class="identicon identicon__image-border"
          src="../../assets/logo.png"
        />
        <div class="balance">
          <span>{{ userInfo.balance }}</span>
          <span class="symbol">{{ tokenInfo.symbol }}</span>
        </div>

        <div class="action-group">
          <div class="action-item">
            <a-button
              type="primary"
              shape="circle"
              @click.stop="mint"
              :loading="mintLoading"
            >
              <template #icon><PlusOutlined /></template>
            </a-button>
            <div class="action-text">Mint</div>
          </div>

          <div class="action-item" @click.stop="translateToken">
            <a-button type="primary" shape="circle">
              <template #icon><SwapOutlined /></template>
            </a-button>
            <div class="action-text">Transfer</div>
          </div>

          <div class="action-item" @click.stop="allow">
            <a-button type="primary" shape="circle">
              <template #icon><ExpandAltOutlined /></template>
            </a-button>
            <div class="action-text">Approve</div>
          </div>
        </div>
      </div>
    </a-card>

    <translate ref="translate" />
    <record v-if="isShowRecord" ref="record" />
    <allow ref="allow" />
    <input-alias ref="alias" />
<!--    <set-avator v-if="isShowAvatorDialog" ref="avator" @offAvatorDialog="offAvatorDialog"/>-->
    <AvatorDialog v-if="isShowAvatorDialog" ref="avator" @offAvatorDialog="offAvatorDialog"/>
  </div>
</template>

<script>
import {
  EllipsisOutlined,
  PlusOutlined,
  SwapOutlined,
  ExpandAltOutlined,
} from "@ant-design/icons-vue";
import Translate from "./Translate.vue";
import Record from "./Record.vue";
import Allow from "./Allow.vue";
import InputAlias from "./InputAlias.vue";
import AvatorDialog from "../NFT/AvatorDialog";

import { mapGetters } from "vuex";
import { message } from "ant-design-vue";
import { defineComponent, ref, onMounted } from "vue";
import TokenInfo from "../../utils/token";
import GameInfo from "../../utils/game";
import router from "../../router";
import { isAgentExpiration } from "../../utils/identity";
import store from "../../store";

export default defineComponent({
  components: {
    EllipsisOutlined,
    PlusOutlined,
    SwapOutlined,
    ExpandAltOutlined,
    Translate,
    Record,
    Allow,
    InputAlias,
    AvatorDialog,
    // SetAvator,
  },
  data() {
    return {
      isShowRecord: false,
    };
  },
  setup() {
    const mintLoading = ref(false);
    let isShowAvatorDialog =ref(false)
    const mint = async () => {
      mintLoading.value = true;
      const flag = await TokenInfo.Instance.mint();
      mintLoading.value = false;

      if (flag) {
        message.info("Mint Success");
      } else {
        message.info("Mint Failed");
      }
    };

    onMounted(async () => {
      if (!TokenInfo.Instance.isLogin) {
        if (await isAgentExpiration()) {
          router.push("/");
        } else {
          await store.dispatch("token/setTokenBasicInfo");
          await store.dispatch("user/setBalance");
        }
      }
    });

    const isShowMenu = ref(false);
    const showMenu = () => {
      isShowMenu.value = !isShowMenu.value;
    }

    return {
      isShowMenu,
      showMenu,

      mintLoading,
      mint,
      isShowAvatorDialog
    };
  },
  computed: {
    ...mapGetters("token", ["tokenInfo"]),
    ...mapGetters("user", ["userInfo"]),
  },
  methods: {
    translateToken() {
      store.dispatch("user/setBalance");
      this.$refs.translate.showModal();
    },

    goRecord() {
      this.isShowMenu = false;
      this.isShowRecord = true;
      this.$nextTick(() => {
        this.$refs.record.showModal();
      });
    },

    allow() {
      this.$refs.allow.showModal();
    },

    logout() {
      TokenInfo.Instance.logout();
      GameInfo.Instance.logout();
      router.push("/");
    },

    copyAddress() {
      var aux = document.createElement("input");
      aux.setAttribute("value", this.userInfo.address);
      document.body.appendChild(aux);
      aux.select();
      document.execCommand("copy");
      document.body.removeChild(aux);
      message.info("Copy success");
    },

    showAddess(address) {
      return `${address.substr(0, 10)}...${address.substr(
        address.length - 10
      )}`;
    },

    setName() {
      this.isShowMenu = false;
      this.$refs.alias.showModal();
    },

    setAvator() {
      this.isShowMenu = false
      this.$refs.avator.showModal(this.userInfo.avatorUrl);
    },
    offAvatorDialog(){
      this.isShowAvatorDialog = false
    }
  },
});
</script>

<style>
.identicon {
  direction: ltr;
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  overflow: hidden;

  height: 32px;
  width: 32px;
  border-radius: 16px;
}

.identicon__image-border {
  border: 1px solid #dedede;
  background: #fff;
}
</style>

<style scoped>
.account-card {
  width: 300px;
  user-select: none;
  margin: 0 auto;
}

.token-name {
  font-size: 1rem;
  line-height: 140%;
  font-weight: 500;
  white-space: nowrap;
  text-align: center;
  margin-bottom: 4px;
}

.user-address {
  font-size: 0.75rem;
  color: #989a9b;
}

.hover-copy {
}

.myaccount-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
}

.balance {
  font-size: 2rem;
  font-family: Euclid, Roboto, Helvetica, Arial, sans-serif;
  line-height: 140%;
  font-style: normal;
  font-weight: normal;
  color: #000;
  width: 100%;
  justify-content: center;
  margin: 16px 0;
}

.symbol {
  margin-left: 4px;
}

.action-group {
  display: flex;
  flex-direction: row;
  justify-content: center;
  color: #1890ff;
}

.action-item {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 55px;
}

.action-group .action-item:not(:last-child) {
  margin-right: 30px;
}

.action-text {
  margin-top: 4px;
}
</style>