<template>
  <div>
    <a-modal
      title="Set Avator"
      v-model:visible="visible"
      :confirm-loading="confirmLoading"
      @ok="handleOk"
    >
      <div class="contanier">
        <a-avatar :size="200"
          :src="imageUrl"
          :style="{ 'margin-bottom': '20px'}"
          :loadError="loadError"
        />

        <a-input placeholder="avator url" size="large" v-model:value="imageUrl" />
      </div>
    </a-modal>
  </div>
</template>
<script>
import { ref, defineComponent } from "vue";
import GameInfo from "../../utils/game";
import { message } from "ant-design-vue";
import store from "../../store";

export default defineComponent({
  setup() {
    const visible = ref(false);
    const confirmLoading = ref(false);
    const imageUrl = ref("");

    const showModal = (url) => {
      visible.value = true;

      if (url.indexOf("http") != -1) {
        imageUrl.value = url;
      }
    };

    const handleOk = async () => {
      const AntAvatarImage = document.getElementsByClassName("ant-avatar-image")
      if (!AntAvatarImage.length || !AntAvatarImage[0].children.length) {
        message.error("Can't find the Image");
        return;
      }

      confirmLoading.value = true;
      const res = await GameInfo.Instance.setAvatar(imageUrl.value);
      if (!res[0]) {
        confirmLoading.value = false;
        message.error(res[1]);
        return;
      }

      await store.dispatch("user/setNickname");

      visible.value = false;
      confirmLoading.value = false;
    };

    return {
      imageUrl,
      visible,
      confirmLoading,
      showModal,
      handleOk,
    };
  },
});
</script>

<style scoped>
.contanier {
  display: flex;
  flex-direction: column;
  align-items: center;
}
</style>