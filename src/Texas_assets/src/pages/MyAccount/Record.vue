<template>
  <div>
    <a-modal title="Transfer History" v-model:visible="visible" @ok="handleOk">
      <a-list size="small" item-layout="horizontal" :data-source="data">
        <template #renderItem="{ item }">
          <a-list-item>
            <a-list-item-meta>
              <template #description>
                <div class="address">{{ item.time }}</div>
              </template>

              <template #title>
                <a-tooltip placement="bottom">
                  <template #title>click to copy</template>
                  <div
                    class="address"
                    @click.stop="copyAddress(item.direction ? item.from : item.to)"
                  >
                    {{ showAddess(item.direction ? item.from : item.to) }}
                  </div>
                </a-tooltip>
              </template>
            </a-list-item-meta>

            <div>
              <a-tag :color="item.color">{{ item.op }}</a-tag>
            </div>

            <div class="amount">
              <span v-if="item.op !== 'approve'">{{ item.direction ? "+" : "-" }}</span> 
              {{ item.amount }}
            </div>
          </a-list-item>
        </template>
      </a-list>
    </a-modal>
  </div>
</template>
<script>
import { ref, defineComponent } from "vue";
import { mapGetters } from "vuex";
import TokenInfo from "../../utils/token";
import { message } from "ant-design-vue";

export default defineComponent({
  components: {},
  data() {
    return {
      data: [],
    };
  },
  mounted() {
    TokenInfo.Instance.getTransactions(this.userInfo.address).then((res) => {   
      this.data = res;
      this.data.forEach((item) => {
        if (item.op === "approve") {
          item.color = "green";
        } else if (item.op === "transfer") {
          item.color = "blue";
        } else {
          item.color = "purple";
        }
      });
    });
  },
  setup() {
    const visible = ref(false);

    const showModal = () => {
      visible.value = true;
    };

    const handleOk = () => {
      visible.value = false;
    };

    return {
      visible,
      showModal,
      handleOk,
    };
  },

  computed: {
    ...mapGetters("token", ["tokenInfo"]),
    ...mapGetters("user", ["userInfo"]),
  },

  methods: {
    showAddess(address) {
      return `${address.substr(0, 10)}...${address.substr(
        address.length - 10
      )}`;
    },

    copyAddress(address) {
      var aux = document.createElement("input");
      aux.setAttribute("value", address);
      document.body.appendChild(aux);
      aux.select();
      document.execCommand("copy");
      document.body.removeChild(aux);
      message.info("Copy success");
    },
  },
});
</script>

<style scoped>
.address {
  font-size: 0.75rem;
  cursor: pointer;
}

.amount {
  width: 150px;
  text-align: right;
}
</style>