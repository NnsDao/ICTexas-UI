<!-- NFT页面 -->
<template>
  <div class="ntf-wrapper">
    <div class="ntf-tittle">
      <p class="text">Browse Collection：</p>
      <div class="icon-position">
        <a-select
            v-model:value="collectionValue"
            label-in-value
            style="width: 120px; color: #5eb34b; font-size: 18px"
            :options="collectionOptions"
            @change="collectionChange"
            :bordered="false"
            :showArrow='false'
        >
          <!--        <template #suffixIcon ></template>-->
        </a-select>
        <img class="select-icon" src="../../../src/assets/ntf/xiala_nft.png" alt="">
        <div class="Underline"></div>
      </div>

    </div>
    <div class="ntf-content">
      <div class="text-wrapper">
        <div>
          <p>Showing</p>
          <div class="icon-position">

            <a-select
                v-model:value="showingValue"
                label-in-value
                style="width: 150px; color: #d4bb7f; font-size: 16px"
                :options="showingOptions"
                @change="showingChange"
                :showArrow="false"
                :bordered="false"
            >
            </a-select>
            <img class="select-icon" src="../../../src/assets/ntf/xiala_nft.png" alt="">
            <div class="Underline-first"></div>
          </div>

        </div>
        <div>
          <p>Sort By</p>
          <div class="icon-position">

            <a-select
                v-model:value="sortValue"
                label-in-value
                style="width: 180px; color: #d4bb7f; font-size: 16px"
                :options="sortOptions"
                @change="sortChange"
                :showArrow="false"
                :bordered="false"
            >
            </a-select>
            <img class="select-icon" src="../../../src/assets/ntf/xiala_nft.png" alt="">
            <div class="Underline-second"></div>
          </div>
        </div>
      </div>
      <div class="page">
        <a-pagination v-model:current="currentPage" :total="500" @change="pageChange"/>
      </div>
    </div>
    <div class="card-wrapper">
      <div class="item-wrapper" v-for="item in dataSource" :key="item.id"
           :style="{backgroundImage:'url('+item.url+')','background-repeat':'no-repeat','background-size':'cover' }"
      >

        <div class="info">
          <p class="number">{{ item.id }}</p>
          <p class="nrl">{{ item.nrl }}</p>
        </div>
        <div class="pic">
          {{ item.pic + ' ICP' }}
        </div>
        <div class="button">
          button
        </div>
      </div>
    </div>
    <div class="images">
      <img src="" alt="">
    </div>
  </div>
</template>


/**
* @description
* 开发者 赵笑寒 10.28
*
* */
<script>
//import router from "../../router";
import {defineComponent, ref} from 'vue';
import {DownCircleOutlined} from '@ant-design/icons-vue';


export default defineComponent({
  components: {
    DownCircleOutlined
  },
  setup() {
    // Collection下拉框
    const collectionOptions = ref([
      {
        value: '100',
        label: 'Starverse',
      },
      {
        value: '200',
        label: 'Lucy (101)',
      },
    ]);
    // Collection下拉框回调
    const collectionChange = value => {
      console.log(value); // { key: "lucy", label: "Lucy (101)" }
    };

    // Showing 下拉框
    const showingOptions = ref([
      {
        value: '100',
        label: 'Current Listings',
      },
      {
        value: '200',
        label: 'pop',
      },
    ]);
    // Showing 下拉框回调
    const showingChange = value => {
      console.log(value); // { key: "lucy", label: "Lucy (101)" }
    };

    // Sort 下拉框
    const sortOptions = ref([
      {
        value: '100',
        label: 'Price:Loe to Height',
      },
      {
        value: '200',
        label: 'low',
      },
    ]);
    // Collection下拉框回调
    const sortChange = value => {
      console.log(value);
    };

    // 分页器页码改变
    const pageChange = value => {
      console.log(value);
    }

    // 整体数据
    let dataSource = [
      {
        id: '1',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_1.png"),
        pic: '131',
      },
      {
        id: '2',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_2.png"),
        pic: '131',
      },
      {
        id: '3',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_3.png"),
        pic: '131',
      },
      {
        id: '4',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_4.png"),
        pic: '131',
      },
      {
        id: '5',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_5.png"),
        pic: '131',
      },
      {
        id: '6',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_6.png"),
        pic: '131',
      },
      {
        id: '7',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_7.png"),
        pic: '131',
      },
      {
        id: '8',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_8.png"),
        pic: '131',
      },
      {
        id: '9',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_9.png"),
        pic: '131',
      },
      {
        id: '10',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_10.png"),
        pic: '131',
      }, {
        id: '11',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_11.png"),
        pic: '131',
      },
      {
        id: '12',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_12.png"),
        pic: '131',
      },
      {
        id: '13',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_13.png"),
        pic: '131',
      },
      {
        id: '14',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_14.png"),
        pic: '131',
      },
      {
        id: '15',
        nrl: '123',
        url: require("../../../src/assets/ntf/k_15.png"),
        pic: '131',
      },
    ]
    return {
      // DownCircleOutlined,
      // 下拉数据
      collectionValue: ref({
        value: 'Starverse',
      }),
      collectionOptions,
      collectionChange,

      showingValue: ref({
        value: 'Current Listings',
      }),
      showingOptions,
      showingChange,

      sortValue: ref({
        value: 'Price:Loe to Height'
      }),
      sortOptions,
      sortChange,

      // 分页器数据
      currentPage: ref(1),
      pageChange,

      // 数据源
      dataSource
    }
  },
});
</script>

<style scoped>
.ntf-wrapper {
  background-image: url("../../../src/assets/ntf/bg.png");
  background-repeat: no-repeat;
  background-size: cover
}

.ntf-wrapper > .ntf-tittle {
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-content: center;
  padding: 50px 0 30px 0;
}

.ntf-wrapper .ntf-tittle .text {
  font-size: 28px;
  color: #FFFFFF;
  line-height: 28px;
}

.select-icon {
  width: 18px;
  height: 18px;
  position: relative;
  left: -14px;
  top: -3px;
}

.icon-position {
  position: relative;
}

.Underline {
  width: 85px;
  height: 1px;
  background-color: #5eb34b;
  position: absolute;
  bottom: 25px;
  left: 19px;
}


.Underline-first {
  width: 137px;
  height: 1px;
  position: absolute;
  bottom: 0px;
  left: 19px;

  background-color: #d4bb7f;

}

.Underline-second {
  width: 167px;
  height: 1px;
  position: absolute;
  bottom: 0px;
  left: 19px;
  background-color: #d4bb7f;

}


/deep/ .ant-pagination .ant-pagination-item {
  display: inline-block;
  min-width: 10px;
  margin-right: 3px;
  line-height: 30px;
  text-align: center;
  background-color: #1f160a;
  border: none;
}

/deep/ .ant-pagination-item a {
  display: block;
  padding: 0 3px;
  color: #fff;
  transition: none;
}

/deep/ .ant-pagination .ant-pagination-item-active {
  color: black;
  background-color: #5eb34b;
  border-radius: 50%;
}

/deep/ .ant-pagination .ant-pagination-prev {
  background-color: #5eb34b;
  border: none;
}

/deep/ .ant-pagination .ant-pagination-next {
  background-color: #5eb34b;
  border: none;
}

/deep/ .ant-pagination .ant-pagination-disabled {
  background-color: #5d574f;
  border: none;
}

.ntf-content {
  margin: 0 13vw;
  display: flex;
  justify-content: space-between;
  align-items: end;
}

.text-wrapper {
  display: flex;
}

.text-wrapper p {
  margin-left: 20px;
  position: relative;
  top: 18px;
  text-align: left;
  color: #bfbdb8;
}

.card-wrapper {
  margin: 30px 13vw 0 13vw;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
  background: url("../../../src/assets/ntf/xiexian.png");
}

.item-wrapper {
  width: 20%;
  height: 240px;
  margin: 20px 0;
  display: flex;
  flex-direction: column;
}

.item-wrapper > .info {
  padding: 14px 17px;
  margin-bottom: 100px;
  color: #a7a191;
  display: flex;
  justify-content: space-between;
}

.pic {
  color: #f1d2ac;
  font-size: 23px;
  text-align: center;

}


.images {
  margin: 0 13vw;
  height: 700px;
  background-image: url("../../../src/assets/ntf/answer.png");
  background-repeat: no-repeat;
  background-size: cover
}
</style>
