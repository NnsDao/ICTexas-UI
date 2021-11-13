<template>
  <div>
    <img class="card" :src="pokerMap.getItem(type)" alt="" srcset="" />
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
    // width: {
    //   type: String,
    //   default: '70px',
    // },
    // height: {
    //   type: String,
    //   default: 'auto'
    // }
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
  height: 100%;
  width: 100%;
}
</style>
