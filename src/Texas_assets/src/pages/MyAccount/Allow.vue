<template>
  <div>
    <a-modal
      title="Approve"
      v-model:visible="visible"
      @ok="handleOk"
      :confirm-loading="confirmLoading"
    >
      <div>
        <a-input placeholder="Address" size="large" v-model:value="userAddress">
          <template #prefix>
            <search-outlined type="user" />
          </template>
        </a-input>

        <a-input
          style="margin-top: 10px"
          type="number"
          placeholder="amount"
          size="large"
          v-model:value="amount"
        >
        </a-input>
      </div>
    </a-modal>
  </div>
</template>
<script>
import { SearchOutlined } from "@ant-design/icons-vue";
import { message } from "ant-design-vue";

import { ref, defineComponent } from "vue";
import { mapGetters } from "vuex";
import TokenInfo from "../../utils/token";

export default defineComponent({
  components: {
    SearchOutlined,
  },
  setup() {
    const visible = ref(false);
    const userAddress = ref("");
    const amount = ref("");
    const confirmLoading = ref(false);

    const showModal = () => {
      visible.value = true;
    };

    const handleOk = async () => {
      confirmLoading.value = true;

      if (await TokenInfo.Instance.approve(userAddress.value, amount.value)) {
        message.info("Approve Success");
        visible.value = false;
      } else {
        message.error("Approve Fail");
      }

      confirmLoading.value = false;
    };

    return {
      userAddress,
      visible,
      amount,
      showModal,
      handleOk,
      confirmLoading,
    };
  },

  computed: {
    ...mapGetters("token", ["tokenInfo"]),
    ...mapGetters("user", ["userInfo"]),
  },
});
</script>

<style scoped>
.address {
  font-size: 0.75rem;
}
</style>