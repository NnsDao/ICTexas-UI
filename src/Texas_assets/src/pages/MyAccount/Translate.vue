<template>
  <div>
    <a-modal
      title="Add Recipient"
      v-model:visible="visible"
      :confirm-loading="confirmLoading"
      @ok="handleOk"
    >
      <div>
        <a-input placeholder="Address" size="large" v-model:value="userAddress">
          <template #prefix>
            <search-outlined type="user" />
          </template>
          <template #suffix>
            <a-tooltip title="Recipient Address">
              <info-circle-outlined style="color: rgba(0, 0, 0, 0.45)" />
            </a-tooltip>
          </template>
        </a-input>

        <div>
          <section class="input-section">
            <div>Balance:</div>
            <div class="input-wapper">
              <!-- <div>
                <img
                  class="identicon identicon__image-border"
                  src="../../assets/logo.png"
                />
              </div> -->
              <div class="sec-value">
                {{ userInfo.balance }} {{ tokenInfo.symbol }}
              </div>
              <!-- <div class="value-group">
                <div class="main-value">{{ tokenInfo.symbol }}</div>
                <div class="sec-value">
                  Balance: {{ userInfo.balance }} {{ tokenInfo.symbol }}
                </div>
              </div> -->
            </div>
          </section>

          <section class="input-section">
            <div>
              Amount:
              <a-button shape="round" size="small" type="link" style="padding: 0"
              @click.stop="max">(Max)</a-button>
            </div>
            <a-input
              class="input-wapper"
              v-model:value="translateUnit"
              :suffix="tokenInfo.symbol"
              type="number"
            />
          </section>

          <section class="input-section">
            <div>Fee:</div>
            <div class="input-wapper">
              <div class="">
                {{ tokenInfo.feePercent * translateUnit }} ({{
                  tokenInfo.feePercent
                }}
                * {{ translateUnit }})
              </div>
            </div>
          </section>
        </div>
      </div>
    </a-modal>
  </div>
</template>
<script>
import { SearchOutlined, InfoCircleOutlined } from "@ant-design/icons-vue";
import { defineComponent } from "vue";
import { mapGetters } from "vuex";
import TokenInfo from "../../utils/token";
import { message } from "ant-design-vue";

export default defineComponent({
  components: {
    SearchOutlined,
    InfoCircleOutlined,
  },
  data() {
    return {
      visible: false,
      confirmLoading: false,
      userAddress: '',
      translateUnit: 0
    }
  },
  computed: {
    ...mapGetters("token", ["tokenInfo"]),
    ...mapGetters("user", ["userInfo"]),
  },
  methods: {
    showModal() {
      this.visible = true;
    },

    max() {
      this.translateUnit = this.userInfo.balance
    },

    async handleOk() {
      if (this.userAddress.length !== 64) {
        message.error("Address Error");
        return;
      }

      if (this.translateUnit > this.userInfo.balance) {
        message.error("Not enough balance");
        return;
      }

      this.confirmLoading = true;
      const flag = await TokenInfo.Instance.translate(
        this.userAddress,
        this.translateUnit
      );

      this.confirmLoading = false;
      if (flag) {
        message.info("Translate Success");
        this.visible = false;
      } else {
        message.error("Translate Failed");
      }
    }
  }
});
</script>

<style scoped>
.input-section {
  margin: 1rem 0;
  position: relative;
  display: flex;
  flex-flow: row;
  flex: 1 0 auto;
  justify-content: space-between;
  align-items: center;
}

.input-wapper {
  border: 1px solid #dedede;
  border-radius: 4px;
  /* height: 54px; */
  width: 75%;
  padding: 8px;

  display: flex;
  align-items: center;
}

.value-group {
  margin-left: 12px;
}

.main-value {
  font-size: 1rem;
}

.sec-value {
  font-size: 0.75rem;
}

.noborder {
  width: 100%;
  border: none;
}
</style>