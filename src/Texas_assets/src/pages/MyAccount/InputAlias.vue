<template>
  <div>
    <a-modal
      title="Input Nickname"
      v-model:visible="visible"
      :confirm-loading="confirmLoading"
      @ok="handleOk"
    >
      <div>
        <a-input placeholder="Nickname" size="large" v-model:value="alias">
          <template #suffix>
            <UserAddOutlined type="user" />
          </template>
        </a-input>
      </div>
    </a-modal>
  </div>
</template>
<script>
import { UserAddOutlined } from "@ant-design/icons-vue";
import { ref, defineComponent } from "vue";
import GameInfo from "../../utils/game";
import { message } from "ant-design-vue";
import store from "../../store";

export default defineComponent({
  components: {
    UserAddOutlined,
  },
  setup() {
    const visible = ref(false);
    const alias = ref("");
    const confirmLoading = ref(false);

    const showModal = () => {
      visible.value = true;
    };

    const handleOk = async () => {
      if (alias.value.length === 0) {
        message.error("Nickname cannot be empty");
        return;
      }

      if (alias.value.length > 18) {
        message.error("Nickname cannot exceed 18 characters");
        return;
      }

      confirmLoading.value = true;
      const res = await GameInfo.Instance.setAlias(alias.value);
      if (!res[0]) {
        confirmLoading.value = false;
        message.error(res[1])
        return;
      }

      await store.dispatch("user/setNickname");

      visible.value = false;
      confirmLoading.value = false;
    };

    return {
      visible,
      alias,
      confirmLoading,
      showModal,
      handleOk,
    };
  },
});
</script>

<style scoped>
</style>