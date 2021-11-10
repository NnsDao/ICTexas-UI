<template>
  <div class="dialog-wrapper" @click.self="close()">
    <div class="dialog">
      <div class="dialog-top">
        <div class="picture">
          <a-avatar :size="75" class="user-btn">
            <template #icon>
              <img :src="userInfo.avatorUrl" @click="setAvator"/>
            </template>
          </a-avatar>
        </div>
        <div class="main-info">
          <div class="first">
            <a-input v-if="isShowEdit" ref="nickName" @blur="submitNickName" v-model:value="newName"
                     placeholder="input nickname"/>
            <span v-if="!isShowEdit"
                  style="font-size: 24px;color: #D48940">{{ userInfo.nickName ? userInfo.nickName : 'set name' }}</span>
            &nbsp;<img src="../../assets/ntf/userinfo/bianji.png" alt="" @click="changeShowEdit">
          </div>
          <div class="first">
            <img src="../../assets/ntf/userinfo/yt.png" alt="">
            &nbsp;<span>{{ userInfo.balance + 'GFT' }}</span>
          </div>
          <div class="first">
            <img src="../../assets/ntf/userinfo/g.png" alt="">
            &nbsp;{{ 'nnsdao' }}
          </div>
          <div class="first">
            {{ 'id' }}&nbsp;&nbsp;
            <a-tooltip placement="bottom">
              <template #title>click to copy</template>
              <div class="user-address" @click.stop="copyAddress">
                {{ showAddess(userInfo.address) }}
              </div>
            </a-tooltip>
          </div>

        </div>
        <div class="mid">
          <div class="action-group">
            <div class="action-item">
              <a-button
                  type="primary"
                  shape="circle"
                  @click.stop="mint"
                  :loading="mintLoading"
              >
                <template #icon>
                  <PlusOutlined/>
                </template>
              </a-button>
              <div class="action-text">Mint</div>
            </div>

            <div class="action-item" @click.stop="translateToken">
              <a-button type="primary" shape="circle">
                <template #icon>
                  <SwapOutlined/>
                </template>
              </a-button>
              <div class="action-text">Transfer</div>
            </div>

            <div class="action-item" @click.stop="allow">
              <a-button type="primary" shape="circle">
                <template #icon>
                  <ExpandAltOutlined/>
                </template>
              </a-button>
              <div class="action-text">Approve</div>
            </div>
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
            <div>nnsdao</div>
            <div>
              <img src="../../assets/ntf/userinfo/yt.png" alt="">
              <span>nnsdao</span>
            </div>
            <div>nnsdao</div>
            <div>nnsdao</div>
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
    <translate ref="translate"/>
    <allow ref="allow"/>
    <avator-dialog v-if="isShowAvatorDialog" ref="avator" @offAvatorDialog="offAvatorDialog"/>

  </div>
</template>

<script>
import {
  EllipsisOutlined,
  PlusOutlined,
  SwapOutlined,
  ExpandAltOutlined,
} from "@ant-design/icons-vue";
import {defineComponent, ref} from 'vue';
import {mapGetters} from "vuex";
import {message} from "ant-design-vue";
import GameInfo from "../../utils/game";
import store from "../../store";
import TokenInfo from "../../utils/token";
import Translate from "./Translate.vue";
import Allow from "./Allow.vue";
import AvatorDialog from "./AvatorDialog.vue";
// import {DownCircleOutlined} from '@ant-design/icons-vue';


export default defineComponent({
  components: {
    EllipsisOutlined,
    PlusOutlined,
    SwapOutlined,
    ExpandAltOutlined,
    Translate,
    Allow,
    AvatorDialog
  },
  setup() {

    let dataSource = [
      {
        id: '1',
        top: '123',
        url: require("../../assets/ntf/k_1.png"),
        bottom: '131',
      },
      {
        id: '2',
        top: '123',
        url: require("../../assets/ntf/k_2.png"),
        bottom: '131',
      },
      {
        id: '3',
        top: '123',
        url: require("../../assets/ntf/k_3.png"),
        bottom: '131',
      },
      {
        id: '4',
        top: '123',
        url: require("../../assets/ntf/k_4.png"),
        bottom: '131',
      },
      {
        id: '5',
        top: '123',
        url: require("../../assets/ntf/k_5.png"),
        bottom: '131',
      },
    ]
    let isShowEdit = ref(false)
    let newName = ref('')
    let isShowAvatorDialog = ref(false)

    let submitNickName = async () => {
      if (newName.value.length === 0) {
        message.error("Nickname cannot be empty");
        return;
      }

      if (newName.value.length > 18) {
        message.error("Nickname cannot exceed 18 characters");
        return;
      }

      const res = await GameInfo.Instance.setAlias(newName.value);
      if (!res[0]) {
        message.error(res[1])
        return;
      }

      await store.dispatch("user/setNickname");
      message.success('change success')
    };
    let mintLoading = ref(false)
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
    return {
      dataSource,
      isShowEdit,
      newName,
      submitNickName,
      mint,
      mintLoading,
      isShowAvatorDialog

    }
  },
  computed: {
    ...mapGetters("user", ["userInfo"]),
  },
  methods: {
    close() {
      console.log(111)
      this.$emit('close')
    },
    changeShowEdit() {
      this.isShowEdit = !this.isShowEdit
      this.$nextTick(function () {
        this.$refs.nickName.focus();
      });
    },
    showAddess(address) {
      return `${address.substr(0, 7)}...${address.substr(
          address.length - 7
      )}`;
    },
    copyAddress() {
      const aux = document.createElement("input");
      aux.setAttribute("value", this.userInfo.address);
      document.body.appendChild(aux);
      aux.select();
      document.execCommand("copy");
      document.body.removeChild(aux);
      message.info("Copy success");
    },
    translateToken() {
      store.dispatch("user/setBalance");
      this.$refs.translate.showModal();
    },
    allow() {
      this.$refs.allow.showModal();
    },
    setAvator() {
      this.isShowAvatorDialog = true
      this.$nextTick(() => {
        this.$refs.avator.showModal(this.userInfo.avatorUrl);
      });
    },
    offAvatorDialog() {
      this.isShowAvatorDialog = false
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
  background: url("../../assets/ntf/userinfo/dk_a.png") no-repeat;
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
  background: url("../../assets/ntf/userinfo/anniu.png") no-repeat;
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
  margin: 8% 4% 13% 4%;
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.text-green {
  color: #64cd56;
}

.dialog-bottom .item img {
  width: 58%;
}

.action-item {
  display: flex;
  align-items: center;
}

.action-text {
  margin-left: 1rem;
}


.ant-btn-icon-only {
  width: 2rem;
  height: 2rem;
  padding: 2.4px 0;
  font-size: 16px;
  border-radius: 50%;
  vertical-align: -1px;
}
</style>
