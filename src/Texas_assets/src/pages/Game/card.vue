<template>
  <div>
    <img class="card" :src="pokerMap.getItem(type)" alt="" srcset="" :style="{ 'width': width + 'px', 'height': height }" />
  </div>
</template>

<script>
import { defineComponent } from "vue";
export default defineComponent({
  props: {
    type: {
      type: String,
      default: "back",
    },
    width: {
      type: Number,
      default: 70
    },
    height: {
      type: String,
      default: 'auto'
    }
  },
  setup() {
      return {
          pokerMap: window.localStorage
      }
  },
});
</script>

<style scoped>
.card {
  height: auto;
}
</style>
