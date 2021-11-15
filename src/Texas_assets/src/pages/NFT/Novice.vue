<!--FAQ-->
<template>
  <i-nav></i-nav>

  <a-carousel autoplay>
    <div class="item">
      <p>1</p>
    </div>
    <div class="item">
      <p>2</p>
    </div>
    <div class="item">
      <p>3</p>
    </div>
    <div class="item">
      <p>4</p>
    </div>
  </a-carousel>
  <div class="content-wrapper">
    <div class="wrapper">
      <div class="texasFentures">
        <div class="texasFentures">
          <img class="texasFentures-img" src="../../assets/ntf/novice/title_texasFentures.png" alt="">
        </div>
        <div class="texasFentures-image">
          <div class="texasFentures-item" v-for="item in imageList" :key="item.text">
            <img :src="item.img" alt="">
            <div class="texasFentures-info">
              <p>{{ item.title || 0 }}</p>
              <span>{{ item.text || 0 }}</span>
            </div>
          </div>

        </div>
      </div>
      <div class="hands">
        <img src="../../assets/ntf/novice/tittle_hands.png" alt="">

      </div>
      <div class="bets">
        <img src="../../assets/ntf/novice/title_bets.png" alt="">

      </div>
      <div class="actions">
        <img src="../../assets/ntf/novice/title_actions.png" alt="">

      </div>
      <div class="faq">
        <img class="faq-img" src="../../assets/ntf/novice/title_faq.png" alt="">
        <div class="faq-content">
          <div class="theader">
            <div>
              <img src="../../assets/ntf/novice/lingx.png" alt="">
              <span> what is nnsdao ?</span>
            </div>
            <div @click="changeShowFaq1">
              <img src="../../assets/ntf/novice/xiala_s.png" alt="">
            </div>
          </div>
          <div class="tbody" v-if="isShowFaq1">
            <span>
              NnsDAO11111asjdoajsdojasoidjaoijdoajsodiaoisdjoaisjdojaoidjaosjdoaidojasodajhfksdjfiusdfasdfskajnkjn vlnhuioi is a boundaryless autonomous organization, which provides some basic modular programmable services for building the world of DAOn.
            </span>
          </div>
        </div>
      </div>
    </div>

  </div>
  <i-bottom></i-bottom>


</template>

<script>

import {defineComponent, onMounted, ref} from 'vue';

import INav from "../../components/nav.vue";
import IBottom from "../../components/bottom.vue";


export default defineComponent({
  components: {
    INav,
    IBottom,
  },
  setup() {
    onMounted(() => {

    })
    let imageList = [
      {
        img: require('../../assets/ntf/novice/kuang_1.png'),
        title: 'Only one account',
        text: 'All our games can share one\n' +
            'Account. In this way, your re\n' +
            '-maining chipsUm, friends li\n' +
            '-st and achievements can be\n' +
            'Used in all games. Very conv\n' +
            '-enient'
      },
      {
        img: require('../../assets/ntf/novice/kuang_2.png'),
        title: 'Only one account',
        text: 'All our games can share one\n' +
            'Account. In this way, your re\n' +
            '-maining chipsUm, friends li\n' +
            '-st and achievements can be\n' +
            'Used in all games. Very conv\n' +
            '-enient'
      },
      {
        img: require('../../assets/ntf/novice/kuang_3.png'),
        title: 'Only one account',
        text: 'All our games can share one\n' +
            'Account. In this way, your re\n' +
            '-maining chipsUm, friends li\n' +
            '-st and achievements can be\n' +
            'Used in all games. Very conv\n' +
            '-enient'
      },
      {
        img: require('../../assets/ntf/novice/kuang_4.png'),
        title: 'Only one account',
        text: 'All our games can share one\n' +
            'Account. In this way, your re\n' +
            '-maining chipsUm, friends li\n' +
            '-st and achievements can be\n' +
            'Used in all games. Very conv\n' +
            '-enient'
      },
      {
        img: require('../../assets/ntf/novice/kuang_5.png'),
        title: 'Only one account',
        text: 'All our games can share one\n' +
            'Account. In this way, your re\n' +
            '-maining chipsUm, friends li\n' +
            '-st and achievements can be\n' +
            'Used in all games. Very conv\n' +
            '-enient'
      },
      {
        img: require('../../assets/ntf/novice/kuang_6.png'),
        title: 'Only one account',
        text: 'All our games can share one\n' +
            'Account. In this way, your re\n' +
            '-maining chipsUm, friends li\n' +
            '-st and achievements can be\n' +
            'Used in all games. Very conv\n' +
            '-enient'
      },
      {
        img: require('../../assets/ntf/novice/kuang_7.png'),
        title: 'Only one account',
        text: 'All our games can share one\n' +
            'Account. In this way, your re\n' +
            '-maining chipsUm, friends li\n' +
            '-st and achievements can be\n' +
            'Used in all games. Very conv\n' +
            '-enient'
      },
      {
        img: require('../../assets/ntf/novice/kuang_8.png'),
        title: 'Only one account',
        text: 'All our games can share one\n' +
            'Account. In this way, your re\n' +
            '-maining chipsUm, friends li\n' +
            '-st and achievements can be\n' +
            'Used in all games. Very conv\n' +
            '-enient'
      },
    ]


    let isShowFaq1 = ref(true)
    let changeShowFaq1 = () => {
      isShowFaq1.value = !isShowFaq1.value
      console.log(isShowFaq1, '改变之后的')
    }
    return {
      imageList,
      isShowFaq1,
      changeShowFaq1
    };

  }
})
</script>
<style scoped>
.content-wrapper {

  background: url("../../assets/ntf/novice/back.png") no-repeat;

}

.wrapper {
  width: 66.66vw;
  min-width: 1200px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  margin: 0 auto 0 auto;
  padding: 120px 0;
}

.texasFentures {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 66vw;
}


.texasFentures-image {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
  margin-top: 100px;
  padding: 0px 30px 0px 35px;
  background: url("../../assets/ntf/novice/xiexian.png") no-repeat center center;
  background-size: cover;
}


.texasFentures-item {
  width: 21%;
  position: relative;
  padding: 50px 0;
}

.texasFentures-item img {
  width: 100%;
}

.texasFentures-info {
  position: absolute;
  width: 88%;
  height: 27%;
  overflow: hidden;
  top: 59%;
  left: 6%;
}

.texasFentures-info p {
  color: #F9C950;
  text-align: center;
}

.texasFentures-info span {
  color: #EFF8F6;
  text-align: center;
}

.hands, .bets, .actions, .faq {
  margin-top: 150px;
}

.hands img, .bets img, .actions img {
  width: 100%;
}

.faq {
  padding-bottom: 200px;
}

.faq-content {
  width: 75vw;
  margin-top: 100px;

}

.theader {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  padding: 2.5rem 3rem 2rem 2rem;
  font-size: 2rem;
  color: #ECECBC;
  line-height: 2rem;
  text-shadow: 0px 4px 3px rgba(0, 0, 0, 0.5);
  background: url("../../assets/ntf/novice/tiao_di.png") no-repeat center center;
  background-size: cover;

}

.theader img {
  width: 1.5rem;
  height: 1.5rem;
  cursor: pointer;
}

.tbody {
  display: flex;

}

.tbody span {
  color: #FFFFFF;
  padding: 1.6rem 0.8rem 1.8rem 0.8rem;
  text-align: left;
}

.texasFentures-img, .faq-img img {
  width: 36.5vw;
}

/*>>> .nt-collapse{*/
/*  background-color: transparent !important;*/
/*  border: none !important;*/
/*}*/
/*>>> .ant-collapse-arrow {*/
/*  color: #3a2e26;*/
/*  right: 15px;*/
/*  left: auto;*/
/*  height: 1.1rem;*/
/*  width: 1.1rem;*/
/*  border-radius: 50%;*/
/*  line-height: 1.5rem !important;*/
/*  background: #ECECBC;}*/

</style>
<style scoped>
.item {
  background: black;
  color: #fbfeb2;
  width: 100%;
  height: 300px;
}

/*.ant-carousel >>> .slick-dots-bottom {*/
/*  bottom: 3vw;*/
/*}*/

/*.ant-carousel >>> .slick-dots li {*/
/*  position: relative;*/
/*  display: inline-block;*/
/*  margin: 0 2vw;*/
/*  padding: 0;*/
/*  text-align: center;*/
/*  vertical-align: top;*/
/*}*/

/*.ant-carousel >>> .slick-dots li button {*/
/*  display: block;*/
/*  width: 1.3rem;*/
/*  height: 1.3rem;*/
/*  font-size: 0;*/
/*  border: 2px solid #fff;*/
/*  border-radius: 50%;*/
/*  cursor: pointer;*/
/*  transition: all 0.5s;*/
/*}*/
/*.ant-carousel >>> .slick-active{*/
/*  position: relative;*/
/*}*/
/*.slick-active{*/
/*  */
/*}:after{*/
/*  position: absolute;*/
/*  content: '';*/
/*  top: 0px;*/
/*  left: 0px;*/
/*  width: 1rem;*/
/*  height: 1rem;*/
/*  background: #fff;*/
/*  border-radius: 50%;*/
/* }*/
</style>
